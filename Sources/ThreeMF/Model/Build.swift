import Foundation
import Nodal

public struct Build: Sendable, XMLElementCodable {
    public var items: [Item]
    public var uuid: UUID?

    public init(items: [Item], uuid: UUID? = nil) {
        self.items = items
        self.uuid = uuid
    }

    public func encode(to element: Node) {
        element.setValue(uuid ?? .uuidIfProduction, forAttribute: Production.UUID)
        element.encode(items, elementName: Core.item)
    }

    public init(from element: Node) throws {
        uuid = try element.value(forAttribute: Production.UUID)
        items = try element.decode(elementName: Core.item)
    }
}
