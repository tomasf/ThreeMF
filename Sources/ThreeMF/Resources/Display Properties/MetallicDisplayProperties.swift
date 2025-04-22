import Foundation
import Nodal

// m:pbmetallicdisplayproperties
public struct MetallicDisplayProperties: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.metallicDisplayProperties

    public var id: ResourceID
    public var metallics: [Metallic]

    public init(id: ResourceID, metallics: [Metallic] = []) {
        self.id = id
        self.metallics = metallics
    }

    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.encode(metallics, elementName: Materials.metallic)
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        metallics = try element.decode(elementName: Materials.metallic)
    }
}

public extension MetallicDisplayProperties {
    @discardableResult
    mutating func addMetallic(_ metallic: Metallic) -> ResourceIndex {
        metallics.append(metallic)
        return metallics.endIndex - 1
    }
}

// m:pbmetallic
public struct Metallic: Hashable, Sendable, XMLElementCodable {
    public var name: String
    public var metallicness: Double
    public var roughness: Double

    public init(name: String, metallicness: Double, roughness: Double) {
        self.name = name
        self.metallicness = metallicness
        self.roughness = roughness
    }

    public func encode(to element: Node) {
        element.setValue(name, forAttribute: .name)
        element.setValue(metallicness, forAttribute: .metallicness)
        element.setValue(roughness, forAttribute: .roughness)
    }

    public init(from element: Node) throws {
        name = try element.value(forAttribute: .name)
        metallicness = try element.value(forAttribute: .metallicness)
        roughness = try element.value(forAttribute: .roughness)
    }
}
