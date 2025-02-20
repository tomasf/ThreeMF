import Foundation
import Nodal

// m:colorgroup
@XMLCodable
public struct ColorGroup: Resource {    
    static public let elementName: ExpandedName = Materials.colorGroup

    @Attribute(.id) public var id: ResourceID
    @Attribute(.displayPropertiesID) public var displayPropertiesID: ResourceID?
    @Element(Materials.color) public var colors: [ColorItem]

    public init(id: ResourceID, displayPropertiesID: ResourceID? = nil, colors: [Color] = []) {
        self.id = id
        self.displayPropertiesID = displayPropertiesID
        self.colors = colors.map { ColorItem(color: $0) }
    }
}

public extension ColorGroup {
    @discardableResult
    mutating func addColor(_ color: Color) -> ResourceIndex {
        colors.append(ColorItem(color: color))
        return colors.endIndex - 1
    }
}

// m:color
@XMLCodable
public struct ColorItem {
    @Attribute(.color) var color: Color

    init(color: Color) {
        self.color = color
    }
}
