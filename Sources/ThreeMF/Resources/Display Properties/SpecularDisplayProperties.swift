import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:pbspeculardisplayproperties
public struct SpecularDisplayProperties: Resource {
    static let elementIdentifier = Materials.specularDisplayProperties

    public var id: ResourceID
    public var speculars: [Specular]

    public init(id: ResourceID, speculars: [Specular] = []) {
        self.id = id
        self.speculars = speculars
    }
}

public extension SpecularDisplayProperties {
    @discardableResult
    mutating func addSpecular(_ specular: Specular) -> ResourceIndex {
        speculars.append(specular)
        return speculars.endIndex - 1
    }
}

extension SpecularDisplayProperties: XMLElementComposable {
    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [.m.id: id]
    }

    var children: [(any XMLConvertible)?] {
        speculars
    }
    
    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement[.m.id]
        speculars = try xmlElement[.m.specular]
    }
}

// m:pbspecular
public struct Specular: Hashable {
    public var name: String
    public var specularColor: Color?
    public var glossiness: Double?

    public init(name: String, specularColor: Color? = nil, glossiness: Double? = nil) {
        self.name = name
        self.specularColor = specularColor
        self.glossiness = glossiness
    }
}

public extension Specular {
    var effectiveValues: (specularColor: Color, glossiness: Double) {
        (specularColor ?? .init(red: 0x38, green: 0x38, blue: 0x38), glossiness ?? 0)
    }
}

extension Specular: XMLElementComposable {
    static let elementIdentifier = Materials.specular

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            .m.name: name,
            .m.specularColor: specularColor,
            .m.glossiness: glossiness
        ]
    }
    
    init(xmlElement: XMLElement) throws(Error) {
        name = try xmlElement[.m.name]
        specularColor = try? xmlElement[.m.specularColor]
        glossiness = try? xmlElement[.m.glossiness]
    }
}
