import Foundation
import Nodal

// m:translucentdisplayproperties
public struct TranslucentDisplayProperties: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.translucentDisplayProperties

    public var id: ResourceID
    public var translucents: [Translucent]

    public init(id: ResourceID, translucents: [Translucent]) {
        self.id = id
        self.translucents = translucents
    }

    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.encode(translucents, elementName: Materials.translucent)
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        translucents = try element.decode(elementName: Materials.translucent)
    }
}


// m:translucent
public struct Translucent: XMLElementCodable {
    public var name: String
    public var attenuation: [Double]
    public var refractiveIndices: [Double]
    public var roughness: Double?

    public init(name: String, attenuation: [Double], refractiveIndices: [Double], roughness: Double? = nil) {
        self.name = name
        self.attenuation = attenuation
        self.refractiveIndices = refractiveIndices
        self.roughness = roughness
    }

    public func encode(to element: Node) {
        element.setValue(name, forAttribute: .name)
        element.setValue(attenuation, forAttribute: .attenuation)
        element.setValue(refractiveIndices, forAttribute: .refractiveIndex)
        element.setValue(roughness, forAttribute: .roughness)
    }

    public init(from element: Node) throws {
        name = try element.value(forAttribute: .name)
        attenuation = try element.value(forAttribute: .attenuation)
        refractiveIndices = try element.value(forAttribute: .refractiveIndex)
        roughness = try element.value(forAttribute: .roughness)
    }
}
