import Foundation
import Nodal

@XMLCodable
public struct Item {
    @Attribute(.objectID) public var objectID: ResourceID
    @Attribute(.transform) public var transform: Matrix3D?
    @Attribute(.partNumber) public var partNumber: String?
    @Attribute(.printable) public var printable: Bool? // Prusa extension

    @Element(Core.metadata, containedIn: Core.metadataGroup)
    public var metadata: [Metadata]

    public init(objectID: ResourceID, transform: Matrix3D? = nil, partNumber: String? = nil, metadata: [Metadata] = [], printable: Bool? = nil) {
        self.objectID = objectID
        self.transform = transform
        self.partNumber = partNumber
        self.metadata = metadata
        self.printable = printable
    }
}
