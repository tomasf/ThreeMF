import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// object
public struct Object: Resource {
    public var id: ResourceID
    public var type: ObjectType?
    public var thumbnail: URL?
    public var partNumber: String?
    public var name: String?

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

        self.propertyGroupID = propertyGroupID
        self.propertyIndex = propertyIndex

        self.metadata = metadata
        self.content = content
    }
}

extension Object: XMLElementComposable {
    static let elementIdentifier = Core.object

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            Core.id: id,
            Core.type: type,
            Core.thumbnail: thumbnail?.relativePath,
            Core.partNumber: partNumber,
            Core.name: name,
            Core.pid: propertyGroupID,
            Core.pIndex: propertyIndex,
        ]
    }

    var children: [(any XMLConvertible)?] {
        metadata + [content.xmlElement]
    }

    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement[Core.id]
        type = try? xmlElement[Core.type]
        thumbnail = try? xmlElement[Core.thumbnail]
        partNumber = try? xmlElement[Core.partNumber]
        name = try? xmlElement[Core.name]

        propertyGroupID = try? xmlElement[Core.pid]
        propertyIndex = try? xmlElement[Core.pIndex]

        metadata = try xmlElement[Core.metadataGroup]
        content = try .init(objectXMLElement: xmlElement)
    }
}


public extension Object {
    enum Content {
        case mesh (Mesh)
        case components ([Component])
    }

    enum ObjectType: String, Sendable, XMLStringConvertible {
        case model
        case solidSupport = "solidsupport"
        case support
        case surface
        case other

        static let `default` = Self.model
    }
}

internal extension Object.Content {
    init(objectXMLElement: XMLElement) throws(Error) {
        if let mesh: Mesh = try? objectXMLElement[Core.mesh] {
            self = .mesh(mesh)
        } else if let componentsElement: XMLElement = try? objectXMLElement[Core.components] {
            self = .components(try componentsElement[Core.component])
        } else {
            throw .missingElement(name: "mesh OR components")
        }
    }

    var xmlElement: XMLConvertible {
        switch self {
        case .mesh (let mesh): mesh
        case .components (let components): components.wrapped(in: Core.components)
        }
    }
}
