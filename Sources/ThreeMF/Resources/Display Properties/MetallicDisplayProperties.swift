import Foundation
import Nodal

// m:pbmetallicdisplayproperties
@XMLCodable
public struct MetallicDisplayProperties: Resource {
    static public let elementName: ExpandedName = Materials.metallicDisplayProperties

    @Attribute(.id) public var id: ResourceID
    @Element(Materials.metallic) public var metallics: [Metallic]

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

// m:pbmetallic
@XMLCodable
public struct Metallic: Hashable {
    @Attribute(.name) public var name: String
    @Attribute(.metallicness) public var metallicness: Double
    @Attribute(.roughness) public var roughness: Double

    public init(name: String, metallicness: Double, roughness: Double) {
        self.name = name
        self.metallicness = metallicness
        self.roughness = roughness
    }
}
