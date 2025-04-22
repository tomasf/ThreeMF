import Foundation
import Nodal

// m:texture2d
public struct Texture2D: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.texture2D

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

    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.setValue(pathURL, forAttribute: .path)
        element.setValue(contentType, forAttribute: .contentType)
        element.setValue(tileStyleU, forAttribute: .tileStyleU)
        element.setValue(tileStyleV, forAttribute: .tileStyleV)
        element.setValue(filter, forAttribute: .filter)
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        pathURL = try element.value(forAttribute: .path)
        contentType = try element.value(forAttribute: .contentType)
        tileStyleU = try element.value(forAttribute: .tileStyleU)
        tileStyleV = try element.value(forAttribute: .tileStyleV)
        filter = try element.value(forAttribute: .filter)
    }
}

public extension Texture2D {
    var effectiveTileStyles: (U: TileStyle, V: TileStyle) {
        (tileStyleU ?? .default, tileStyleV ?? .default)
    }

    enum ContentType: String, Hashable, Sendable, XMLValueCodable {
        case png = "image/png"
        case jpeg = "image/jpeg"
    }

    enum TileStyle: String, Hashable, Sendable, XMLValueCodable {
        case wrap
        case mirror
        case clamp
        case none

        public static let `default` = Self.wrap
    }

    enum Filter: String, Hashable, Sendable, XMLValueCodable {
        case auto
        case linear
        case nearest

        public static let `default` = Self.auto
    }
}
