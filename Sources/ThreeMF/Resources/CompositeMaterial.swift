import Foundation
import Nodal

// m:compositematerials
public struct CompositeMaterialGroup: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.compositeMaterials

    public var id: ResourceID
    public var baseMaterialGroupID: ResourceID // matid
    public var baseMaterialIndices: ResourceIndices  // Indices inside the material group
    public var displayPropertiesID: ResourceID?  // Points to a <displayproperties>
    public var composites: [[Double]]

    public init(id: ResourceID, baseMaterialGroupID: ResourceID, baseMaterialIndices: ResourceIndices, displayPropertiesID: ResourceID? = nil, composites: [[Double]]) {
        self.id = id
        self.baseMaterialGroupID = baseMaterialGroupID
        self.baseMaterialIndices = baseMaterialIndices
        self.displayPropertiesID = displayPropertiesID
        self.composites = composites
    }

    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.setValue(baseMaterialGroupID, forAttribute: .matID)
        element.setValue(baseMaterialIndices, forAttribute: .matIndices)
        element.setValue(displayPropertiesID, forAttribute: .displayPropertiesID)

        for composite in composites {
            let child = element.addElement(Materials.composite)
            child.setValue(composite, forAttribute: .values)
        }
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        baseMaterialGroupID = try element.value(forAttribute: .matID)
        baseMaterialIndices = try element.value(forAttribute: .matIndices)
        displayPropertiesID = try element.value(forAttribute: .displayPropertiesID)

        composites = try element[elements: Materials.composite].map { try $0.value(forAttribute: .values) }
    }
}
