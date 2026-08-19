import Foundation
import Nodal

/// One placement of an object in a model's output.
///
/// A build item names an object in the model's resources and, optionally, where to put it. Only
/// objects reached through a build item are output; anything else in ``Model/resources`` is just
/// available to be referenced.
public struct Item: Sendable, XMLElementCodable {
    /// The ``Resource/id`` of the object to place.
    ///
    /// The object lives in the same model file, unless ``path`` points at another one.
    public var objectID: ResourceID

    /// Where to place the object, as an affine transform. `nil` places it untransformed.
    public var transform: Matrix3D?

    /// An identifier for the part this item produces, for consumers that track parts across builds.
    public var partNumber: String?

    /// Metadata about this placement.
    public var metadata: [Metadata]

    /// Attributes on the `<item>` element that aren't part of 3MF, preserved as they are.
    ///
    /// An attribute in a namespace needs a prefix for that namespace in ``Model/customNamespaces``.
    public var customAttributes: [ExpandedName: String]

    /// The model part the object comes from, when it isn't this one.
    ///
    /// Part of the production extension, for models split across several files. Use the URL returned
    /// by ``PackageWriter/addAdditionalModel(_:named:)``.
    public var path: URL?

    /// A stable identifier for this item, from the production extension.
    ///
    /// When the model requires that extension, the writer assigns one if you don't.
    public var uuid: UUID?

    /// Creates a build item placing an object.
    /// - Parameters:
    ///   - objectID: The id of the object to place.
    ///   - transform: Where to place it. `nil` places it untransformed.
    ///   - partNumber: An identifier for the resulting part.
    ///   - metadata: Metadata about this placement.
    ///   - customAttributes: Non-3MF attributes to keep on the element.
    ///   - path: The model part the object comes from, for production-extension packages.
    ///   - uuid: A stable identifier for this item.
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
        for (name, value) in customAttributes.sortedByName {
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
        customAttributes = element.customAttributes(besides: knownAttributes)
    }
}
