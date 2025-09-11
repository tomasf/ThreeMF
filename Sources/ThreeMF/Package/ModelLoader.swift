import Foundation
import Zip

public struct ModelLoader<Source: Sendable> {
    private let source: Source

    private init(source: Source) {
        self.source = source
    }

    public init(url: URL) where Source == URL {
        self.init(source: url)
    }

    public init(data: Data) where Source == Data {
        self.init(source: data)
    }

    public func load() async throws -> LoadedModel {
        let readerSource = self.source

        @Sendable func makeReader() throws -> PackageReader<Source> {
            if let url = readerSource as? URL {
                try PackageReader(url: url) as! PackageReader<Source>
            } else if let data = readerSource as? Data {
                try PackageReader(data: data) as! PackageReader<Source>
            } else { preconditionFailure() }
        }

        let rootModel = try makeReader().model()

        let additionalModelPaths = Set(rootModel.build.items.compactMap(\.path))
            .union(rootModel.resources.resources.flatMap { resource -> [URL] in
                guard let object = resource as? Object,
                      case .components(let components) = object.content
                else { return [] }
                return components.compactMap(\.path)
            })

        let additionalModels = try await additionalModelPaths.asyncMap {
            do {
                return ($0, try makeReader().model(at: $0))
            } catch ZipError.fileNotFound {
                throw LoadingError.modelNotFoundInArchive(path: $0)
            }
        }

        var models: [URL?: Model] = Dictionary(uniqueKeysWithValues: additionalModels)
        models[nil] = rootModel
        let staticModels = models

        let references = try rootModel.build.items.map {
            ($0, try meshObjectsReferences(for: $0, with: staticModels))
        }

        let allRefs = Set(references.flatMap(\.1).map(\.reference))
        let orderedModelPaths = Array(Set(allRefs.map(\.modelPath)))

        let meshes = Dictionary(uniqueKeysWithValues: await allRefs.asyncMap { reference in
            guard let model = staticModels[reference.modelPath],
                  let modelIndex = orderedModelPaths.firstIndex(of: reference.modelPath),
                  let object = model.resources.resource(for: reference.objectID) as? Object,
                  case .mesh (let mesh) = object.content
            else { preconditionFailure() }

            return (reference, LoadedModel.LoadedMesh(mesh: mesh, modelIndex: modelIndex))
        })

        var indexedMeshes: [LoadedModel.LoadedMesh] = []
        let meshIndexByReference = meshes.mapValues { mesh in
            let index = indexedMeshes.count
            indexedMeshes.append(mesh)
            return index
        }

        let orderedModels = orderedModelPaths.compactMap { models[$0] }

        return LoadedModel(rootModel: rootModel, models: orderedModels, meshes: indexedMeshes, items: references.map { item, references in
            guard let rootObject = models[item.path]?.resources.resource(for: item.objectID) as? Object else {
                preconditionFailure()
            }
            return LoadedModel.LoadedItem(item: item, rootObject: rootObject, components: references.map { reference in
                guard let meshIndex = meshIndexByReference[reference.reference] else { preconditionFailure() }
                return LoadedModel.LoadedComponent(
                    meshIndex: meshIndex,
                    transforms: reference.transforms,
                    propertyGroupID: reference.propertyGroupID,
                    propertyIndex: reference.propertyIndex,
                    names: reference.names,
                    partNumbers: reference.partNumbers
                )
            })
        })
    }

    private func meshObjectReferences(
        for objectID: ResourceID,
        in modelPath: URL?,
        with models: [URL?: Model],
        propertyGroupID: ResourceID?,
        propertyIndex: ResourceIndex?
    ) throws -> [MeshObjectReference] {
        guard let model = models[modelPath],
              let object = model.resources.resource(for: objectID) as? Object
        else {
            throw LoadingError.objectNotFound(modelPath: modelPath, objectID)
        }

        let resolvedPropertyGroupID = object.propertyGroupID ?? propertyGroupID
        let resolvedPropertyIndex = object.propertyIndex ?? propertyIndex

        return switch object.content {
        case .mesh:
            [MeshObjectReference(
                id: objectID,
                in: modelPath,
                propertyGroupID: resolvedPropertyGroupID,
                propertyIndex: resolvedPropertyIndex,
                name: object.name,
                partNumber: object.partNumber
            )]

        case .components (let components):
            try components.flatMap { component in
                try meshObjectReferences(
                    for: component.objectID,
                    in: component.path,
                    with: models,
                    propertyGroupID: resolvedPropertyGroupID,
                    propertyIndex: resolvedPropertyIndex
                )
                .map { $0.prepending(transform: component.transform, name: object.name, partNumber: object.partNumber) }
            }
        }
    }

    private func meshObjectsReferences(for item: Item, with models: [URL?: Model]) throws -> [MeshObjectReference] {
        try meshObjectReferences(for: item.objectID, in: item.path, with: models, propertyGroupID: nil, propertyIndex: nil)
            .map { $0.prepending(transform: item.transform, partNumber: item.partNumber) }
    }
}

public extension ModelLoader {
    enum LoadingError: Error {
        case modelNotFoundInArchive (path: URL)
        case objectNotFound (modelPath: URL?, ResourceID)
    }

    struct LoadedModel: Sendable {
        public let rootModel: Model
        public let models: [Model]
        public let meshes: [LoadedMesh]
        public let items: [LoadedItem]

        public struct LoadedMesh: Sendable {
            public let mesh: Mesh
            public let modelIndex: Int
        }

        public struct LoadedItem: Sendable {
            public let item: Item
            public let rootObject: Object
            public let components: [LoadedComponent]
        }

        public struct LoadedComponent: Sendable {
            public let meshIndex: Int
            public let transforms: [Matrix3D]
            public let propertyGroupID: ResourceID?
            public let propertyIndex: ResourceIndex?
            public var names: [String]
            public var partNumbers: [String]
        }
    }
}

struct MeshObjectReference {
    let reference: ObjectReference
    let transforms: [Matrix3D]
    let propertyGroupID: ResourceID?
    let propertyIndex: ResourceIndex?
    let names: [String]
    let partNumbers: [String]

    struct ObjectReference: Hashable {
        let modelPath: URL?
        let objectID: ResourceID
    }

    private init(
        reference: ObjectReference,
        transforms: [Matrix3D] = [],
        propertyGroupID: ResourceID?,
        propertyIndex: ResourceIndex?,
        names: [String],
        partNumbers: [String]
    ) {
        self.reference = reference
        self.transforms = transforms
        self.propertyGroupID = propertyGroupID
        self.propertyIndex = propertyIndex
        self.names = names
        self.partNumbers = partNumbers
    }

    init(
        id objectID: ResourceID,
        in modelPath: URL?,
        propertyGroupID: ResourceID?,
        propertyIndex: ResourceIndex?,
        name: String?,
        partNumber: String?
    ) {
        self.init(
            reference: ObjectReference(modelPath: modelPath, objectID: objectID),
            transforms: [],
            propertyGroupID: propertyGroupID,
            propertyIndex: propertyIndex,
            names: name.map { [$0] } ?? [],
            partNumbers: partNumber.map { [$0] } ?? [],
        )
    }

    func prepending(transform: Matrix3D? = nil, name: String? = nil, partNumber: String? = nil) -> MeshObjectReference {
        return MeshObjectReference(
            reference: reference,
            transforms: (transform.map { [$0] } ?? []) + transforms,
            propertyGroupID: propertyGroupID,
            propertyIndex: propertyIndex,
            names: name.map { [$0] + self.names } ?? names,
            partNumbers: partNumber.map { [$0] + self.partNumbers } ?? partNumbers,
        )
    }
}
