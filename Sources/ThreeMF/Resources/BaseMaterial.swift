import Foundation
import Nodal

// basematerials
@XMLCodable
public struct BaseMaterialGroup: Resource {
    static public let elementName: ExpandedName = Core.baseMaterials

    @Attribute(.id) public var id: ResourceID
    @Attribute(.displayPropertiesID) public var displayPropertiesID: ResourceID? // Points to a <displayproperties>
    @Element(Core.base) public var properties: [BaseMaterial]

    public init(id: ResourceID, displayPropertiesID: ResourceID? = nil, properties: [BaseMaterial]) {
        self.id = id
        self.displayPropertiesID = displayPropertiesID
        self.properties = properties
    }
}

// base
@XMLCodable
public struct BaseMaterial {
    @Attribute(.name) public let name: String
    @Attribute(.displayColor) public let displayColor: Color

    public init(name: String, displayColor: Color) {
        self.name = name
        self.displayColor = displayColor
    }
}
