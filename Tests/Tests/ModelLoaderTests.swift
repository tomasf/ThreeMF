import Testing
import Foundation
@testable import ThreeMF

struct ModelLoaderTests {
    private func translation(_ x: Double, _ y: Double, _ z: Double) -> Matrix3D {
        Matrix3D(values: [[1, 0, 0], [0, 1, 0], [0, 0, 1], [x, y, z]])
    }

    private func loadedModel(from model: Model) async throws -> ModelLoader<Data>.LoadedModel {
        let writer = PackageWriter<Data>()
        writer.model = model
        let data = try await writer.finalize()
        return try await ModelLoader<Data>(data: data).load()
    }

    @Test func `flat item with no components resolves directly to its mesh`() async throws {
        var model = Model()
        model.resources.resources = [meshObject(id: 1, name: "Leaf", partNumber: "PN-Leaf")]
        model.build.items = [Item(objectID: 1)]

        let loaded = try await loadedModel(from: model)
        #expect(loaded.meshes.count == 1)
        #expect(loaded.items.count == 1)

        let component = loaded.items[0].components[0]
        #expect(component.transforms.isEmpty)
        #expect(component.names == ["Leaf"])
        #expect(component.partNumbers == ["PN-Leaf"])
        #expect(loaded.meshes[component.meshIndex].mesh.vertices.count == 3)
    }

    @Test func `single level of components accumulates transforms in parent-to-child order`() async throws {
        var model = Model()
        model.resources.resources = [
            meshObject(id: 1, name: "Leaf"),
            componentsObject(id: 2, name: "Container", [Component(objectID: 1, transform: translation(1, 0, 0))]),
        ]
        model.build.items = [Item(objectID: 2, transform: translation(0, 10, 0))]

        let loaded = try await loadedModel(from: model)
        let component = loaded.items[0].components[0]
        #expect(component.transforms.map(\.values) == [translation(0, 10, 0).values, translation(1, 0, 0).values])
        #expect(component.names == ["Container", "Leaf"])
    }

    @Test func `three levels of nested components accumulate everything in root-to-leaf order`() async throws {
        var model = Model()
        model.resources.resources = [
            meshObject(id: 1, name: "Leaf", partNumber: "PN-Leaf"),
            componentsObject(id: 2, name: "Middle", [Component(objectID: 1, transform: translation(0, 0, 1))]),
            Object(id: 3, partNumber: "PN-Top", name: "Top", content: .components([Component(objectID: 2, transform: translation(0, 1, 0))])),
        ]
        model.build.items = [Item(objectID: 3, transform: translation(1, 0, 0))]

        let loaded = try await loadedModel(from: model)
        let component = loaded.items[0].components[0]
        #expect(component.transforms.map(\.values) == [
            translation(1, 0, 0).values,
            translation(0, 1, 0).values,
            translation(0, 0, 1).values,
        ])
        #expect(component.names == ["Top", "Middle", "Leaf"])
        #expect(component.partNumbers == ["PN-Top", "PN-Leaf"])
    }

    @Test func `the same mesh referenced from two items is deduplicated`() async throws {
        var model = Model()
        model.resources.resources = [meshObject(id: 1, name: "Shared")]
        model.build.items = [Item(objectID: 1), Item(objectID: 1, transform: translation(5, 0, 0))]

        let loaded = try await loadedModel(from: model)
        #expect(loaded.meshes.count == 1)
        let meshIndices = Set(loaded.items.flatMap { $0.components.map(\.meshIndex) })
        #expect(meshIndices == [0])
    }

    @Test func `propertyGroupID and propertyIndex are inherited from an ancestor when not overridden`() async throws {
        var model = Model()
        model.resources.resources = [
            meshObject(id: 1),
            Object(id: 2, propertyGroupID: 100, propertyIndex: 5, content: .components([Component(objectID: 1)])),
        ]
        model.build.items = [Item(objectID: 2)]

        let loaded = try await loadedModel(from: model)
        let component = loaded.items[0].components[0]
        #expect(component.propertyGroupID == 100)
        #expect(component.propertyIndex == 5)
    }

    @Test func `a child's own propertyGroupID and propertyIndex override an inherited one`() async throws {
        var model = Model()
        model.resources.resources = [
            meshObject(id: 1, pid: 200, pIndex: 9),
            Object(id: 2, propertyGroupID: 100, propertyIndex: 5, content: .components([Component(objectID: 1)])),
        ]
        model.build.items = [Item(objectID: 2)]

        let loaded = try await loadedModel(from: model)
        let component = loaded.items[0].components[0]
        #expect(component.propertyGroupID == 200)
        #expect(component.propertyIndex == 9)
    }

    @Test func `build items can reference objects defined in an additional model`() async throws {
        var additionalModel = Model()
        additionalModel.resources.resources = [meshObject(id: 1, name: "External")]

        let writer = PackageWriter<Data>()
        let additionalURL = try writer.addAdditionalModel(additionalModel, named: "extra")
        writer.model = Model(build: Build(items: [Item(objectID: 1, path: additionalURL)]))
        let data = try await writer.finalize()

        let loaded = try await ModelLoader<Data>(data: data).load()
        #expect(loaded.models.count == 1)
        #expect(loaded.meshes.first?.modelIndex == 0)
        #expect(loaded.items.first?.rootObject.id == 1)
        #expect(loaded.items.first?.rootObject.name == "External")
    }

    @Test func `an inherited property doesn't follow a component into another model file`() async throws {
        // A property group id names a resource of the file it's written in, so a parent's id means
        // nothing in the file a component's path points to. The child there gets no property
        // rather than whichever unrelated resource happens to share the id.
        var additionalModel = Model()
        additionalModel.resources.resources = [meshObject(id: 1)]

        let writer = PackageWriter<Data>()
        let additionalURL = try writer.addAdditionalModel(additionalModel, named: "extra")
        var rootModel = Model()
        rootModel.resources.resources = [
            Object(id: 2, propertyGroupID: 100, propertyIndex: 5, content: .components([Component(objectID: 1, path: additionalURL)])),
        ]
        rootModel.build.items = [Item(objectID: 2)]
        writer.model = rootModel
        let data = try await writer.finalize()

        let loaded = try await ModelLoader<Data>(data: data).load()
        let component = loaded.items[0].components[0]
        #expect(component.propertyGroupID == nil)
        #expect(component.propertyIndex == nil)
    }

    @Test func `a component without a path refers to its own model file, not the root`() async throws {
        // The production extension lets only the root file's components name a path; the rest
        // reference objects in the file they're written in.
        var additionalModel = Model()
        additionalModel.resources.resources = [
            meshObject(id: 1, name: "External leaf"),
            componentsObject(id: 2, name: "External container", [Component(objectID: 1)]),
        ]

        let writer = PackageWriter<Data>()
        let additionalURL = try writer.addAdditionalModel(additionalModel, named: "extra")
        writer.model = Model(build: Build(items: [Item(objectID: 2, path: additionalURL)]))
        let data = try await writer.finalize()

        let loaded = try await ModelLoader<Data>(data: data).load()
        let component = loaded.items[0].components[0]
        #expect(component.names == ["External container", "External leaf"])
        #expect(loaded.meshes[component.meshIndex].mesh.vertices.count == 3)
    }

    @Test func `components with mixed mesh and nested-components siblings both resolve`() async throws {
        var model = Model()
        model.resources.resources = [
            meshObject(id: 1, name: "LeafA"),
            meshObject(id: 2, name: "LeafB"),
            componentsObject(id: 3, name: "Nested", [Component(objectID: 2)]),
            componentsObject(id: 4, name: "Top", [Component(objectID: 1), Component(objectID: 3)]),
        ]
        model.build.items = [Item(objectID: 4)]

        let loaded = try await loadedModel(from: model)
        #expect(loaded.meshes.count == 2)
        #expect(loaded.items[0].components.count == 2)
        let leafNames = Set(loaded.items[0].components.map(\.names.last))
        #expect(leafNames == ["LeafA", "LeafB"])
    }

    @Test func `missing object in the root model throws objectNotFound with a nil modelPath`() async throws {
        var model = Model()
        model.build.items = [Item(objectID: 999)]

        let writer = PackageWriter<Data>()
        writer.model = model
        let data = try await writer.finalize()

        await #expect {
            _ = try await ModelLoader<Data>(data: data).load()
        } throws: { error in
            guard case ModelLoader<Data>.LoadingError.objectNotFound(let modelPath, let objectID) = error else { return false }
            return modelPath == nil && objectID == 999
        }
    }

    @Test func `missing object in an additional model throws objectNotFound with that model's path`() async throws {
        let writer = PackageWriter<Data>()
        let additionalURL = try writer.addAdditionalModel(Model(), named: "extra")
        writer.model = Model(build: Build(items: [Item(objectID: 1, path: additionalURL)]))
        let data = try await writer.finalize()

        await #expect {
            _ = try await ModelLoader<Data>(data: data).load()
        } throws: { error in
            guard case ModelLoader<Data>.LoadingError.objectNotFound(let modelPath, let objectID) = error else { return false }
            return modelPath == additionalURL && objectID == 1
        }
    }

    @Test func `a dangling model path throws modelNotFoundInArchive`() async throws {
        var model = Model()
        model.build.items = [Item(objectID: 1, path: URL(string: "/3D/nonexistent.model")!)]

        let writer = PackageWriter<Data>()
        writer.model = model
        let data = try await writer.finalize()

        await #expect {
            _ = try await ModelLoader<Data>(data: data).load()
        } throws: { error in
            guard case ModelLoader<Data>.LoadingError.modelNotFoundInArchive(let path) = error else { return false }
            return path == URL(string: "/3D/nonexistent.model")!
        }
    }
}
