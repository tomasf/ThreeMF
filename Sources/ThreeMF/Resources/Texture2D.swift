import Foundation
import Nodal

// m:texture2d
@XMLCodable
public struct Texture2D: Resource {
    static public let elementName: ExpandedName = Materials.texture2D

    @Attribute(.id) public var id: ResourceID
    @Attribute(.path) public var pathURL: URL
    @Attribute(.contentType) public var contentType: ContentType
    @Attribute(.tileStyleU) public var tileStyleU: TileStyle?
    @Attribute(.tileStyleV) public var tileStyleV: TileStyle?
    @Attribute(.filter) public var filter: Filter?

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

    enum ContentType: String, XMLValueCodable, Hashable, Sendable {
        case png = "image/png"
        case jpeg = "image/jpeg"
    }

    enum TileStyle: String, XMLValueCodable, Hashable, Sendable {
        case wrap
        case mirror
        case clamp
        case none

        public static let `default` = Self.wrap
    }

    enum Filter: String, XMLValueCodable, Hashable, Sendable {
        case auto
        case linear
        case nearest

        public static let `default` = Self.auto
    }
}
