import Foundation
import Nodal

internal struct Materials: NamespaceSpecification {
    static let namespace = Namespace.materials

    static let metallicDisplayProperties = elementName("pbmetallicdisplayproperties")
    static let metallic = elementName("pbmetallic")
    static let metallicTexturedDisplayProperties = elementName("pbmetallictexturedisplayproperties")
    static let specularDisplayProperties = elementName("pbspeculardisplayproperties")
    static let specular = elementName("pbspecular")
    static let specularTextureDisplayProperties = elementName("pbspeculartexturedisplayproperties")
    static let translucentDisplayProperties = elementName("translucentdisplayproperties")
    static let translucent = elementName("translucent")

    static let color = elementName("color")
    static let colorGroup = elementName("colorgroup")
    static let compositeMaterials = elementName("compositematerials")
    static let composite = elementName("composite")
    static let multiproperties = elementName("multiproperties")
    static let multi = elementName("multi")
    static let texture2D = elementName("texture2d")
    static let texture2DGroup = elementName("texture2dgroup")
    static let tex2Coord = elementName("text2coord")
}
