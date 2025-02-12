import Foundation
import Nodal

// m:multiproperties
public struct Multiproperties: Resource {
    public var id: ResourceID
    public var propertyGroupIDs: ResourceIndices // pids
    public var blendMethods: [BlendMethod]?
    public var elements: [ResourceIndices]

    public init(id: ResourceID, propertyGroupIDs: ResourceIndices, blendMethods: [BlendMethod]? = nil, elements: [ResourceIndices]) {
        self.id = id
        self.propertyGroupIDs = propertyGroupIDs
        self.blendMethods = blendMethods
        self.elements = elements
    }
}

public extension Multiproperties {
    struct Layer {
        let property: PropertyReference
        let blendMethod: BlendMethod
    }

    typealias LayerSequence = [Layer]

    var layerSequences: [LayerSequence] {
        elements.map { indices in
            propertyGroupIDs.enumerated().map { i, propertyGroupID in
                Layer(
                    property: PropertyReference(groupID: propertyGroupID, index: indices[safe: i] ?? 0),
                    blendMethod: blendMethods?[safe: i - 1] ?? .mix
                )
            }
        }
    }

    enum BlendMethod: String, Hashable, XMLStringConvertible {
        case mix
        case multiply
    }
}

extension Multiproperties: XMLElementComposable {
    static let elementIdentifier = Materials.multiproperties

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            .m.id: id,
            .m.pids: propertyGroupIDs.string,
            .m.blendMethods: blendMethods?.string
        ]
    }

    var children: [(any XMLConvertible)?] {
        elements.map { LiteralElement(name: .m.multi, attributes: [.m.pIndices: $0.string]) }

    }

    init(xmlElement: Node) throws(Error) {
        id = try xmlElement[.m.id]
        propertyGroupIDs = try xmlElement[.m.pids]

        blendMethods = try? xmlElement[.m.blendMethods]
        elements = try xmlElement[.m.multi].map { n throws(Error) in try n[.m.pIndices] }
    }
}
