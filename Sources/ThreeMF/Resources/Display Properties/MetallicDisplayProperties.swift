import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:pbmetallicdisplayproperties
public struct MetallicDisplayProperties: Resource, XMLElementComposable {
    static let elementIdentifier = Materials.metallicDisplayProperties

    public var id: ResourceID
    public var metallics: [Metallic]

    public init(id: ResourceID, metallics: [Metallic] = []) {
        self.id = id
        self.metallics = metallics
    }
}

public extension MetallicDisplayProperties {
    @discardableResult
    mutating func addMetallic(_ metallic: Metallic) -> ResourceIndex {
        metallics.append(metallic)
        return metallics.endIndex - 1
    }
}

internal extension MetallicDisplayProperties {
    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [.m.id: id]
    }

    var children: [(any XMLConvertible)?] {
        metallics
    }

    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement[.m.id]
        metallics = try xmlElement[.m.metallic]
    }
}

// m:pbmetallic
public struct Metallic: Hashable {
    public var name: String
    public var metallicness: Double
    public var roughness: Double

    public init(name: String, metallicness: Double, roughness: Double) {
        self.name = name
        self.metallicness = metallicness
        self.roughness = roughness
    }
}

extension Metallic: XMLElementComposable {
    static let elementIdentifier = Materials.metallic

    var attributes: [AttributeIdentifier : (any XMLStringConvertible)?] {
        [
            .m.name: name,
            .m.metallicness: metallicness,
            .m.roughness: roughness
        ]
    }

    init(xmlElement: XMLElement) throws(Error) {
        name = try xmlElement[.m.name]
        metallicness = try xmlElement[.m.metallicness]
        roughness = try xmlElement[.m.roughness]
    }
}
