import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// basematerials
public struct BaseMaterialGroup: Resource, XMLConvertibleNamed {
    static let elementName = "basematerials"

    public var id: ResourceID
    public var displayPropertiesID: ResourceID? // Points to a <displayproperties>
    public var properties: [BaseMaterial]

    public init(id: ResourceID, displayPropertiesID: ResourceID? = nil, properties: [BaseMaterial]) {
        self.id = id
        self.displayPropertiesID = displayPropertiesID
        self.properties = properties
    }
}

extension BaseMaterialGroup {
    public var xmlElement: XMLElement {
        XMLElement("basematerials", [
            "id": String(id),
            "displaypropertiesid": displayPropertiesID.map { String($0) }
        ], children: properties.map(\.xmlElement))
    }

    public init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement["id"]
        displayPropertiesID = try? xmlElement["displaypropertiesid"]
        properties = try xmlElement[elements: "base"]
    }
}

// base
public struct BaseMaterial {
    let name: String
    let displayColor: Color
}

extension BaseMaterial: XMLConvertible {
    var xmlElement: XMLElement {
        XMLElement("base", [
            "name": String(name),
            "displaycolor": displayColor.string
        ])
    }

    init(xmlElement: XMLElement) throws(Error) {
        name = try xmlElement["name"]
        displayColor = try Color(string: try xmlElement["displaycolor"])
    }
}
