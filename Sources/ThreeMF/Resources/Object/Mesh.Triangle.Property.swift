import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public extension Mesh.Triangle {
    struct Property: Hashable {
        public let groupID: ResourceID
        public let index: Index

        public enum Index: Hashable {
            case uniform (ResourceIndex)
            case perVertex (ResourceIndex, ResourceIndex, ResourceIndex)

            public var indicesPerVertex: (ResourceIndex, ResourceIndex, ResourceIndex) {
                switch self {
                case .uniform (let index): return (index, index, index)
                case .perVertex (let p1, let p2, let p3): return (p1, p2, p3)
                }
            }
        }
    }
}

internal extension Mesh.Triangle.Property {
    var xmlAttributes: [String: String] {
        switch index {
        case .uniform (let index):
            return ["pid": String(index), "p1": String(index)]
        case .perVertex (let v1, let v2, let v3):
            return ["pid": String(v1), "p1": String(v1), "p2": String(v2), "p3": String(v3)]
        }
    }

    init?(triangleXMLElement: XMLElement) {
        guard let groupID: ResourceID = try? triangleXMLElement["pid"],
              let p1: ResourceIndex = try? triangleXMLElement["p1"] else {
            return nil
        }
        self.groupID = groupID

        if let p2: ResourceIndex = try? triangleXMLElement["p2"],
           let p3: ResourceIndex = try? triangleXMLElement["p3"] {
            index = .perVertex(p1, p2, p3)
        } else {
            index = .uniform(p1)
        }
    }
}
