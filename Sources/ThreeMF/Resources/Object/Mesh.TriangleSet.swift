import Foundation
import Nodal

// t:triangleset
/// Named subsets of a mesh's triangles.
public extension Mesh {
    /// A named group of triangles within a mesh, from the triangle sets extension.
    ///
    /// Lets part of a mesh be referred to as a unit, such as a face to treat differently or a region
    /// to select, without splitting it into a separate object.
    struct TriangleSet: Sendable {
        let elementName: ExpandedName = TriangleSets.triangleSet

        /// A human-readable name for the set.
        public var name: String

        /// An identifier for the set, unique within its mesh.
        public var identifier: String

        /// The indices into ``Mesh/triangles`` that belong to this set.
        ///
        /// Written as ranges where the indices are contiguous, so a set covering a whole region stays compact.
        public var triangleIndices: IndexSet

        /// Creates a triangle set.
        /// - Parameters:
        ///   - name: A human-readable name for the set.
        ///   - identifier: An identifier for the set, unique within its mesh.
        ///   - triangleIndices: The indices into ``Mesh/triangles`` that belong to this set.
        public init(name: String, identifier: String, triangleIndices: IndexSet) {
            self.name = name
            self.identifier = identifier
            self.triangleIndices = triangleIndices
        }
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
