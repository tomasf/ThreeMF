import Foundation
import Nodal

internal struct Materials: NamespaceSpecification {
    static let namespace = Namespace.materials

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
}
