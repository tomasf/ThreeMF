import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:pbspeculardisplayproperties
public struct SpecularDisplayProperties: Resource, XMLConvertibleNamed {
    static let elementName = "m:pbspeculardisplayproperties"

    public var id: ResourceID
    public var speculars: [Specular]
}

extension SpecularDisplayProperties: XMLConvertible {
    var xmlElement: XMLElement {
        XMLElement("m:pbspeculardisplayproperties", [
            "id": String(id)
        ], children: speculars)
    }
    
    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement["id"]
        speculars = try xmlElement[elements: "m:pbspecular"]
    }
}

// m:pbspecular
public struct Specular {
    public var name: String
    public var specularColor: Color?
    public var glossiness: Double?
}

public extension Specular {
    var effectiveValues: (specularColor: Color, glossiness: Double) {
        (specularColor ?? .init(red: 0x38, green: 0x38, blue: 0x38), glossiness ?? 0)
    }
}

extension Specular: XMLConvertible {
    var xmlElement: XMLElement {
        XMLElement("m:pbspecular", [
            "name": name,
            "specularcolor": specularColor?.string,
            "glossiness": glossiness.map { String($0) }
        ])
    }
    
    init(xmlElement: XMLElement) throws(Error) {
        name = try xmlElement["name"]
        specularColor = try? xmlElement["specularcolor"]
        glossiness = try? xmlElement["glossiness"]
    }
}
