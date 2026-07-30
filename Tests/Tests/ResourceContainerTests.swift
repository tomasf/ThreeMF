import Testing
import Foundation
import Nodal
@testable import ThreeMF

struct ResourceContainerTests {
    @Test func `container round trips one of every known resource type`() throws {
        let resources: [any Resource] = [
            Object(id: 1, content: .mesh(triangleMesh())),
            ColorGroup(id: 2, colors: [.white]),
            BaseMaterialGroup(id: 3, properties: [BaseMaterial(name: "M", displayColor: .white)]),
            Multiproperties(id: 4, propertyGroupIDs: [2], multis: [[0]]),
            Texture2D(id: 5, pathURL: URL(string: "/Textures/t.png")!, contentType: .png),
            Texture2DGroup(id: 6, texture2DID: 5, coordinates: [Texture2DGroup.Coordinate(u: 0, v: 0)]),
            CompositeMaterialGroup(id: 7, baseMaterialGroupID: 3, baseMaterialIndices: [0], composites: [[1.0]]),
            TranslucentDisplayProperties(id: 8, translucents: []),
            MetallicDisplayProperties(id: 9),
            SpecularDisplayProperties(id: 10),
            SpecularTextureDisplayProperties(id: 11, name: "ST", specularTextureID: 5, glossinessTextureID: 5),
            MetallicTextureDisplayProperties(id: 12, name: "MT", metallicTextureID: 5, roughnessTextureID: 5),
        ]
        let container = ResourceContainer(resources: resources)
        let decoded = try roundTrip(container)
        #expect(decoded.resources.count == resources.count)

        #expect(decoded.resources.first { $0.id == 1 } is Object)
        #expect(decoded.resources.first { $0.id == 2 } is ColorGroup)
        #expect(decoded.resources.first { $0.id == 3 } is BaseMaterialGroup)
        #expect(decoded.resources.first { $0.id == 4 } is Multiproperties)
        #expect(decoded.resources.first { $0.id == 5 } is Texture2D)
        #expect(decoded.resources.first { $0.id == 6 } is Texture2DGroup)
        #expect(decoded.resources.first { $0.id == 7 } is CompositeMaterialGroup)
        #expect(decoded.resources.first { $0.id == 8 } is TranslucentDisplayProperties)
        #expect(decoded.resources.first { $0.id == 9 } is MetallicDisplayProperties)
        #expect(decoded.resources.first { $0.id == 10 } is SpecularDisplayProperties)
        #expect(decoded.resources.first { $0.id == 11 } is SpecularTextureDisplayProperties)
        #expect(decoded.resources.first { $0.id == 12 } is MetallicTextureDisplayProperties)
    }

    @Test func `unknown resource element is silently skipped`() throws {
        let document = Document()
        let root = document.makeDocumentElement(name: "resources", defaultNamespace: Namespace.core.uri)
        ResourceContainer(resources: [componentsObject(id: 1, [])]).encode(to: root)
        root.addElement("somethingunknown")

        let decoded = try ResourceContainer(from: root)
        #expect(decoded.resources.count == 1)
        #expect(decoded.resources.first?.id == 1)
    }

    @Test func `nextFreeResourceID is 1 for an empty container`() {
        #expect(ResourceContainer(resources: []).nextFreeResourceID == 1)
    }

    @Test func `nextFreeResourceID is one more than the highest existing id`() {
        let container = ResourceContainer(resources: [componentsObject(id: 3, []), componentsObject(id: 7, [])])
        #expect(container.nextFreeResourceID == 8)
    }

    @Test func `add(resource:) stores the resource under, and returns, the next free id`() {
        var container = ResourceContainer(resources: [componentsObject(id: 5, [])])
        let assignedID = container.add(resource: componentsObject(id: 999, []))
        #expect(assignedID == 6)
        #expect(container.resources.last?.id == 6)
    }

    @Test func `resource(for:) returns nil for a missing id`() {
        let container = ResourceContainer(resources: [componentsObject(id: 1, [])])
        #expect(container.resource(for: 42) == nil)
    }
}
