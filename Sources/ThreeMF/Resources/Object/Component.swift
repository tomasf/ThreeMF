import Foundation
import Nodal

// component
public struct Component: Sendable, XMLElementCodable {
    public var objectID: ResourceID
    public var transform: Matrix3D?
    public var path: URL?
    public var uuid: UUID?

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
