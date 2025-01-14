import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// basematerials
public struct BaseMaterialGroup: Resource {
    public var id: ResourceID
    public var displayPropertiesID: ResourceID? // Points to a <displayproperties>
    public var properties: [BaseMaterial]

    public init(id: ResourceID, displayPropertiesID: ResourceID? = nil, properties: [BaseMaterial]) {
        self.id = id
        self.displayPropertiesID = displayPropertiesID
        self.properties = properties
    }
}

extension BaseMaterialGroup: XMLElementComposable {
    static let elementIdentifier = Core.baseMaterials

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            Core.id: id,
            .m.displayPropertiesID: displayPropertiesID
        ]
    }

    var children: [(any XMLConvertible)?] { properties }

    public init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement[Core.id]
        displayPropertiesID = try? xmlElement[.m.displayPropertiesID]
        properties = try xmlElement[Core.base]
    }
}

// base
public struct BaseMaterial {
    public let name: String
    public let displayColor: Color

    public init(name: String, displayColor: Color) {
        self.name = name
        self.displayColor = displayColor
    }
}

extension BaseMaterial: XMLElementComposable {
    static let elementIdentifier = Core.base

    var attributes: [AttributeIdentifier : (any XMLStringConvertible)?] {
        [
            Core.name: name,
            Core.displayColor: displayColor
        ]
    }

    init(xmlElement: XMLElement) throws(Error) {
        name = try xmlElement[Core.name]
        displayColor = try xmlElement[Core.displayColor]
    }
}
