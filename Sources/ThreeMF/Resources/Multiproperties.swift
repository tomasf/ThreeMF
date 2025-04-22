import Foundation
import Nodal

// m:multiproperties
public struct Multiproperties: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.multiproperties

    public var id: ResourceID
    public var propertyGroupIDs: ResourceIndices // pids
    public var blendMethods: [BlendMethod]?
    public var multis: [ResourceIndices]

    public init(id: ResourceID, propertyGroupIDs: ResourceIndices, blendMethods: [BlendMethod]? = nil, multis: [ResourceIndices]) {
        self.id = id
        self.propertyGroupIDs = propertyGroupIDs
        self.blendMethods = blendMethods
        self.multis = multis
    }

    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.setValue(propertyGroupIDs, forAttribute: .pids)
        element.setValue(blendMethods, forAttribute: .blendMethods)

        for composite in multis {
            let child = element.addElement(Materials.multi)
            child.setValue(composite, forAttribute: .pIndices)
        }
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        propertyGroupIDs = try element.value(forAttribute: .pids)
        blendMethods = try element.value(forAttribute: .blendMethods)

        multis = try element[elements: Materials.multi].map { try $0.value(forAttribute: .pIndices) }
    }
}

public extension Multiproperties {
    struct Layer: Sendable {
        let property: PropertyReference
        let blendMethod: BlendMethod
    }

    typealias LayerSequence = [Layer]

    var layerSequences: [LayerSequence] {
        multis.map { indices in
            propertyGroupIDs.enumerated().map { i, propertyGroupID in
                Layer(
                    property: PropertyReference(groupID: propertyGroupID, index: indices[safe: i] ?? 0),
                    blendMethod: blendMethods?[safe: i - 1] ?? .mix
                )
            }
        }
    }

    enum BlendMethod: String, Hashable, Sendable, XMLValueCodable {
        case mix
        case multiply
    }
}
