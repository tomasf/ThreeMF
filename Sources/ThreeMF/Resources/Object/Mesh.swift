import Foundation
import Nodal

/// Triangle geometry: a list of vertices, and triangles indexing into it.
///
/// For a mesh to describe a solid volume it has to be manifold and orientable: every edge shared
/// by exactly two triangles, all wound consistently so their normals point outward.
public struct Mesh: Sendable, XMLElementCodable {
    /// The vertex positions, in the model's ``Model/unit``. Triangles refer to these by index.
    public var vertices: [Vertex]

    /// The triangles, each indexing three of ``vertices``.
    public var triangles: [Triangle]

    /// Named subsets of ``triangles``, from the triangle sets extension.
    public var triangleSets: [TriangleSet]

    /// Creates a mesh.
    /// - Parameters:
    ///   - vertices: The vertex positions.
    ///   - triangles: The triangles, indexing into `vertices`.
    ///   - triangleSets: Named subsets of the triangles.
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
        // Unlike vertices/triangles above, triangleSets belongs to the "t:" (TriangleSets)
        // extension namespace, not the document's default namespace, so it needs the
        // namespace-qualified encode path to come back out through the matching decode lookup.
        element.encode(triangleSets, elementName: TriangleSets.triangleSet, containedIn: TriangleSets.triangleSets)
    }

    public init(from element: Node) throws {
        vertices = try element.decode(elementName: Core.vertex, containedIn: Core.vertices)
        triangles = try element.decode(elementName: Core.triangle, containedIn: Core.triangles)
        triangleSets = try element.decode(elementName: TriangleSets.triangleSet, containedIn: TriangleSets.triangleSets)
    }
}
