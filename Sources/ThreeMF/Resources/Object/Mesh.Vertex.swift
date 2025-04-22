import Foundation
import Nodal

public extension Mesh {
    struct Vertex: Hashable, Sendable, XMLElementCodable {
        public let x: Double
        public let y: Double
        public let z: Double

        public init(x: Double, y: Double, z: Double) {
            self.x = x
            self.y = y
            self.z = z
        }

        public func encode(to element: Node) {
            element.setValue(x, forAttribute: .x)
            element.setValue(y, forAttribute: .y)
            element.setValue(z, forAttribute: .z)
        }

        public init(from element: Node) throws {
            x = try element.value(forAttribute: .x)
            y = try element.value(forAttribute: .y)
            z = try element.value(forAttribute: .z)
        }
    }
}

public extension Mesh.Vertex {
    var elementName: ExpandedName { Core.vertex }
}
