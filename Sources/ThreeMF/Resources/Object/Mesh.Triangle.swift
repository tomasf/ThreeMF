import Foundation
import Nodal

/// A mesh's triangles.
public extension Mesh {
    /// One triangle of a mesh, as three vertex indices and optional material properties.
    ///
    /// The winding order of `v1`, `v2` and `v3` gives the triangle its facing: counter-clockwise seen
    /// from outside the solid.
    struct Triangle: Hashable, Sendable, XMLElementCodable {
        /// The index of the first vertex in ``Mesh/vertices``.
        public let v1: ResourceIndex

        /// The index of the second vertex.
        public let v2: ResourceIndex

        /// The index of the third vertex.
        public let v3: ResourceIndex

        /// Which entry of the property group this triangle uses, either one for the whole triangle or one
        /// per vertex. `nil` falls back to the object's own property.
        public let propertyIndex: Index?

        /// The property group ``propertyIndex`` refers into. `nil` uses the object's ``Object/propertyGroupID``.
        public let propertyGroup: ResourceID?

        /// Creates a triangle.
        /// - Parameters:
        ///   - v1: The index of the first vertex.
        ///   - v2: The index of the second vertex.
        ///   - v3: The index of the third vertex.
        ///   - propertyIndex: The properties to use, or `nil` to inherit the object's.
        ///   - propertyGroup: The group the property index refers into.
        public init(v1: ResourceIndex, v2: ResourceIndex, v3: ResourceIndex, propertyIndex: Index?, propertyGroup: ResourceID? = nil) {
            self.v1 = v1
            self.v2 = v2
            self.v3 = v3
            self.propertyIndex = propertyIndex
            self.propertyGroup = propertyGroup
        }

        public func encode(to element: Node) {
            element.appendValue(String(v1), forAttribute: "v1")
            element.appendValue(String(v2), forAttribute: "v2")
            element.appendValue(String(v3), forAttribute: "v3")
            propertyIndex?.encode(to: element)
            if let propertyGroup {
                element.appendValue(String(propertyGroup), forAttribute: "pid")
            }
        }

        public init(from element: Node) throws {
            v1 = try element.value(forAttribute: .v1)
            v2 = try element.value(forAttribute: .v2)
            v3 = try element.value(forAttribute: .v3)
            propertyIndex = .init(from: element)
            propertyGroup = try element.value(forAttribute: .pid)
        }
    }
}

/// How a triangle picks its material properties.
public extension Mesh.Triangle {
    /// Which entry of a property group a triangle uses.
    ///
    /// One index applies to the whole triangle; three interpolate across it, for gradients and texture
    /// coordinates.
    enum Index: Hashable, Sendable {
        /// One property for the whole triangle.
        case uniform (ResourceIndex)

        /// One property per vertex, interpolated across the triangle, in the same order as `v1`, `v2`, `v3`.
        case perVertex (ResourceIndex, ResourceIndex, ResourceIndex)

        /// The three indices this resolves to, repeating the single one for ``uniform(_:)``.
        public var indices: [ResourceIndex] {
            switch self {
            case .uniform (let index): return [index, index, index]
            case .perVertex (let p1, let p2, let p3): return [p1, p2, p3]
            }
        }
    }
}

internal extension Mesh.Triangle.Index {
    var p1: String {
        switch self {
        case .uniform (let index): String(index)
        case .perVertex (let p1, _, _): String(p1)
        }
    }

    var p2: String? {
        switch self {
        case .uniform: nil
        case .perVertex (_, let p2, _): String(p2)
        }
    }

    var p3: String? {
        switch self {
        case .uniform: nil
        case .perVertex (_, _, let p3): String(p3)
        }
    }
}

extension Mesh.Triangle.Index {
    public init?(from element: Node) {
        // Check attribute presence with the plain (non-throwing) accessor before decoding:
        // p1/p2/p3 are absent on the vast majority of triangles (per-vertex property indices
        // are a rarely-used feature), and routing that common "missing" case through the
        // throwing `value(forAttribute:)` API means constructing and discarding a Swift error
        // for essentially every triangle in a typical mesh.
        guard element[attribute: .p1] != nil,
              let p1: ResourceIndex = try? element.value(forAttribute: .p1)
        else {
            return nil
        }

        if element[attribute: .p2] != nil, element[attribute: .p3] != nil,
           let p2: ResourceIndex = try? element.value(forAttribute: .p2),
           let p3: ResourceIndex = try? element.value(forAttribute: .p3) {
            self = .perVertex(p1, p2, p3)
        } else {
            self = .uniform(p1)
        }
    }

    public func encode(to element: Node) {
        switch self {
        case .uniform (let index):
            element.appendValue(String(index), forAttribute: "p1")

        case .perVertex (let p1, let p2, let p3):
            element.appendValue(String(p1), forAttribute: "p1")
            element.appendValue(String(p2), forAttribute: "p2")
            element.appendValue(String(p3), forAttribute: "p3")
        }
    }
}

