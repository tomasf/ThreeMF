import Foundation
import Nodal

// m:texture2d
/// An image inside the package, used as a texture.
///
/// From the materials extension. The image itself is a separate part: add it with
/// ``PackageWriter/addTexture(data:)`` and point ``pathURL`` at what that returns. A
/// ``Texture2DGroup`` then maps triangle vertices onto it.
public struct Texture2D: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.texture2D

    public var id: ResourceID

    /// The part inside the package holding the image data.
    public var pathURL: URL

    /// The image format of that part.
    public var contentType: ContentType

    /// What happens horizontally outside the 0–1 range. `nil` means ``TileStyle/wrap``.
    public var tileStyleU: TileStyle?

    /// What happens vertically outside the 0–1 range. `nil` means ``TileStyle/wrap``.
    public var tileStyleV: TileStyle?

    /// How the image is sampled when it's scaled. `nil` leaves the choice to the consumer.
    public var filter: Filter?

    /// Creates a texture referring to an image part.
    /// - Parameters:
    ///   - id: The texture's id, unique within its model file.
    ///   - pathURL: The package part holding the image.
    ///   - contentType: The image's format.
    ///   - tileStyleU: What happens horizontally outside the 0–1 range.
    ///   - tileStyleV: What happens vertically outside the 0–1 range.
    ///   - filter: How the image is sampled when scaled.
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

/// A texture's tiling, format and filtering.
public extension Texture2D {
    /// The tile styles actually in force, substituting the default for any that isn't set.
    var effectiveTileStyles: (U: TileStyle, V: TileStyle) {
        (tileStyleU ?? .default, tileStyleV ?? .default)
    }

    /// The image formats a texture may be stored in.
    enum ContentType: String, Hashable, Sendable, XMLValueCodable {
        /// A PNG image.
        case png = "image/png"

        /// A JPEG image.
        case jpeg = "image/jpeg"
    }

    /// What a texture does outside the 0–1 coordinate range.
    enum TileStyle: String, Hashable, Sendable, XMLValueCodable {
        /// Repeat the image. The default when a file doesn't say.
        case wrap

        /// Repeat the image, flipping it on each repeat.
        case mirror

        /// Hold the edge pixels.
        case clamp

        /// Treat anything outside the range as unpainted.
        case none

        /// The tile style in force when a file doesn't say: ``TileStyle/wrap``.
        public static let `default` = Self.wrap
    }

    /// How a texture is sampled when it doesn't map one-to-one onto the output.
    enum Filter: String, Hashable, Sendable, XMLValueCodable {
        /// Leave the choice to the consumer. The default when a file doesn't say.
        case auto

        /// Interpolate between neighbouring pixels, for a smooth result.
        case linear

        /// Take the nearest pixel, keeping edges hard.
        case nearest

        /// The filter in force when a file doesn't say: ``Filter/auto``.
        public static let `default` = Self.auto
    }
}
