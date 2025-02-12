import Foundation
import Nodal

public struct Mesh {
    public var vertices: [Vertex]
    public var triangles: [Triangle]
    public var triangleSets: [TriangleSet]

    public init(vertices: [Vertex], triangles: [Triangle], triangleSets: [TriangleSet] = []) {
        self.vertices = vertices
        self.triangles = triangles
        self.triangleSets = triangleSets
    }
}

extension Mesh: XMLElementComposable {
    static let elementIdentifier = Core.mesh

    var children: [(any XMLConvertible)?] {
        [
            triangles.wrapped(in: Core.triangles),
            vertices.wrapped(in: Core.vertices),
            triangleSets.wrappedNonEmpty(in: .t.triangleSets)
        ]
    }

    init(xmlElement: Node) throws(Error) {
        triangles = try xmlElement[Core.triangles][Core.triangle]
        vertices = try xmlElement[Core.vertices][Core.vertex]
        triangleSets = (try? xmlElement[.t.triangleSets][.t.triangleSet]) ?? []
    }
}
