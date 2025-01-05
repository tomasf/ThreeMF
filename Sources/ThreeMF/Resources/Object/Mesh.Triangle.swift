import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public extension Mesh {
    struct Triangle: Hashable {
        public let v1: ResourceIndex
        public let v2: ResourceIndex
        public let v3: ResourceIndex
        public let property: Property?

        public init(v1: ResourceIndex, v2: ResourceIndex, v3: ResourceIndex, property: Property? = nil) {
            self.v1 = v1
            self.v2 = v2
            self.v3 = v3
            self.property = property
        }
    }
}

extension Mesh.Triangle: XMLConvertible {
    var xmlElement: XMLElement {
        XMLElement("triangle", [
            "v1": String(v1),
            "v2": String(v2),
            "v3": String(v3),
        ] + (property?.xmlAttributes ?? [:]))
    }

    init(xmlElement: XMLElement) throws(Error) {
        v1 = try xmlElement["v1"]
        v2 = try xmlElement["v2"]
        v3 = try xmlElement["v3"]
        property = Property(triangleXMLElement: xmlElement)
    }
}

internal extension [Mesh.Triangle] {
    var xmlElement: XMLElement {
        XMLElement("triangles", children: map(\.xmlElement))
    }

    init(xmlElement: XMLElement) throws(Error) {
        self = try xmlElement[elements: "triangle"]
    }
}
