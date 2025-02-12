import Foundation
import Nodal

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
    func xmlDocument() -> Document {
        let document = Document()
        let root = document.makeDocumentElement(name: "Relationships", defaultNamespace: "http://schemas.openxmlformats.org/package/2006/relationships")

        for relationship in relationships {
            let element = root.addElement("Relationship")
            element[attribute: "Target"] = relationship.target.relativePath
            element[attribute: "Id"] = relationship.id
            element[attribute: "Type"] = relationship.typeURI
        }

        return document
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

