import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// t:triangleset
public extension Mesh {
    struct TriangleSet {
        public var name: String
        public var identifier: String
        public var triangleIndices: IndexSet
    }
}

extension Mesh.TriangleSet: XMLConvertible {
    var xmlElement: XMLElement {
        XMLElement("t:triangleset", [
            "name": name,
            "identifier": identifier
        ], children: refs)
    }

    var refs: [XMLElement] {
        triangleIndices.rangeView.map {
            if $0.count == 1 {
                XMLElement("t:ref", ["index": String($0.lowerBound)])
            } else {
                XMLElement("t:refrange", ["startindex": String($0.lowerBound), "endindex": String($0.upperBound)])
            }
        }
    }

    init(xmlElement: XMLElement) throws(Error) {
        name = try xmlElement["name"]
        identifier = try xmlElement["identifier"]

        triangleIndices = []
        for element in xmlElement.elements(forName: "t:ref") {
            triangleIndices.insert(try element["index"])
        }
        for element in xmlElement.elements(forName: "t:refrange") {
            let range = try (element["startindex"] as Int)..<(element["endindex"] as Int)
            triangleIndices.insert(integersIn: range)
        }
    }
}

// t:trianglesets
internal extension [Mesh.TriangleSet] {
    var xmlElement: XMLElement? {
        isEmpty ? nil : XMLElement("trianglesets", children: map(\.xmlElement))
    }

    init(xmlElement: XMLElement) throws(Error) {
        self = try xmlElement[elements: "triangleset"]
    }
}
