import Foundation
import Nodal

// m:translucentdisplayproperties
@XMLCodable
public struct TranslucentDisplayProperties: Resource {
    static public let elementName: ExpandedName = Materials.translucentDisplayProperties

    @Attribute(.id) public var id: ResourceID
    @Element(Materials.translucent) public var translucents: [Translucent]

    public init(id: ResourceID, translucents: [Translucent]) {
        self.id = id
        self.translucents = translucents
    }
}


// m:translucent
@XMLCodable
public struct Translucent {
    @Attribute(.name) public var name: String
    @Attribute(.attenuation) public var attenuation: [Double]
    @Attribute(.refractiveIndex) public var refractiveIndices: [Double]
    @Attribute(.roughness) public var roughness: Double?

    public init(name: String, attenuation: [Double], refractiveIndices: [Double], roughness: Double? = nil) {
        self.name = name
        self.attenuation = attenuation
        self.refractiveIndices = refractiveIndices
        self.roughness = roughness
    }
}
