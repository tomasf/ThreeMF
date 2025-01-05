import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:texture2dgroup
public struct Texture2DGroup: Resource, XMLConvertibleNamed {
    static let elementName = "m:texture2dgroup"

    public var id: ResourceID
    public var texture2DID: ResourceID // "texid", points to a <texture2d>
    public var displayPropertiesID: ResourceID?  // Points to a <displayproperties>
    public var coordinates: [Coordinate]

    public init(id: ResourceID, texture2DID: ResourceID, displayPropertiesID: ResourceID? = nil, coordinates: [Coordinate]) {
        self.id = id
        self.texture2DID = texture2DID
        self.displayPropertiesID = displayPropertiesID
        self.coordinates = coordinates
    }
}

internal extension Texture2DGroup {
    var xmlElement: XMLElement {
        XMLElement("m:texture2dgroup", [
            "id": String(id),
            "texid": String(texture2DID),
            "displaypropertiesid": displayPropertiesID.map { String($0) }
        ], children: coordinates.map(\.xmlElement))
    }

    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement["id"]
        texture2DID = try xmlElement["texid"]
        displayPropertiesID = try? xmlElement["displaypropertiesid"]
        coordinates = try xmlElement[elements: "m:tex2coord"]
    }
}

public extension Texture2DGroup {
    // m:tex2coord
    struct Coordinate {
        public let u: Double
        public let v: Double

        init(u: Double, v: Double) {
            self.u = u
            self.v = v
        }
    }
}

extension Texture2DGroup.Coordinate: XMLConvertible {
    var xmlElement: XMLElement {
        XMLElement("m:tex2coord", [
            "u": String(u),
            "v": String(v),
        ])
    }

    init(xmlElement: XMLElement) throws(Error) {
        u = try xmlElement["u"]
        v = try xmlElement["v"]
    }
}

