import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:texture2d
public struct Texture2D: Resource, XMLConvertibleNamed {
    static let elementName = "m:texture2d"

    public var id: ResourceID
    public var pathURL: URL
    public var contentType: ContentType
    public var tileStyleU: TileStyle
    public var tileStyleV: TileStyle
    public var filter: Filter

    public init(
        id: ResourceID,
        pathURL: URL,
        contentType: ContentType,
        tileStyleU: TileStyle = .default,
        tileStyleV: TileStyle = .default,
        filter: Filter = .default
    ) {
        self.id = id
        self.pathURL = pathURL
        self.contentType = contentType
        self.tileStyleU = tileStyleU
        self.tileStyleV = tileStyleV
        self.filter = filter
    }
}

public extension Texture2D {
    enum ContentType: String, StringConvertible, Hashable, Sendable {
        case png = "image/png"
        case jpeg = "image/jpeg"
    }

    enum TileStyle: String, StringConvertible, Hashable, Sendable {
        case wrap
        case mirror
        case clamp
        case none

        public static let `default` = Self.wrap
    }

    enum Filter: String, StringConvertible, Hashable, Sendable {
        case auto
        case linear
        case nearest

        public static let `default` = Self.auto
    }
}

internal extension Texture2D {
    var xmlElement: XMLElement {
        XMLElement("m:texture2d", [
            "id": String(id),
            "path": pathURL.absoluteString,
            "contenttype": contentType.rawValue,
            "tilestyleu": tileStyleU.rawValue,
            "tilestylev": tileStyleV.rawValue,
            "filter": filter.rawValue
        ])
    }
    
    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement["id"]
        pathURL = try xmlElement["path"]
        contentType = try xmlElement["contenttype"]

        tileStyleU = try xmlElement["tilestyleu", default: .default]
        tileStyleV = try xmlElement["tilestylev", default: .default]
        filter = try xmlElement["filter", default: .default]
    }
}
