import Foundation
import Nodal

// pa:alternative
public struct Alternative: XMLElementCodable, Sendable {
    public var objectID: ResourceID
    public var uuid: UUID
    public var path: URL?
    public var modelResolution: ModelResolution?

    init(objectID: ResourceID, uuid: UUID? = nil, path: URL? = nil, modelResolution: ModelResolution? = nil) {
        self.objectID = objectID
        self.uuid = uuid ?? UUID()
        self.path = path
        self.modelResolution = modelResolution
    }

    public func encode(to element: Node) {
        element.setValue(objectID, forAttribute: .objectID)
        element.setValue(uuid, forAttribute: Production.UUID)
        element.setValue(path, forAttribute: .path)
        element.setValue(modelResolution, forAttribute: .modelResolution)
    }

    public init(from element: Node) throws {
        objectID = try element.value(forAttribute: .objectID)
        uuid = try element.value(forAttribute: Production.UUID)
        path = try element.value(forAttribute: .path)
        modelResolution = try element.value(forAttribute: .modelResolution)
    }
}
