import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:pbspeculartexturedisplayproperties
public struct SpecularTextureDisplayProperties: Resource, XMLConvertibleNamed {
    static let elementName = "m:pbspeculartexturedisplayproperties"

    public var id: ResourceID
    public var name: String
    public var specularTextureID: ResourceID
    public var glossinessTextureID: ResourceID
    public var diffuseFactor: Color?
    public var specularFactor: Color?
    public var glossinessFactor: Double?
}

public extension SpecularTextureDisplayProperties {
    var effectiveFactors: (diffuseFactor: Color, specularFactor: Color, glossinessFactor: Double) {
        (diffuseFactor ?? .white, specularFactor ?? .white, glossinessFactor ?? 1)
    }
}

internal extension SpecularTextureDisplayProperties {
    var xmlElement: XMLElement {
        XMLElement("m:pbspeculartexturedisplayproperties", [
            "id": String(id),
            "name": name,
            "speculartextureid": String(specularTextureID),
            "glossinesstextureid": String(glossinessTextureID),
            "diffusefactor": diffuseFactor?.string,
            "specularfactor": specularFactor?.string,
            "glossinessfactor": glossinessFactor.map { String($0) }
        ])
    }
    
    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement["id"]
        name = try xmlElement["name"]
        specularTextureID = try xmlElement["speculartextureid"]
        glossinessTextureID = try xmlElement["glossinesstextureid"]
        diffuseFactor = try? xmlElement["diffusefactor"]
        specularFactor = try? xmlElement["specularfactor"]
        glossinessFactor = try? xmlElement["glossinessfactor"]
    }
}
