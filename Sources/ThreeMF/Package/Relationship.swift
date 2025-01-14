import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

internal struct Relationships {
    private var relationships: [Relationship] = []

    internal init() {}

    mutating func add(id: String? = nil, target: URL, type: String) {
        let resolvedID = id ?? "rel\(relationships.count + 1)"
        relationships.append(Relationship(target: target, id: resolvedID, typeURI: type))
    }

    func count(ofType relationshipType: String) -> Int {
        relationships.filter { $0.typeURI == relationshipType }.count
    }
}

extension Relationships {
    func xmlDocument() -> XMLDocument {
        let rootElement = XMLElement("Relationships", children: relationships.map { relationship in
            XMLElement("Relationship", [
                "Target": relationship.target.relativePath,
                "Id": relationship.id,
                "Type": relationship.typeURI
            ])
        })
        rootElement.declareNamespace("http://schemas.openxmlformats.org/package/2006/relationships")
        return XMLDocument(rootElement: rootElement)
    }
}

fileprivate extension Relationships {
    struct Relationship {
        let target: URL
        let id: String
        let typeURI: String

        init(target: URL, id: String, typeURI: String) {
            self.target = target
            self.id = id
            self.typeURI = typeURI
        }
    }
}

extension Relationships {
    static let archiveFileURL = URL(string: "/_rels/.rels")!
}

