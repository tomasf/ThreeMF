import Testing
import Foundation
import Nodal
@testable import ThreeMF

struct ObjectTests {
    @Test func `mesh object round trips with every scalar field populated`() throws {
        let object = Object(
            id: 1,
            type: .support,
            thumbnail: URL(string: "/Thumbnails/thumb.png"),
            partNumber: "PN-1",
            name: "My Object",
            uuid: UUID(),
            propertyGroupID: 5,
            propertyIndex: 2,
            metadata: [Metadata(name: .title, value: "A title")],
            content: .mesh(triangleMesh())
        )
        let decoded = try roundTrip(object)
        #expect(decoded.id == 1)
        #expect(decoded.type == .support)
        #expect(decoded.thumbnail == object.thumbnail)
        #expect(decoded.partNumber == "PN-1")
        #expect(decoded.name == "My Object")
        #expect(decoded.uuid == object.uuid)
        #expect(decoded.propertyGroupID == 5)
        #expect(decoded.propertyIndex == 2)
        #expect(decoded.metadata.map(\.value) == ["A title"])
        if case .mesh(let mesh) = decoded.content {
            #expect(mesh.vertices == object.mesh?.vertices)
        } else {
            Issue.record("Expected mesh content")
        }
    }

    @Test func `components object round trips`() throws {
        let object = Object(id: 2, content: .components([
            Component(objectID: 10, transform: nil, path: nil, uuid: nil),
            Component(objectID: 11, transform: nil, path: nil, uuid: nil),
        ]))
        let decoded = try roundTrip(object)
        guard case .components(let components) = decoded.content else {
            Issue.record("Expected components content")
            return
        }
        #expect(components.map(\.objectID) == [10, 11])
    }

    @Test func `missing mesh and components content throws expandedElementMissing`() {
        let document = Document()
        let root = document.makeDocumentElement(name: "object")
        root[attribute: "id"] = "1"

        #expect {
            try Object(from: root)
        } throws: { error in
            guard case XMLElementCodableError.expandedElementMissing(let name) = error else { return false }
            return name == Core.mesh
        }
    }

    @Test(arguments: [
        (Object.ObjectType.model, "model"),
        (.solidSupport, "solidsupport"),
        (.support, "support"),
        (.surface, "surface"),
        (.other, "other"),
    ])
    func `object type round trips through its wire string`(type: Object.ObjectType, wireValue: String) throws {
        let document = Document()
        let root = document.makeDocumentElement(name: "test")
        #expect(type.xmlStringValue(for: root) == wireValue)
        #expect(try roundTrip(type) == type)
    }

    @Test func `default object type is model`() {
        #expect(Object.ObjectType.default == .model)
    }
}

private extension Object {
    var mesh: Mesh? {
        if case .mesh(let mesh) = content { return mesh }
        return nil
    }
}
