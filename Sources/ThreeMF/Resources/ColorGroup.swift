import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:colorgroup
public struct ColorGroup: Resource {    
    public var id: ResourceID
    public var displayPropertiesID: ResourceID?
    public var colors: [Color]

    public init(id: ResourceID, displayPropertiesID: ResourceID? = nil, colors: [Color] = []) {
        self.id = id
        self.displayPropertiesID = displayPropertiesID
        self.colors = colors
    }
}

public extension ColorGroup {
    @discardableResult
    mutating func addColor(_ color: Color) -> ResourceIndex {
        colors.append(color)
        return colors.endIndex - 1
    }
}

extension ColorGroup: XMLElementComposable {
    static let elementIdentifier = Materials.colorGroup

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        let attrs: [AttributeIdentifier: (any XMLStringConvertible)?] = [
            .m.id: id,
            .m.displayPropertiesID: displayPropertiesID
        ]
        return attrs
    }

    var children: [(any XMLConvertible)?] {
        colors
    }

    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement[.m.id]
        displayPropertiesID = try? xmlElement[.m.displayPropertiesID]
        colors = try xmlElement[.m.color]
    }
}
