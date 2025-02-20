import Foundation
import Nodal

// m:pbspeculardisplayproperties
@XMLCodable
public struct SpecularDisplayProperties: Resource {
    static public let elementName: ExpandedName = Materials.specularDisplayProperties

    @Attribute(.id) public var id: ResourceID
    @Element(Materials.specular) public var speculars: [Specular]

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

// m:pbspecular
@XMLCodable
public struct Specular: Hashable {
    @Attribute(.name) public var name: String
    @Attribute(.specularColor) public var specularColor: Color?
    @Attribute(.glossiness) public var glossiness: Double?

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
