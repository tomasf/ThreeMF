import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:pbmetallicdisplayproperties
public struct MetallicDisplayProperties: Resource, XMLConvertibleNamed {
    static let elementName = "m:pbmetallicdisplayproperties"

    public var id: ResourceID
    public var metallics: [Metallic]
}

internal extension MetallicDisplayProperties {
    var xmlElement: XMLElement {
        XMLElement("m:pbmetallicdisplayproperties", [
            "id": String(id)
        ], children: metallics)
    }
    
    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement["id"]
        metallics = try xmlElement[elements: "m:pbmetallic"]
    }
}

// m:pbmetallic
public struct Metallic {
    public var name: String
    public var metallicness: Double
    public var roughness: Double
}

extension Metallic: XMLConvertible {
    var xmlElement: XMLElement {
        XMLElement("m:pbmetallic", [
            "name": name,
            "metallicness": String(metallicness),
            "roughness": String(roughness)
        ])
    }
    
    init(xmlElement: XMLElement) throws(Error) {
        name = try xmlElement["name"]
        metallicness = try xmlElement["metallicness"]
        roughness = try xmlElement["roughness"]
    }
}
