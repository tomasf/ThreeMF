import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

internal struct Materials: NamespaceSpecification {
    static let namespace = Namespace.materials

    // Elements
    static let metallicDisplayProperties = element("pbmetallicdisplayproperties")
    static let metallic = element("pbmetallic")
    static let metallicTexturedDisplayProperties = element("pbmetallictexturedisplayproperties")
    static let specularDisplayProperties = element("pbspeculardisplayproperties")
    static let specular = element("pbspecular")
    static let specularTextureDisplayProperties = element("pbspeculartexturedisplayproperties")
    static let translucentDisplayProperties = element("translucentdisplayproperties")
    static let translucent = element("translucent")

    static let color = element("color")
    static let colorGroup = element("colorgroup")
    static let compositeMaterials = element("compositematerials")
    static let composite = element("composite")
    static let multiproperties = element("multiproperties")
    static let multi = element("multi")
    static let texture2D = element("texture2d")
    static let texture2DGroup = element("texture2dgroup")
    static let tex2Coord = element("text2coord")

    // Attributes
    static let id = attribute("id")
    static let name = attribute("name")
    static let displayPropertiesID = attribute("displaypropertiesid")
    static let values = attribute("values")
    static let path = attribute("path")
    static let contentType = attribute("contenttype")
    static let colorAttribute = attribute("color")

    static let matID = attribute("matid")
    static let matIndices = attribute("matindices")
    static let pids = attribute("pids")
    static let pIndices = attribute("pindices")
    static let blendMethods = attribute("blendmethods")
    static let filter = attribute("filter")
    static let texID = attribute("texid")
    static let u = attribute("u")
    static let v = attribute("v")

    static let tileStyleU = attribute("tilestyleu")
    static let tileStyleV = attribute("tilestylev")

    static let metallicness = attribute("metallicness")
    static let roughness = attribute("roughness")

    static let metallicTextureID = attribute("metallictextureid")
    static let roughnessTextureID = attribute("roughnesstextureid")
    static let baseColorFactor = attribute("basecolorfactor")
    static let metallicFactor = attribute("metallicfactor")
    static let roughnessFactor = attribute("roughnessfactor")

    static let specularColor = attribute("specularcolor")
    static let glossiness = attribute("glossiness")

    static let specularTextureID = attribute("speculartextureid")
    static let glossinessTextureID = attribute("glossinesstextureid")
    static let diffuseFactor = attribute("diffusefactor")
    static let specularFactor = attribute("specularfactor")
    static let glossinessFactor = attribute("glossinessfactor")

    static let attenuation = attribute("attenuation")
    static let refractiveIndex = attribute("refractiveindex")
}

extension AttributeIdentifier {
    static let m = Materials.self
}

extension ElementIdentifier {
    static let m = Materials.self
}
