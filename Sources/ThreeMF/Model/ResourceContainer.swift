import Foundation
import Nodal

/// The resources a model defines, in the order they appear in the file.
///
/// Resources may only refer to ones declared before them, so order matters: a material group has to
/// come before the object that uses it.
public struct ResourceContainer: Sendable {
    /// The resources, in file order.
    public var resources: [any Resource]

    /// Creates a container holding the given resources.
    /// - Parameter resources: The resources, in the order they should appear in the file.
    public init(resources: [any Resource]) {
        self.resources = resources
    }
}

/// Looking up and adding resources.
public extension ResourceContainer {
    /// The resource with the given id, or `nil` if the model has none.
    /// - Parameter id: The id to look for.
    func resource(for id: ResourceID) -> (any Resource)? {
        resources.first(where: { $0.id == id })
    }

    /// An id no resource is using yet, one past the highest in use.
    var nextFreeResourceID: ResourceID {
        (resources.map(\.id).max() ?? 0) + 1
    }

    /// Appends a resource, assigning it an unused id.
    ///
    /// The resource's own ``Resource/id`` is overwritten with the assigned one, which is also returned so
    /// you can refer to it from an ``Item`` or ``Component``.
    /// - Parameter resource: The resource to add.
    /// - Returns: The id assigned to it.
    mutating func add(resource: any Resource) -> ResourceID {
        var mutable = resource
        mutable.id = nextFreeResourceID
        resources.append(mutable)
        return mutable.id
    }
}

extension ResourceContainer: XMLElementCodable {
    public init(from element: Nodal.Node) throws {
        resources = try element.elements.map { e throws in
            guard let resourceType = resourceTypePerElementIdentifier[e.expandedName] else {
                return nil // Unknown resource element type
            }
            return try resourceType.init(from: e)
        }.compactMap { $0 }
    }

    public func encode(to element: Nodal.Node) {
        for resource in resources {
            element.encode(resource, elementName: type(of: resource).elementName)
        }
    }
}
