import Foundation
import Nodal

// m:compositematerials
public struct CompositeMaterialGroup: Resource {
    public var id: ResourceID
    public var baseMaterialGroupID: ResourceID // matid
    public var baseMaterialIndices: ResourceIndices  // Indices inside the material group
    public var displayPropertiesID: ResourceID?  // Points to a <displayproperties>
    public var composites: [Numbers]

    public init(id: ResourceID, baseMaterialGroupID: ResourceID, baseMaterialIndices: ResourceIndices, displayPropertiesID: ResourceID? = nil, composites: [Numbers]) {
        self.id = id
        self.baseMaterialGroupID = baseMaterialGroupID
        self.baseMaterialIndices = baseMaterialIndices
        self.displayPropertiesID = displayPropertiesID
        self.composites = composites
    }
}

extension CompositeMaterialGroup: XMLElementComposable {
    static let elementIdentifier = Materials.compositeMaterials

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            .m.id: id,
            .m.matID: baseMaterialGroupID,
            .m.matIndices: baseMaterialIndices.string,
            .m.displayPropertiesID: displayPropertiesID
        ]
    }

    var children: [(any XMLConvertible)?] {
        composites.map { LiteralElement(name: .m.composite, attributes: [.m.values: $0.string]) }
    }

    init(xmlElement: Node) throws(Error) {
        id = try xmlElement[.m.id]
        baseMaterialGroupID = try xmlElement[.m.matID]
        baseMaterialIndices = try xmlElement[.m.matIndices]
        displayPropertiesID = try? xmlElement[.m.displayPropertiesID]
        composites = try xmlElement[.m.composite].map { n throws(Error) in try n[.m.values] }
    }
}
