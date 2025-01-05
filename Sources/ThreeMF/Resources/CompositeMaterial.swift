import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:compositematerials
public struct CompositeMaterialGroup: Resource, XMLConvertibleNamed {
    static let elementName = "m:compositematerials"

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

internal extension CompositeMaterialGroup {
    var xmlElement: XMLElement {
        XMLElement("m:compositematerials", [
            "id": String(id),
            "matid": String(baseMaterialGroupID),
            "matindices": baseMaterialIndices.string,
            "displaypropertiesid": displayPropertiesID.map { String($0) }
        ], children: composites.map(\.compositeXMLElement))
    }

    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement["id"]
        baseMaterialGroupID = try xmlElement["matid"]
        baseMaterialIndices = try xmlElement["matindices"]
        displayPropertiesID = try? xmlElement["displaypropertiesid"]

        composites = try xmlElement.elements(named: "m:composite") { e throws(Error) in
            try Numbers(compositeXMLElement: e)
        }
    }
}

internal extension Numbers {
    var compositeXMLElement: XMLElement {
        XMLElement("m:composite", ["values": string])
    }

    init(compositeXMLElement xmlElement: XMLElement) throws(Error) {
        self = try xmlElement["values"]
    }
}
