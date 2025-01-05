import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:multiproperties
public struct Multiproperties: Resource, XMLConvertibleNamed {
    static let elementName = "m:multiproperties"

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

    enum BlendMethod: String, Hashable, StringConvertible {
        case mix
        case multiply

        public init(string: String) throws(Error) {
            guard let value = BlendMethod(rawValue: string) else {
                throw .malformedBlendMethod(string)
            }
            self = value
        }
    }
}

internal extension Multiproperties {
    var xmlElement: XMLElement {
        XMLElement("m:multiproperties", [
            "id": String(id),
            "pids": propertyGroupIDs.string,
            "blendMethods": blendMethods?.map(\.rawValue).joined(separator: " "),
        ], children: elements.map(\.multiXMLElement))
    }

    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement["id"]
        propertyGroupIDs = try xmlElement["pids"]

        blendMethods = try? xmlElement["blendMethods"]
        elements = try xmlElement.elements(named: "multi") { e throws(Error) in
            try ResourceIndices(multiXMLElement: e)
        }
    }
}

internal extension ResourceIndices {
    var multiXMLElement: XMLElement {
        XMLElement("multi", ["pindices": string])
    }

    init(multiXMLElement xmlElement: XMLElement) throws(Error) {
        self = try xmlElement["pindices"]
    }
}
