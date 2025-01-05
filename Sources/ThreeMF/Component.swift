import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// component
public struct Component {
    public var objectID: ResourceID
    public var transform: Matrix3D?
}

extension Component: XMLConvertible {
    init(xmlElement: XMLElement) throws(Error) {
        objectID = try xmlElement["id"]
        transform = try? xmlElement["transform"]
    }

    var xmlElement: XMLElement {
        XMLElement("component", [
            "objectid": String(objectID),
            "transform": transform?.string
        ])
    }
}

// components
internal extension [Component] {
    var xmlElement: XMLElement {
        XMLElement("components", children: map(\.xmlElement))
    }

    init(xmlElement: XMLElement) throws(Error) {
        self = try xmlElement[elements: "components"]
    }
}
