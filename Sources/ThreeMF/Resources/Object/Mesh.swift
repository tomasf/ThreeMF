import Foundation
import Nodal

public struct Mesh: Sendable, XMLElementCodable {
    public var vertices: [Vertex]
    public var triangles: [Triangle]
    public var triangleSets: [TriangleSet]

    public init(vertices: [Vertex], triangles: [Triangle], triangleSets: [TriangleSet] = []) {
        self.vertices = vertices
        self.triangles = triangles
        self.triangleSets = triangleSets
    }

    public func encode(to element: Node) {
        // Use qualified names here as an optimization. We're producing output and have full control.
        element.encode(vertices, elementName: Core.vertex.localName, containedIn: Core.vertices)
        element.encode(triangles, elementName: Core.triangle.localName, containedIn: Core.triangles)
        element.encode(triangleSets, elementName: TriangleSets.triangleSet.localName, containedIn: TriangleSets.triangleSets)
    }

    public init(from element: Node) throws {
        vertices = try element.decode(elementName: Core.vertex, containedIn: Core.vertices)
        triangles = try element.decode(elementName: Core.triangle, containedIn: Core.triangles)
        triangleSets = try element.decode(elementName: TriangleSets.triangleSet, containedIn: TriangleSets.triangleSets)
    }
}
