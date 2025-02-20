import Foundation
import Nodal

// component
@XMLCodable
public struct Component {
    @Attribute(.objectID) public var objectID: ResourceID
    @Attribute(.transform) public var transform: Matrix3D?

    public init(objectID: ResourceID, transform: Matrix3D? = nil) {
        self.objectID = objectID
        self.transform = transform
    }
}
