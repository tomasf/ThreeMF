import Testing
import Foundation
import Nodal

// Deliberately a plain import rather than `@testable`, so this file sees the package exactly as a
// client does. Every symbol below is reachable from the public API; if one of them loses its
// `public` again, this file stops compiling.
import ThreeMF

struct PublicAPIAccessTests {
    @Test func `a multiproperties layer reports the property it takes and how it blends`() throws {
        let multiproperties = Multiproperties(
            id: 3,
            propertyGroupIDs: [1, 2],
            blendMethods: [.multiply],
            multis: [[0, 1]]
        )

        let layers = try #require(multiproperties.layerSequences.first)
        #expect(layers.count == 2)

        #expect(layers[0].property == PropertyReference(groupID: 1, index: 0))
        #expect(layers[1].property == PropertyReference(groupID: 2, index: 1))
        #expect(layers[1].blendMethod == .multiply)
    }

    @Test func `an object's type falls back to the documented default`() {
        let object = Object(id: 1, content: .mesh(Mesh(vertices: [], triangles: [])))

        // The file said nothing, which per the spec means `.model`.
        #expect(object.type == nil)
        #expect(object.type ?? .default == .model)
    }

    @Test func `a triangle set can be built and handed to a mesh`() {
        let set = Mesh.TriangleSet(name: "Top", identifier: "top", triangleIndices: IndexSet(0..<2))
        let mesh = Mesh(vertices: [], triangles: [], triangleSets: [set])

        #expect(mesh.triangleSets.count == 1)
        #expect(mesh.triangleSets[0].name == "Top")
        #expect(mesh.triangleSets[0].identifier == "top")
        #expect(mesh.triangleSets[0].triangleIndices == IndexSet(0..<2))
    }

    @Test func `texture coordinates can be built and handed to a group`() {
        let group = Texture2DGroup(id: 2, texture2DID: 1, coordinates: [
            Texture2DGroup.Coordinate(u: 0, v: 0),
            Texture2DGroup.Coordinate(u: 1, v: 0.5),
        ])

        #expect(group.coordinates.count == 2)
        #expect(group.coordinates[1].u == 1)
        #expect(group.coordinates[1].v == 0.5)
    }

    @Test func `an alternative can be built and handed to an object`() {
        let uuid = UUID()
        let alternative = Alternative(objectID: 7, uuid: uuid, modelResolution: .low)
        let object = Object(
            id: 1,
            alternatives: [alternative],
            content: .mesh(Mesh(vertices: [], triangles: []))
        )

        #expect(object.alternatives.count == 1)
        #expect(object.alternatives[0].objectID == 7)
        #expect(object.alternatives[0].uuid == uuid)
        #expect(object.alternatives[0].modelResolution == .low)
    }
}
