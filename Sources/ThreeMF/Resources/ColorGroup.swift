import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:colorgroup
public struct ColorGroup: Resource, XMLConvertibleNamed {
    static let elementName = "m:colorgroup"
    
    public var id: ResourceID
    public var displayPropertiesID: ResourceID?
    public var colors: [Color]

    public init(id: ResourceID, displayPropertiesID: ResourceID? = nil, colors: [Color]) {
        self.id = id
        self.displayPropertiesID = displayPropertiesID
        self.colors = colors
    }
}

extension ColorGroup {
    var xmlElement: XMLElement {
        XMLElement("m:colorgroup", [
            "id": String(id),
            "displaypropertiesid": displayPropertiesID.map(String.init)
        ], children: colors.map(\.xmlElement))
    }

    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement["id"]
        displayPropertiesID = try? xmlElement["displaypropertiesid"]
        colors = try xmlElement[elements: "m:color"]
    }
}
