import Foundation
import Nodal

// m:multiproperties
/// Several property groups applied at once, blended together.
///
/// From the materials extension. It lets one index select, say, both a base material and a color, and
/// says how to combine them, giving a color layered over a material rather than either alone.
public struct Multiproperties: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.multiproperties

    public var id: ResourceID

    /// The property groups being combined, in layering order: the first is the base, later ones blend
    /// over it.
    public var propertyGroupIDs: ResourceIndices // pids

    /// How each layer after the first blends onto the ones below it.
    ///
    /// One fewer than ``propertyGroupIDs``, since the base layer isn't blended onto anything. `nil`
    /// blends everything with ``BlendMethod/mix``.
    public var blendMethods: [BlendMethod]?

    /// The combinations, each holding one index per entry of ``propertyGroupIDs``.
    public var multis: [ResourceIndices]

    /// Creates a multiproperties resource.
    /// - Parameters:
    ///   - id: The resource's id, unique within its model file.
    ///   - propertyGroupIDs: The property groups to combine, in layering order.
    ///   - blendMethods: How each layer blends onto the ones below.
    ///   - multis: The combinations, each an index per group.
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

/// Reading a multiproperties resource as resolved layers.
public extension Multiproperties {
    /// One layer of a combination: which property it takes, and how it blends onto what's beneath.
    struct Layer: Sendable {
        /// Which entry of which property group this layer takes.
        public let property: PropertyReference

        /// How this layer combines with the ones below it.
        public let blendMethod: BlendMethod
    }

    /// One combination, as layers from the base upward.
    typealias LayerSequence = [Layer]

    /// ``multis`` resolved into layers, pairing each index with its group and blend method.
    ///
    /// Indices missing from a combination resolve to 0, and layers with no blend method given use
    /// ``BlendMethod/mix``, so every sequence has one layer per property group.
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

    /// How one property layer combines with the ones below it.
    enum BlendMethod: String, Hashable, Sendable, XMLValueCodable {
        /// Interpolate between the layers.
        case mix

        /// Multiply the layers together, darkening where they overlap.
        case multiply
    }
}
