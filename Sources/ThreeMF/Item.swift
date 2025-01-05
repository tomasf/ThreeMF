import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public struct Item {
    public var objectID: ResourceID
    public var transform: Matrix3D?
    public var partNumber: String?
    public var metadata: [Metadata]
    public var printable: Bool? // Prusa extension

    init(objectID: ResourceID, transform: Matrix3D? = nil, partNumber: String? = nil, metadata: [Metadata] = []) {
        self.objectID = objectID
        self.transform = transform
        self.partNumber = partNumber
        self.metadata = metadata
    }
}

extension Item: XMLConvertible {
    var xmlElement: XMLElement {
        XMLElement("item", [
            "objectid": String(objectID),
            "transform": transform?.string,
            "partnumber": partNumber
        ], children: [metadata.xmlElement])
    }

    init(xmlElement: XMLElement) throws(Error) {
        objectID = try xmlElement["objectid"]
        transform = try? xmlElement["transform"]
        partNumber = try? xmlElement["partnumber"]
        metadata = try .init(xmlElement: try? xmlElement[element: "metadatagroup"])
    }
}
