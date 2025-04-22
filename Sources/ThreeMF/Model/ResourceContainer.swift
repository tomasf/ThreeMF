import Foundation
import Nodal

public struct ResourceContainer: Sendable {
    public var resources: [any Resource]

    public init(resources: [any Resource]) {
        self.resources = resources
    }
}

public extension ResourceContainer {
    func resource(for id: ResourceID) -> (any Resource)? {
        resources.first(where: { $0.id == id })
    }

    var nextFreeResourceID: ResourceID {
        (resources.map(\.id).max() ?? 0) + 1
    }

    mutating func add(resource: any Resource) -> ResourceID {
        var mutable = resource
        mutable.id = nextFreeResourceID
        resources.append(mutable)
        return resource.id
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
