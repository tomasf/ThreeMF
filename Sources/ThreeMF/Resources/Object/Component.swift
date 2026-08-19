import Foundation
import Nodal

// component
/// One object placed inside another, with its own transform.
///
/// Components are how an assembly is built: an object whose ``Object/content`` is components places
/// other objects rather than holding geometry itself. A component must not, directly or indirectly,
/// place the object it belongs to.
public struct Component: Sendable, XMLElementCodable {
    /// The ``Resource/id`` of the object being placed.
    public var objectID: ResourceID

    /// Where to place the object, relative to the containing object. `nil` places it untransformed.
    public var transform: Matrix3D?

    /// The model part the object comes from, when it isn't this one.
    ///
    /// Part of the production extension, for models split across several files.
    public var path: URL?

    /// A stable identifier for this component, from the production extension.
    ///
    /// When the model requires that extension, the writer assigns one if you don't.
    public var uuid: UUID?

    /// Creates a component placing an object.
    /// - Parameters:
    ///   - objectID: The id of the object to place.
    ///   - transform: Where to place it, relative to the containing object.
    ///   - path: The model part the object comes from.
    ///   - uuid: A stable identifier for this component.
    public init(objectID: ResourceID, transform: Matrix3D? = nil, path: URL? = nil, uuid: UUID? = nil) {
        self.objectID = objectID
        self.transform = transform
        self.path = path
        self.uuid = uuid
    }

    public func encode(to element: Node) {
        element.setValue(objectID, forAttribute: .objectID)
        element.setValue(transform, forAttribute: .transform)
        element.setValue(path, forAttribute: Production.path)
        element.setValue(uuid ?? .uuidIfProduction, forAttribute: Production.UUID)
    }

    public init(from element: Node) throws {
        objectID = try element.value(forAttribute: .objectID)
        transform = try element.value(forAttribute: .transform)
        path = try element.value(forAttribute: Production.path)
        uuid = try element.value(forAttribute: Production.UUID)
    }
}
