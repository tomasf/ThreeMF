import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public extension Mesh {
    public struct Vertex: Hashable {
        public let x: Double
        public let y: Double
        public let z: Double

        public init(x: Double, y: Double, z: Double) {
            self.x = x
            self.y = y
            self.z = z
        }
    }
}

extension Mesh.Vertex: XMLElementComposable {
    static let elementIdentifier = Core.vertex

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [Core.x: x, Core.y: y, Core.z: z]
    }

    init(xmlElement: XMLElement) throws(Error) {
        x = try xmlElement[Core.x]
        y = try xmlElement[Core.y]
        z = try xmlElement[Core.z]
    }
}
