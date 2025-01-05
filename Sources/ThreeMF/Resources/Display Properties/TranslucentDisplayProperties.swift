import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:translucentdisplayproperties
public struct TranslucentDisplayProperties: Resource, XMLConvertibleNamed {
    static let elementName = "m:translucentdisplayproperties"

    public var id: ResourceID
    public var translucents: [Translucent]
}

extension TranslucentDisplayProperties: XMLConvertible {
    var xmlElement: XMLElement {
        XMLElement("m:translucentdisplayproperties", [
            "id": String(id),
        ], children: translucents)
    }
    
    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement["id"]
        translucents = try xmlElement[elements: "m:translucent"]
    }
}

// m:translucent
public struct Translucent {
    public var name: String
    public var attenuation: [Double]
    public var refractiveIndices: [Double]
    public var roughness: Double?
}

extension Translucent: XMLConvertible {
    var xmlElement: XMLElement {
        XMLElement("m:translucent", [
            "name": name,
            "attenuation": attenuation.string,
            "refractiveindex": refractiveIndices.string,
            "roughness": roughness.map { String($0) }
        ])
    }
    
    init(xmlElement: XMLElement) throws(Error) {
        name = try xmlElement["name"]
        attenuation = try xmlElement["attenuation"]
        refractiveIndices = try xmlElement["refractiveindex"]
        roughness = try? xmlElement["roughness"]
    }
}
