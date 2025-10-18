import Foundation
import Nodal

// object
public struct Object: Resource {
    static public let elementName: ExpandedName = Core.object

    public var id: ResourceID
    public var type: ObjectType?
    public var thumbnail: URL?
    public var partNumber: String?
    public var name: String?
    public var uuid: UUID?

    public var modelResolution: ModelResolution?
    public var alternatives: [Alternative]

    public var propertyGroupID: ResourceID?
    public var propertyIndex: ResourceIndex?

    public var metadata: [Metadata]
    public var content: Content

    public init(
        id: ResourceID,
        type: ObjectType? = nil,
        thumbnail: URL? = nil,
        partNumber: String? = nil,
        name: String? = nil,
        uuid: UUID? = nil,
        modelResolution: ModelResolution? = nil,
        alternatives: [Alternative] = [],
        propertyGroupID: ResourceID? = nil,
        propertyIndex: ResourceIndex? = nil,
        metadata: [Metadata] = [],
        content: Content
    ) {
        self.id = id
        self.type = type
        self.thumbnail = thumbnail
        self.partNumber = partNumber
        self.name = name
        self.uuid = uuid

        self.modelResolution = modelResolution
        self.alternatives = alternatives

        self.propertyGroupID = propertyGroupID
        self.propertyIndex = propertyIndex

        self.metadata = metadata
        self.content = content
    }
}

extension Object: XMLElementCodable {
    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.setValue(type, forAttribute: .type)
        element.setValue(thumbnail, forAttribute: .thumbnail)
        element.setValue(partNumber, forAttribute: .partNumber)
        element.setValue(name, forAttribute: .name)
        element.setValue(uuid ?? .uuidIfProduction, forAttribute: Production.UUID)

        element.setValue(modelResolution, forAttribute: Alternatives.modelResolution)
        element.encode(alternatives, elementName: Alternatives.alternative, containedIn: Alternatives.alternatives)

        element.setValue(propertyGroupID, forAttribute: .pid)
        element.setValue(propertyIndex, forAttribute: .pIndex)
        element.encode(metadata, elementName: Core.metadata)

        let contentElement = element.addElement("")
        content.encode(to: contentElement)
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        type = try element.value(forAttribute: .type)
        thumbnail = try element.value(forAttribute: .thumbnail)
        partNumber = try element.value(forAttribute: .partNumber)
        name = try element.value(forAttribute: .name)
        uuid = try element.value(forAttribute: Production.UUID)

        modelResolution = try element.value(forAttribute: Alternatives.modelResolution)
        alternatives = try element.decode(elementName: Alternatives.alternative, containedIn: Alternatives.alternatives)

        propertyGroupID = try element.value(forAttribute: .pid)
        propertyIndex = try element.value(forAttribute: .pIndex)
        metadata = try element.decode(elementName: Core.metadata)

        guard let contentElement = element[element: Core.mesh] ?? element[element: Core.components] else {
            throw XMLElementCodableError.elementMissing(Core.mesh)
        }
        content = try .init(from: contentElement)
    }
}

public extension Object {
    enum Content: Sendable {
        case mesh (Mesh)
        case components ([Component])
    }

    enum ObjectType: String, Sendable, XMLValueCodable {
        case model
        case solidSupport = "solidsupport"
        case support
        case surface
        case other

        static let `default` = Self.model
    }
}

extension Object.Content: XMLElementCodable {
    public func encode(to element: Node) {
        switch self {
        case .mesh (let mesh):
            element.expandedName = Core.mesh
            mesh.encode(to: element)

        case .components (let components):
            element.expandedName = Core.components
            element.encode(components, elementName: Core.component)
        }
    }

    public init(from element: Node) throws {
        if element.expandedName == Core.mesh {
            self = .mesh(try Mesh(from: element))
        } else {
            self = .components(try element.decode(elementName: Core.component))
        }
    }
}
