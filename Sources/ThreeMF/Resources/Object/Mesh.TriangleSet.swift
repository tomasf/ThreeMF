import Foundation
import Nodal

// t:triangleset
public extension Mesh {
    struct TriangleSet {
        let elementName: ExpandedName = TriangleSets.triangleSet

        public var name: String
        public var identifier: String
        public var triangleIndices: IndexSet
    }
}

extension Mesh.TriangleSet: XMLElementCodable {
    public func encode(to xmlElement: Node) {
        xmlElement.setValue(name, forAttribute: .name)
        xmlElement.setValue(identifier, forAttribute: .identifier)

        for range in triangleIndices.rangeView {
            let rangeElement = xmlElement.addElement("")
            if range.count == 1 {
                rangeElement.expandedName = TriangleSets.ref
                rangeElement.setValue(range.lowerBound, forAttribute: .index)
            } else {
                rangeElement.expandedName = TriangleSets.refRange
                rangeElement.setValue(range.lowerBound, forAttribute: .startIndex)
                rangeElement.setValue(range.upperBound, forAttribute: .endIndex)
            }
        }
    }

    public init(from xmlElement: Node) throws {
        name = try xmlElement.value(forAttribute: .name)
        identifier = try xmlElement.value(forAttribute: .identifier)

        triangleIndices = []

        for element in xmlElement[elements: TriangleSets.ref] {
            triangleIndices.insert(try element.value(forAttribute: .index))
        }
        for element in xmlElement[elements: TriangleSets.refRange] {
            let range = try (element.value(forAttribute: .startIndex) as Int)..<(element.value(forAttribute: .endIndex) as Int)
            triangleIndices.insert(integersIn: range)
        }
    }
}
