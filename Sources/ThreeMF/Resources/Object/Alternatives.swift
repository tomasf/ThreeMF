import Foundation
import Nodal

// pa:alternative
/// Another representation of an object, from the alternatives extension.
///
/// Lets a file carry, say, a low-resolution or obfuscated stand-in beside the real geometry, so a
/// consumer can pick whichever it's entitled to use.
public struct Alternative: XMLElementCodable, Sendable {
    /// The ``Resource/id`` of the object holding this alternative representation.
    public var objectID: ResourceID

    /// The identifier this alternative shares with the object it stands in for.
    public var uuid: UUID

    /// The model part the alternative's object lives in, when it isn't this one.
    public var path: URL?

    /// How exact this alternative is, so a consumer can tell it apart from the others.
    public var modelResolution: ModelResolution?

    /// Creates an alternative representation of an object.
    /// - Parameters:
    ///   - objectID: The id of the object holding this representation.
    ///   - uuid: The identifier this alternative shares with the object it stands in for. A fresh
    ///     one is generated when you don't give one.
    ///   - path: The model part the alternative's object lives in, when it isn't this one.
    ///   - modelResolution: How exact this alternative is.
    public init(objectID: ResourceID, uuid: UUID? = nil, path: URL? = nil, modelResolution: ModelResolution? = nil) {
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
