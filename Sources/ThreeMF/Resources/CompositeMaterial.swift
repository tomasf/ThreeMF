import Foundation
import Nodal

// m:compositematerials
/// Materials made by mixing base materials in fixed ratios.
///
/// From the materials extension, for consumers that can blend materials. Each composite gives the proportions
/// of the base materials it's mixed from.
public struct CompositeMaterialGroup: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.compositeMaterials

    public var id: ResourceID

    /// The ``BaseMaterialGroup`` whose materials are being mixed.
    public var baseMaterialGroupID: ResourceID // matid

    /// Which materials of that group take part, as indices into it.
    ///
    /// A composite's ratios line up with this list.
    public var baseMaterialIndices: ResourceIndices  // Indices inside the material group

    /// Display properties describing how these composites should look when rendered, if any.
    public var displayPropertiesID: ResourceID?  // Points to a <displayproperties>

    /// The mixtures, each giving one ratio per entry of ``baseMaterialIndices``.
    public var composites: [[Double]]

    /// Creates a composite material group.
    /// - Parameters:
    ///   - id: The group's id, unique within its model file.
    ///   - baseMaterialGroupID: The base material group being mixed from.
    ///   - baseMaterialIndices: Which materials of that group take part.
    ///   - displayPropertiesID: Display properties for these composites.
    ///   - composites: The mixtures, each a ratio per participating material.
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
