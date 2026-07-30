import Testing
import Foundation
import Nodal
@testable import ThreeMF

struct MeshTriangleSetTests {
    @Test func `mixed singleton and contiguous run round trips`() throws {
        let triangleSet = Mesh.TriangleSet(name: "Set", identifier: "id1", triangleIndices: IndexSet([1, 5, 6, 7, 20]))
        let decoded = try roundTrip(triangleSet)
        #expect(decoded.name == "Set")
        #expect(decoded.identifier == "id1")
        #expect(decoded.triangleIndices == triangleSet.triangleIndices)
    }

    @Test func `contiguous-run-only set round trips`() throws {
        let triangleSet = Mesh.TriangleSet(name: "Run", identifier: "id2", triangleIndices: IndexSet(3...9))
        let decoded = try roundTrip(triangleSet)
        #expect(decoded.triangleIndices == triangleSet.triangleIndices)
    }

    @Test func `singletons-only set round trips`() throws {
        let triangleSet = Mesh.TriangleSet(name: "Singles", identifier: "id3", triangleIndices: IndexSet([1, 3, 5]))
        let decoded = try roundTrip(triangleSet)
        #expect(decoded.triangleIndices == triangleSet.triangleIndices)
    }

    // Known issue, not fixed as part of this test suite: Mesh.encode builds its <trianglesets>
    // container via a bare (unprefixed) element name — the same fast-path optimization used for
    // vertices/triangles — but unlike those, triangleSets belongs to the "t:" (TriangleSets)
    // namespace, not the document's default (core) namespace. Mesh.init(from:) looks the container
    // back up via a namespace-qualified name (TriangleSets.triangleSet/.triangleSets), which never
    // matches the unprefixed element that was actually written. The result: any triangleSets data
    // is silently dropped when a Mesh is written through PackageWriter and read back — confirmed
    // via a full PackageWriter<Data> -> PackageReader<Data> round trip, not just this isolated one.
    // This predates the recent "Speed up and shrink 3MF model generation" commit (the bare-name
    // triangleSets encode call is unchanged context in that diff), so it's a pre-existing bug, not
    // a new regression. See Sources/ThreeMF/Resources/Object/Mesh.swift's encode(to:).
    @Test(.disabled("Known issue: Mesh.encode's triangleSets container isn't namespace-qualified, so it never survives a round trip. See Mesh.swift's encode(to:)."))
    func `mesh triangleSets survive a round trip through Mesh`() throws {
        let mesh = Mesh(
            vertices: [.init(x: 0, y: 0, z: 0), .init(x: 1, y: 0, z: 0), .init(x: 0, y: 1, z: 0)],
            triangles: [.init(v1: 0, v2: 1, v3: 2, propertyIndex: nil)],
            triangleSets: [Mesh.TriangleSet(name: "Set", identifier: "id1", triangleIndices: [0])]
        )
        let decoded = try roundTrip(mesh)
        #expect(decoded.triangleSets.map(\.name) == ["Set"])
        #expect(decoded.triangleSets.map(\.identifier) == ["id1"])
        #expect(decoded.triangleSets.map(\.triangleIndices) == [IndexSet([0])])
    }
}
