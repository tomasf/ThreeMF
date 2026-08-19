import Testing
import Foundation
import Nodal
@testable import ThreeMF

struct MeshTests {
    // triangleSets get deeper, dedicated coverage in MeshTriangleSetTests.swift.
    @Test func `mesh with vertices triangles and triangleSets round trips`() throws {
        let mesh = Mesh(
            vertices: [.init(x: 0, y: 0, z: 0), .init(x: 1, y: 0, z: 0), .init(x: 0, y: 1, z: 0)],
            triangles: [.init(v1: 0, v2: 1, v3: 2, propertyIndex: nil)],
            triangleSets: [Mesh.TriangleSet(name: "Set", identifier: "id1", triangleIndices: [0])]
        )
        let decoded = try roundTrip(mesh)
        #expect(decoded.vertices == mesh.vertices)
        #expect(decoded.triangles == mesh.triangles)
        #expect(decoded.triangleSets.map(\.name) == ["Set"])
        #expect(decoded.triangleSets.map(\.identifier) == ["id1"])
        #expect(decoded.triangleSets.map(\.triangleIndices) == [IndexSet([0])])
    }

    // Distinguishes "container element omitted" from "container element present but empty".
    // A round trip alone can't tell these apart, since decoding an absent <vertices> and decoding
    // an empty one both yield an empty array.
    @Test func `empty vertices and triangles produce no container elements`() {
        let mesh = Mesh(vertices: [], triangles: [])
        let document = Document(mesh, elementName: "mesh")
        let root = document.documentElement!
        #expect(root[element: "vertices"] == nil)
        #expect(root[element: "triangles"] == nil)
    }

    @Test func `non-empty vertices and triangles produce container elements`() {
        let mesh = triangleMesh()
        let document = Document(mesh, elementName: "mesh")
        let root = document.documentElement!
        #expect(root[element: "vertices"] != nil)
        #expect(root[element: "triangles"] != nil)
    }

    @Test func `vertex round trips with distinct coordinates`() throws {
        let vertex = Mesh.Vertex(x: 1, y: 2, z: 3)
        let decoded = try roundTrip(vertex)
        #expect(decoded == vertex)
    }

    // compactXMLString (used for vertex coordinates) differs deliberately from Matrix3D's lossy
    // "%g" formatting: whole numbers print without a decimal point, and fractional values keep
    // full round-trip precision via Double.description. Pinning both down separately guards against
    // the two formatting strategies getting mixed up if either is edited later.
    @Test func `whole-number coordinates encode without a decimal point`() {
        let document = Document()
        let root = document.makeDocumentElement(name: "test")
        let vertex = Mesh.Vertex(x: 5, y: -3, z: 0)
        vertex.encode(to: root)
        #expect(root[attribute: "x"] == "5")
        #expect(root[attribute: "y"] == "-3")
        #expect(root[attribute: "z"] == "0")
    }

    @Test func `fractional coordinates keep full precision unlike Matrix3D`() throws {
        let vertex = Mesh.Vertex(x: 1.0 / 3.0, y: 0, z: 0)
        let decoded = try roundTrip(vertex)
        #expect(decoded.x == 1.0 / 3.0)
    }
}
