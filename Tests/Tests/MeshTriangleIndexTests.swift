import Testing
import Nodal
@testable import ThreeMF

struct MeshTriangleIndexTests {
    // Regression test for a bug where per-vertex property indices were read from the wrong
    // attributes (p1 -> p2, p2 -> p3, p3 never read). p1/p2/p3 must be pairwise distinct here:
    // a test using equal or overlapping values would have passed against the buggy code too.
    @Test func `per-vertex triangle with distinct property indices round trips exactly`() throws {
        let triangle = Mesh.Triangle(v1: 0, v2: 1, v3: 2, propertyIndex: .perVertex(10, 20, 30), propertyGroup: nil)
        let decoded = try roundTrip(triangle)
        #expect(decoded.propertyIndex == .perVertex(10, 20, 30))
        #expect(decoded.v1 == 0)
        #expect(decoded.v2 == 1)
        #expect(decoded.v3 == 2)
    }

    @Test func `uniform property index round trips with only p1 on the wire`() throws {
        let triangle = Mesh.Triangle(v1: 0, v2: 1, v3: 2, propertyIndex: .uniform(7), propertyGroup: nil)
        let decoded = try roundTrip(triangle)
        #expect(decoded.propertyIndex == .uniform(7))
    }

    @Test func `nil property index round trips to nil`() throws {
        let triangle = Mesh.Triangle(v1: 0, v2: 1, v3: 2, propertyIndex: nil, propertyGroup: nil)
        let decoded = try roundTrip(triangle)
        #expect(decoded.propertyIndex == nil)
    }

    @Test func `property group round trips independently of property index`() throws {
        let both = try roundTrip(Mesh.Triangle(v1: 0, v2: 1, v3: 2, propertyIndex: .uniform(3), propertyGroup: 9))
        #expect(both.propertyIndex == .uniform(3))
        #expect(both.propertyGroup == 9)

        let onlyGroup = try roundTrip(Mesh.Triangle(v1: 0, v2: 1, v3: 2, propertyIndex: nil, propertyGroup: 9))
        #expect(onlyGroup.propertyIndex == nil)
        #expect(onlyGroup.propertyGroup == 9)

        let neither = try roundTrip(Mesh.Triangle(v1: 0, v2: 1, v3: 2, propertyIndex: nil, propertyGroup: nil))
        #expect(neither.propertyGroup == nil)
    }

    @Test func `indices computed property preserves order`() {
        #expect(Mesh.Triangle.Index.uniform(5).indices == [5, 5, 5])
        #expect(Mesh.Triangle.Index.perVertex(1, 2, 3).indices == [1, 2, 3])
    }

    // Hand-built Node cases bypassing Triangle.encode entirely, to exercise the presence-detection
    // fix directly (Triangle.encode always emits p2+p3 together or neither, so these asymmetric
    // presence cases can only be reached by constructing the XML by hand).

    private func triangleElement(p1: Int? = nil, p2: Int? = nil, p3: Int? = nil) -> Node {
        let document = Document()
        let root = document.makeDocumentElement(name: "triangle")
        root[attribute: "v1"] = "0"
        root[attribute: "v2"] = "1"
        root[attribute: "v3"] = "2"
        if let p1 { root[attribute: "p1"] = String(p1) }
        if let p2 { root[attribute: "p2"] = String(p2) }
        if let p3 { root[attribute: "p3"] = String(p3) }
        return root
    }

    @Test func `only p1 present decodes as uniform`() {
        let index = Mesh.Triangle.Index(from: triangleElement(p1: 5))
        #expect(index == .uniform(5))
    }

    @Test func `p1 and p2 present but not p3 falls back to uniform`() {
        let index = Mesh.Triangle.Index(from: triangleElement(p1: 5, p2: 6))
        #expect(index == .uniform(5))
    }

    @Test func `p1 p2 and p3 all present with distinct values decodes as perVertex`() {
        let index = Mesh.Triangle.Index(from: triangleElement(p1: 11, p2: 22, p3: 33))
        #expect(index == .perVertex(11, 22, 33))
    }

    @Test func `no p1 at all decodes as nil`() {
        let index = Mesh.Triangle.Index(from: triangleElement())
        #expect(index == nil)
    }
}
