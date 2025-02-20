import Foundation
import Nodal

public extension Mesh {
    struct Triangle: Hashable, XMLElementCodable {
        @Attribute(.v1) public let v1: ResourceIndex
        @Attribute(.v2) public let v2: ResourceIndex
        @Attribute(.v3) public let v3: ResourceIndex

        @Attribute(.pid) public let propertyIndex: Index?
        @Attribute(.pid) public let propertyGroup: ResourceID?

        public init(v1: ResourceIndex, v2: ResourceIndex, v3: ResourceIndex, propertyIndex: Index?, propertyGroup: ResourceID? = nil) {
            self.v1 = v1
            self.v2 = v2
            self.v3 = v3
            self.propertyIndex = propertyIndex
            self.propertyGroup = propertyGroup
        }

        public func encode(to element: Node) {
            element.setValue(v1, forAttribute: .v1)
            element.setValue(v2, forAttribute: .v2)
            element.setValue(v3, forAttribute: .v3)
            propertyIndex?.encode(to: element)
            element.setValue(propertyGroup, forAttribute: .pid)
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

public extension Mesh.Triangle {
    enum Index: Hashable {
        case uniform (ResourceIndex)
        case perVertex (ResourceIndex, ResourceIndex, ResourceIndex)

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
        guard let p1: ResourceIndex = try? element.value(forAttribute: .p1) else {
            return nil
        }

        if let p2: ResourceIndex = try? element.value(forAttribute: .p1),
           let p3: ResourceIndex = try? element.value(forAttribute: .p2) {
            self = .perVertex(p1, p2, p3)
        } else {
            self = .uniform(p1)
        }
    }

    public func encode(to element: Node) {
        switch self {
        case .uniform (let index):
            element.setValue(index, forAttribute: .p1)

        case .perVertex (let p1, let p2, let p3):
            element.setValue(p1, forAttribute: .p1)
            element.setValue(p2, forAttribute: .p2)
            element.setValue(p3, forAttribute: .p3)
        }
    }
}

public extension Mesh.Triangle {
    func resolvedProperties(in object: Object) -> [PropertyReference]? {
        guard let groupID = propertyGroup ?? object.propertyGroupID else {
            return nil
        }

        switch propertyIndex {
        case .perVertex (let p1, let p2, let p3):
            return [p1, p2, p3].map { PropertyReference(groupID: groupID, index: $0) }

        case .uniform (let index):
            return [PropertyReference(groupID: groupID, index: index)]

        case .none:
            if let index = object.propertyIndex {
                return [PropertyReference(groupID: groupID, index: index)]
            } else {
                return nil
            }
        }
    }
}
