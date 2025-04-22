import Foundation
import Nodal

public struct Item: Sendable, XMLElementCodable {
    public var objectID: ResourceID
    public var transform: Matrix3D?
    public var partNumber: String?
    public var printable: Bool? // Prusa extension
    public var metadata: [Metadata]

    public init(objectID: ResourceID, transform: Matrix3D? = nil, partNumber: String? = nil, metadata: [Metadata] = [], printable: Bool? = nil) {
        self.objectID = objectID
        self.transform = transform
        self.partNumber = partNumber
        self.metadata = metadata
        self.printable = printable
    }

    public func encode(to element: Node) {
        element.setValue(objectID, forAttribute: .objectID)
        element.setValue(transform, forAttribute: .transform)
        element.setValue(partNumber, forAttribute: .partNumber)
        element.setValue(printable, forAttribute: .printable)
        element.encode(metadata, elementName: Core.metadata, containedIn: Core.metadataGroup)
    }

    public init(from element: Node) throws {
        objectID = try element.value(forAttribute: .objectID)
        transform = try element.value(forAttribute: .transform)
        partNumber = try element.value(forAttribute: .partNumber)
        printable = try element.value(forAttribute: .printable)
        metadata = try element.decode(elementName: Core.metadata, containedIn: Core.metadataGroup)
    }
}
