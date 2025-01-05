import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:pbmetallictexturedisplayproperties
public struct MetallicTextureDisplayProperties: Resource, XMLConvertibleNamed {
    static let elementName = "m:pbmetallictexturedisplayproperties"

    public var id: ResourceID
    public var name: String
    public var metallicTextureID: ResourceID
    public var roughnessTextureID: ResourceID
    public var baseColorFactor: Color?
    public var metallicFactor: Double?
    public var roughnessFactor: Double?
}

public extension MetallicTextureDisplayProperties {
    var effectiveFactors: (baseColorFactor: Color, metallicFactor: Double, roughnessFactor: Double) {
        (baseColorFactor ?? .white, metallicFactor ?? 1, roughnessFactor ?? 1)
    }
}

internal extension MetallicTextureDisplayProperties {
    var xmlElement: XMLElement {
        XMLElement("m:pbmetallictexturedisplayproperties", [
            "id": String(id),
            "name": name,
            "metallictextureid": String(metallicTextureID),
            "roughnesstextureid": String(roughnessTextureID),
            "basecolorfactor": baseColorFactor?.string,
            "metallicfactor": metallicFactor.map { String($0) },
            "roughnessfactor": roughnessFactor.map { String($0) }
        ])
    }
    
    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement["id"]
        name = try xmlElement["name"]
        metallicTextureID = try xmlElement["metallictextureid"]
        roughnessTextureID = try xmlElement["roughnesstextureid"]
        baseColorFactor = try? xmlElement["basecolorfactor"]
        metallicFactor = try? xmlElement["metallicfactor"]
        roughnessFactor = try? xmlElement["roughnessfactor"]
    }
}
