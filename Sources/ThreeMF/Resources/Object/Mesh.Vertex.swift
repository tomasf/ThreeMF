import Foundation
import Nodal

public extension Mesh {
    @XMLCodable
    struct Vertex: Hashable {
        @Attribute(.x) public let x: Double
        @Attribute(.y) public let y: Double
        @Attribute(.z) public let z: Double

        public init(x: Double, y: Double, z: Double) {
            self.x = x
            self.y = y
            self.z = z
        }
    }
}

public extension Mesh.Vertex {
    var elementName: ExpandedName { Core.vertex }
}
