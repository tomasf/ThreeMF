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
        // Use qualified names and concrete loops here as an optimization.
        // We're producing output and have full control, and this is by far
        // the hottest encoding path for typical models.
        if !vertices.isEmpty {
            let container = element.addElement(Core.vertices.localName)
            let elementName = Core.vertex.localName
            for vertex in vertices {
                vertex.encode(to: container.addElement(elementName))
            }
        }
        if !triangles.isEmpty {
            let container = element.addElement(Core.triangles.localName)
            let elementName = Core.triangle.localName
            for triangle in triangles {
                triangle.encode(to: container.addElement(elementName))
            }
        }
        element.encode(triangleSets, elementName: TriangleSets.triangleSet.localName, containedIn: TriangleSets.triangleSets.localName)
    }

    public init(from element: Node) throws {
        vertices = try element.decode(elementName: Core.vertex, containedIn: Core.vertices)
        triangles = try element.decode(elementName: Core.triangle, containedIn: Core.triangles)
        triangleSets = try element.decode(elementName: TriangleSets.triangleSet, containedIn: TriangleSets.triangleSets)
    }
}
