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

    public init(objectID: ResourceID, transform: Matrix3D? = nil, partNumber: String? = nil, metadata: [Metadata] = [], printable: Bool? = nil) {
        self.objectID = objectID
        self.transform = transform
        self.partNumber = partNumber
        self.metadata = metadata
        self.printable = printable
    }
}

extension Item: XMLElementComposable {
    static let elementIdentifier = Core.item

    var attributes: [AttributeIdentifier : (any XMLStringConvertible)?] {
        [
            Core.objectID: objectID,
            Core.transform: transform,
            Core.partNumber: partNumber,
            Core.printable: printable
        ]
    }

    var children: [(any XMLConvertible)?] {
        [metadata.wrappedNonEmpty(in: Core.metadataGroup)]
    }

    init(xmlElement: XMLElement) throws(Error) {
        objectID = try xmlElement[Core.objectID]
        transform = try? xmlElement[Core.transform]
        partNumber = try? xmlElement[Core.partNumber]

        metadata = try ((try? xmlElement[Core.metadataGroup])?[Core.metadata]) ?? []
        printable = try? xmlElement[Core.printable]
    }
}
