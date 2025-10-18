import Foundation
import Zip

/// Loads 3MF model packages from either a URL or in‑memory data, resolves cross‑file references,
/// and produces a flattened, render‑ready representation of meshes and build items.
///
/// ModelLoader reads a root 3MF model and any additional models it references. It then resolves
/// each build item down to concrete mesh instances with accumulated transforms, properties, and metadata.
/// The result is a LoadedModel that is convenient to render or further process.
///
/// Usage:
/// - Initialize with a URL or Data
/// - Call `load()` to obtain a `LoadedModel`
///
/// Example:
/// ```swift
/// let loader = ModelLoader(url: fileURL)
/// let loaded = try await loader.load()
/// ```
///
/// Threading:
/// - `load()` is async and can be awaited from Swift Concurrency contexts.
public struct ModelLoader<Source: Sendable> {
    private let source: Source

    private init(source: Source) {
        self.source = source
    }

    /// Creates a loader that will read a 3MF package from a file URL.
    ///
    /// - Parameter url: The URL of the 3MF package to load.
    public init(url: URL) where Source == URL {
        self.init(source: url)
    }

    /// Creates a loader that will read a 3MF package from in‑memory data.
    ///
    /// - Parameter data: The 3MF package data to load.
    public init(data: Data) where Source == Data {
        self.init(source: data)
    }

    /// Loads the 3MF package, resolves referenced models and objects, and returns a flattened representation.
    ///
    /// The returned `LoadedModel` contains:
    /// - The parsed root model
    /// - All referenced models (ordered)
    /// - A deduplicated list of meshes with stable indices
    /// - Each build item expanded into concrete components referencing mesh indices with accumulated transforms and metadata
    ///
    /// - Returns: A `LoadedModel` ready for rendering or further processing.
    /// - Throws: `LoadingError` if referenced models or objects cannot be found, or other errors encountered while reading the package.
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
    /// Errors that can occur while loading and resolving a 3MF package.
    enum LoadingError: Error {
        /// A referenced model file could not be found in the package.
        /// - Parameter path: The path of the missing model file.
        case modelNotFoundInArchive (path: URL)

        /// An object reference could not be resolved in the specified model.
        /// - Parameters:
        ///   - modelPath: The model file containing the expected object, or `nil` for the root model.
        ///   - _: The identifier of the missing object.
        case objectNotFound (modelPath: URL?, ResourceID)
    }

    /// A flattened, render‑ready representation of a 3MF package after loading and resolution.
    ///
    /// LoadedModel contains:
    /// - The root model that initiated loading
    /// - All additional models that were referenced
    /// - A deduplicated array of meshes with stable indices
    /// - Items expanded into components that reference meshes and carry transforms and properties
    struct LoadedModel: Sendable {
        /// The parsed root model.
        public let rootModel: Model

        /// The set of referenced models, ordered to align with `LoadedMesh.modelIndex`.
        ///
        /// Note: The root model is not included here; it is available via `rootModel`.
        public let models: [Model]

        /// The deduplicated meshes referenced by items/components.
        ///
        /// Each mesh has a stable `modelIndex` that points back to an entry in `models`.
        public let meshes: [LoadedMesh]

        /// The build items from the root model, expanded into concrete components referencing meshes.
        public let items: [LoadedItem]

        /// A mesh paired with the index of the model it came from.
        public struct LoadedMesh: Sendable {
            /// The mesh geometry.
            public let mesh: Mesh

            /// The index of the model in `LoadedModel.models` that contains this mesh.
            public let modelIndex: Int
        }

        /// An item from the root model with its resolved components.
        public struct LoadedItem: Sendable {
            /// The original item from the root model's build.
            public let item: Item

            /// The object referenced by `item`, as defined in the corresponding model.
            public let rootObject: Object

            /// The concrete components of this item, each referencing a mesh and carrying transforms and metadata.
            public let components: [LoadedComponent]
        }

        /// A concrete component that references a mesh and carries transforms, properties, and metadata.
        public struct LoadedComponent: Sendable {
            /// The index into `LoadedModel.meshes` for the referenced mesh.
            public let meshIndex: Int

            /// The transforms to apply to the mesh, in order from parent to child.
            public let transforms: [Matrix3D]

            /// The property group identifier, if any, associated with this component.
            public let propertyGroupID: ResourceID?

            /// The property index within the property group, if any.
            public let propertyIndex: ResourceIndex?

            /// The accumulated names along the reference path, from parent to child.
            public var names: [String]

            /// The accumulated part numbers along the reference path, from parent to child.
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
