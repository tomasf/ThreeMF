import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// object
public struct Object: Resource, XMLConvertibleNamed {
    static let elementName = "object"

    public var id: ResourceID
    public var type: ObjectType
    public var thumbnail: URL?
    public var partNumber: String?
    public var name: String?
    public var property: PropertyReference?
    public var metadata: [Metadata]
    public var content: Content

    public init(id: ResourceID, type: ObjectType, thumbnail: URL? = nil, partNumber: String? = nil, name: String? = nil, property: PropertyReference? = nil, metadata: [Metadata], content: Content) {
        self.id = id
        self.type = type
        self.thumbnail = thumbnail
        self.partNumber = partNumber
        self.name = name
        self.property = property
        self.metadata = metadata
        self.content = content
    }
}

public extension Object {
    enum Content {
        case mesh (Mesh)
        case components ([Component])
    }

    enum ObjectType: String, Sendable {
        case model
        case solidSupport = "solidsupport"
        case support
        case surface
        case other

        static let `default` = Self.model

        init(string: String?) {
            self = string.flatMap { Self(rawValue: $0) } ?? .default
        }

        var string: String { rawValue }
    }
}

internal extension PropertyReference {
    var objectXMLAttributes: [String: String] {
        ["pid": String(groupID), "pindex": String(index)]
    }
}

internal extension Object {
    var xmlElement: XMLElement {
        XMLElement("object", [
            "id": String(id),
            "type": type.string,
            "thumbnail": thumbnail?.relativeString,
            "partnumber": partNumber,
            "name": name,
        ] + (property?.objectXMLAttributes ?? [:]), children: [metadata.xmlElement])
    }

    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement["id"]
        type = ObjectType(string: try? xmlElement["type"])
        thumbnail = try? xmlElement["thumbnail"]
        partNumber = try? xmlElement["partnumber"]
        name = try? xmlElement["name"]
        if let pindex: ResourceIndex = try? xmlElement["pindex"] {
            property = PropertyReference(groupID: try xmlElement["pid"], index: pindex)
        } else {
            property = nil
        }
        metadata = try .init(xmlElement: try? xmlElement[element: "metadatagroup"])
        content = try .init(objectXMLElement: xmlElement)
    }
}

internal extension Object.Content {
    init(objectXMLElement: XMLElement) throws(Error) {
        if let mesh = try? objectXMLElement[element: "mesh"] {
            self = .mesh(try .init(xmlElement: mesh))
        } else if let components = try? objectXMLElement[element: "components"] {
            self = .components(try .init(xmlElement: components))
        } else {
            throw .missingElement(name: "mesh OR components", parentXPath: objectXMLElement.xPath ?? "")
        }
    }

    var xmlElement: XMLElement {
        switch self {
        case .mesh (let mesh): mesh.xmlElement
        case .components (let components): components.xmlElement
        }
    }
}
