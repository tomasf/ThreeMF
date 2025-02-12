import Foundation
import Nodal

// m:translucentdisplayproperties
public struct TranslucentDisplayProperties: Resource {
    public var id: ResourceID
    public var translucents: [Translucent]

    public init(id: ResourceID, translucents: [Translucent]) {
        self.id = id
        self.translucents = translucents
    }
}

extension TranslucentDisplayProperties: XMLElementComposable {
    static let elementIdentifier = Materials.translucentDisplayProperties

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [.m.id: id]
    }

    var children: [(any XMLConvertible)?] {
        translucents
    }

    init(xmlElement: Node) throws(Error) {
        id = try xmlElement[.m.id]
        translucents = try xmlElement[.m.translucent]
    }
}

// m:translucent
public struct Translucent {
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
}

extension Translucent: XMLElementComposable {
    static let elementIdentifier = Materials.translucent

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            .m.name: name,
            .m.attenuation: attenuation.string,
            .m.refractiveIndex: refractiveIndices.string,
            .m.roughness: roughness
        ]
    }
    
    init(xmlElement: Node) throws(Error) {
        name = try xmlElement[.m.name]
        attenuation = try xmlElement[.m.attenuation]
        refractiveIndices = try xmlElement[.m.refractiveIndex]
        roughness = try? xmlElement[.m.roughness]
    }
}
