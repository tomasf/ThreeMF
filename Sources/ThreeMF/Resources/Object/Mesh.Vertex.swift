import Foundation
import Nodal

/// A mesh's vertices.
public extension Mesh {
    /// One point in a mesh, in the model's ``Model/unit``.
    struct Vertex: Hashable, Sendable, XMLElementCodable {
        /// The x coordinate.
        public let x: Double

        /// The y coordinate.
        public let y: Double

        /// The z coordinate.
        public let z: Double

        /// Creates a vertex at the given coordinates.
        /// - Parameters:
        ///   - x: The x coordinate.
        ///   - y: The y coordinate.
        ///   - z: The z coordinate.
        public init(x: Double, y: Double, z: Double) {
            self.x = x
            self.y = y
            self.z = z
        }

        public func encode(to element: Node) {
            element.appendValue(x.compactXMLString, forAttribute: "x")
            element.appendValue(y.compactXMLString, forAttribute: "y")
            element.appendValue(z.compactXMLString, forAttribute: "z")
        }

        public init(from element: Node) throws {
            x = try element.value(forAttribute: .x)
            y = try element.value(forAttribute: .y)
            z = try element.value(forAttribute: .z)
        }
    }
}

/// How a vertex is written.
public extension Mesh.Vertex {
    var elementName: ExpandedName { Core.vertex }
}
