import Foundation
import Nodal

public struct Item: Sendable, XMLElementCodable {
    public var objectID: ResourceID
    public var transform: Matrix3D?
    public var partNumber: String?
    public var metadata: [Metadata]
    public var customAttributes: [ExpandedName: String]
    public var path: URL?
    public var uuid: UUID?

    public init(
        objectID: ResourceID,
        transform: Matrix3D? = nil,
        partNumber: String? = nil,
        metadata: [Metadata] = [],
        customAttributes: [ExpandedName: String] = [:],
        path: URL? = nil,
        uuid: UUID? = nil
    ) {
        self.objectID = objectID
        self.transform = transform
        self.partNumber = partNumber
        self.metadata = metadata
        self.customAttributes = customAttributes
        self.path = path
        self.uuid = uuid
    }

    public func encode(to element: Node) {
        element.setValue(objectID, forAttribute: .objectID)
        element.setValue(transform, forAttribute: .transform)
        element.setValue(partNumber, forAttribute: .partNumber)
        element.setValue(uuid ?? .uuidIfProduction, forAttribute: Production.UUID)
        element.setValue(path, forAttribute: Production.path)

        element.encode(metadata, elementName: Core.metadata, containedIn: Core.metadataGroup)
        for (name, value) in customAttributes {
            element.setValue(value, forAttribute: name)
        }
    }

    public init(from element: Node) throws {
        objectID = try element.value(forAttribute: .objectID)
        transform = try element.value(forAttribute: .transform)
        partNumber = try element.value(forAttribute: .partNumber)
        uuid = try element.value(forAttribute: Production.UUID)
        path = try element.value(forAttribute: Production.path)
        metadata = try element.decode(elementName: Core.metadata, containedIn: Core.metadataGroup)

        let knownAttributes: Set<ExpandedName> = [.objectID, .transform, .partNumber, Core.metadataGroup, Production.UUID, Production.path]
        customAttributes = element.namespacedAttributes.filter { !knownAttributes.contains($0.key) }
    }
}
