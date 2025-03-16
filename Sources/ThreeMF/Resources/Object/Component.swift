import Foundation
import Nodal

// component
public struct Component: XMLElementCodable {
    public var objectID: ResourceID
    public var transform: Matrix3D?

    public init(objectID: ResourceID, transform: Matrix3D? = nil) {
        self.objectID = objectID
        self.transform = transform
    }

    public func encode(to element: Node) {
        element.setValue(objectID, forAttribute: .objectID)
        element.setValue(transform, forAttribute: .transform)
    }

    public init(from element: Node) throws {
        objectID = try element.value(forAttribute: .objectID)
        transform = try element.value(forAttribute: .transform)
    }
}
