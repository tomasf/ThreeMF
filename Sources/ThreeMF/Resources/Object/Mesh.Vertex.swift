import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public extension Mesh {
    struct Vertex: Hashable {
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

extension Mesh.Vertex: XMLConvertible {
    var xmlElement: XMLElement {
        XMLElement("vertex", [
            "x": String(x),
            "y": String(y),
            "z": String(z)
        ])
    }

    init(xmlElement: XMLElement) throws(Error) {
        x = try xmlElement["x"]
        y = try xmlElement["y"]
        z = try xmlElement["z"]
    }
}

internal extension [Mesh.Vertex] {
    var xmlElement: XMLElement {
        XMLElement("vertices", children: map(\.xmlElement))
    }

    init(xmlElement: XMLElement) throws(Error) {
        self = try xmlElement[elements: "vertex"]
    }
}
