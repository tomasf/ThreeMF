import Foundation
import Nodal

/// The objects a model actually outputs, and where to place them.
///
/// A model's resources describe what's available; the build says which of it is produced, and where.
/// What that production is (printing, machining, rendering, something else) is up to the consumer.
public struct Build: Sendable, XMLElementCodable {
    /// The placements to output. An empty build is valid and produces nothing.
    public var items: [Item]

    /// A stable identifier for the build, from the production extension.
    ///
    /// When the model requires that extension, the writer assigns one if you don't.
    public var uuid: UUID?

    /// Creates a build from its items.
    /// - Parameters:
    ///   - items: The placements to output.
    ///   - uuid: A stable identifier for the build.
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
