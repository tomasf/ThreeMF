import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public extension Mesh {
    struct Triangle: Hashable {
        public let v1: ResourceIndex
        public let v2: ResourceIndex
        public let v3: ResourceIndex

        public let propertyIndex: Index?
        public let propertyGroup: ResourceID?

        public init(v1: ResourceIndex, v2: ResourceIndex, v3: ResourceIndex, propertyIndex: Index?, propertyGroup: ResourceID? = nil) {
            self.v1 = v1
            self.v2 = v2
            self.v3 = v3
            self.propertyIndex = propertyIndex
            self.propertyGroup = propertyGroup
        }
    }
}

extension Mesh.Triangle: XMLElementComposable {
    static let elementIdentifier = Core.triangle

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            Core.v1: v1,
            Core.v2: v2,
            Core.v3: v3,
            Core.pid: propertyGroup
        ] + (propertyIndex?.attributes ?? [:])
    }

    init(xmlElement: XMLElement) throws(Error) {
        v1 = try xmlElement[Core.v1]
        v2 = try xmlElement[Core.v2]
        v3 = try xmlElement[Core.v3]
        propertyGroup = try? xmlElement[Core.pid]
        propertyIndex = Index(triangleXMLElement: xmlElement)
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
    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        switch self {
        case .uniform (let index):
            return [Core.p1: String(index)]
        case .perVertex (let v1, let v2, let v3):
            return [
                Core.p1: String(v1),
                Core.p2: String(v2),
                Core.p3: String(v3)
            ]
        }
    }

    init?(triangleXMLElement: XMLElement) {
        guard let p1: ResourceIndex = try? triangleXMLElement[Core.p1] else {
            return nil
        }

        if let p2: ResourceIndex = try? triangleXMLElement[Core.p2],
           let p3: ResourceIndex = try? triangleXMLElement[Core.p3] {
            self = .perVertex(p1, p2, p3)
        } else {
            self = .uniform(p1)
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
