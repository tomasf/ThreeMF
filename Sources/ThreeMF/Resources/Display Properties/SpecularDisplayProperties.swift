import Foundation
import Nodal

// m:pbspeculardisplayproperties
public struct SpecularDisplayProperties: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.specularDisplayProperties

    public var id: ResourceID
    public var speculars: [Specular]

    public init(id: ResourceID, speculars: [Specular] = []) {
        self.id = id
        self.speculars = speculars
    }

    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.encode(speculars, elementName: Materials.specular)
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        speculars = try element.decode(elementName: Materials.specular)
    }
}

public extension SpecularDisplayProperties {
    @discardableResult
    mutating func addSpecular(_ specular: Specular) -> ResourceIndex {
        speculars.append(specular)
        return speculars.endIndex - 1
    }
}

// m:pbspecular
public struct Specular: Hashable, Sendable, XMLElementCodable {
    public var name: String
    public var specularColor: Color?
    public var glossiness: Double?

    public init(name: String, specularColor: Color? = nil, glossiness: Double? = nil) {
        self.name = name
        self.specularColor = specularColor
        self.glossiness = glossiness
    }

    public func encode(to element: Node) {
        element.setValue(name, forAttribute: .name)
        element.setValue(specularColor, forAttribute: .specularColor)
        element.setValue(glossiness, forAttribute: .glossiness)
    }

    public init(from element: Node) throws {
        name = try element.value(forAttribute: .name)
        specularColor = try element.value(forAttribute: .specularColor)
        glossiness = try element.value(forAttribute: .glossiness)
    }
}

public extension Specular {
    var effectiveValues: (specularColor: Color, glossiness: Double) {
        (specularColor ?? .init(red: 0x38, green: 0x38, blue: 0x38), glossiness ?? 0)
    }
}
