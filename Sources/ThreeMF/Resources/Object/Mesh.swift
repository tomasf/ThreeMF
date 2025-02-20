import Foundation
import Nodal

@XMLCodable
public struct Mesh {
    @Element(Core.vertex, containedIn: Core.vertices)
    public var vertices: [Vertex]

    @Element(Core.triangle, containedIn: Core.triangles)
    public var triangles: [Triangle]

    @Element(TriangleSets.triangleSet, containedIn: TriangleSets.triangleSets)
    public var triangleSets: [TriangleSet]

    public init(vertices: [Vertex], triangles: [Triangle], triangleSets: [TriangleSet] = []) {
        self.vertices = vertices
        self.triangles = triangles
        self.triangleSets = triangleSets
    }
}
