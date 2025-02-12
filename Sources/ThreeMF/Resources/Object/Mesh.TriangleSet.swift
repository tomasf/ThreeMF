import Foundation
import Nodal

// t:triangleset
public extension Mesh {
    struct TriangleSet {
        public var name: String
        public var identifier: String
        public var triangleIndices: IndexSet
    }
}

extension Mesh.TriangleSet: XMLElementComposable {
    static let elementIdentifier = TriangleSets.triangleSet

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            .t.name: name,
            .t.identifier: identifier
        ]
    }

    var children: [(any XMLConvertible)?] {
        triangleIndices.rangeView.map {
            if $0.count == 1 {
                LiteralElement(name: .t.ref, attributes: [.t.index: $0.lowerBound])
            } else {
                LiteralElement(name: .t.refRange, attributes: [.t.startIndex: $0.lowerBound, .t.endIndex: $0.upperBound])
            }
        }
    }

    init(xmlElement: Node) throws(Error) {
        name = try xmlElement[.t.name]
        identifier = try xmlElement[.t.identifier]

        triangleIndices = []

        for element in xmlElement[.t.ref] {
            triangleIndices.insert(try element[.t.index])
        }
        for element in xmlElement[.t.refRange] {
            let range = try (element[.t.startIndex] as Int)..<(element[.t.endIndex] as Int)
            triangleIndices.insert(integersIn: range)
        }
    }
}
