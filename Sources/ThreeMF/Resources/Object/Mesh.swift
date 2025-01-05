import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public struct Mesh {
    public var vertices: [Vertex]
    public var triangles: [Triangle]
    public var triangleSets: [TriangleSet]
}

internal extension Mesh {
    var xmlElement: XMLElement {
        XMLElement("mesh", children: [triangles.xmlElement, vertices.xmlElement, triangleSets.xmlElement])
    }

    init(xmlElement: XMLElement) throws(Error) {
        triangles = try .init(xmlElement: xmlElement[element: "triangles"])
        vertices = try .init(xmlElement: xmlElement[element: "vertices"])
        triangleSets = (try? .init(xmlElement: xmlElement[element: "trianglesets"])) ?? []
    }
}

