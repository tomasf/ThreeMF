import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:texture2d
public struct Texture2D: Resource {
    public var id: ResourceID
    public var pathURL: URL
    public var contentType: ContentType
    public var tileStyleU: TileStyle?
    public var tileStyleV: TileStyle?
    public var filter: Filter?

    public init(
        id: ResourceID,
        pathURL: URL,
        contentType: ContentType,
        tileStyleU: TileStyle? = nil,
        tileStyleV: TileStyle? = nil,
        filter: Filter? = nil
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
    var effectiveTileStyles: (U: TileStyle, V: TileStyle) {
        (tileStyleU ?? .default, tileStyleV ?? .default)
    }

    enum ContentType: String, XMLStringConvertible, Hashable, Sendable {
        case png = "image/png"
        case jpeg = "image/jpeg"
    }

    enum TileStyle: String, XMLStringConvertible, Hashable, Sendable {
        case wrap
        case mirror
        case clamp
        case none

        public static let `default` = Self.wrap
    }

    enum Filter: String, XMLStringConvertible, Hashable, Sendable {
        case auto
        case linear
        case nearest

        public static let `default` = Self.auto
    }
}

extension Texture2D: XMLElementComposable {
    static let elementIdentifier = Materials.texture2D

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            .m.id: id,
            .m.path: pathURL.relativePath,
            .m.contentType: contentType,
            .m.tileStyleU: tileStyleU,
            .m.tileStyleV: tileStyleV,
            .m.filter: filter
        ]
    }

    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement[.m.id]
        pathURL = try xmlElement[.m.path]
        contentType = try xmlElement[.m.contentType]

        tileStyleU = try? xmlElement[.m.tileStyleU]
        tileStyleV = try? xmlElement[.m.tileStyleV]
        filter = try? xmlElement[.m.filter]
    }
}
