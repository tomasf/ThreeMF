import Foundation
import Nodal
import Zip

internal struct Relationships: Sendable {
    private var relationships: [Relationship] = []

    internal init() {}

    mutating func add(id: String? = nil, target: URL, type: String) {
        let resolvedID = id ?? "rel\(relationships.count + 1)"
        relationships.append(Relationship(target: target, id: resolvedID, typeURI: type))
    }

    func count(ofType relationshipType: String) -> Int {
        relationships.filter { $0.typeURI == relationshipType }.count
    }

    func firstTarget(ofType relationshipType: String) -> URL? {
        relationships.first { $0.typeURI == relationshipType }?.target
    }
}

extension Relationships {
    func xmlDocument() -> Document {
        let document = Document()
        let root = document.makeDocumentElement(name: "Relationships", defaultNamespace: "http://schemas.openxmlformats.org/package/2006/relationships")

        for relationship in relationships {
            relationship.appendElement(to: root)
        }

        return document
    }

    init(document: Document) throws {
        guard let root = document.documentElement,
              root.name == "Relationships" else {
            throw ThreeMFError.malformedRelationships(nil)
        }

        relationships = try root[elements: "Relationship"].map {
            try Relationship(element: $0)
        }
    }

    init<T>(zipArchive archive: ZipArchive<T>) throws(ThreeMFError) {
        do {
            let document = try Document(data: archive.fileContents(at: Self.archiveFileURL.relativePath))
            try self.init(document: document)
        } catch {
            throw .failedToReadArchiveFile(name: Self.archiveFileURL.relativePath, error: error)
        }
    }
}

fileprivate extension Relationships {
    struct Relationship: Sendable {
        let target: URL
        let id: String
        let typeURI: String

        init(target: URL, id: String, typeURI: String) {
            self.target = target
            self.id = id
            self.typeURI = typeURI
        }

        @discardableResult
        func appendElement(to parent: Node) -> Node {
            let element = parent.addElement("Relationship")
            element[attribute: "Target"] = target.relativePath
            element[attribute: "Id"] = id
            element[attribute: "Type"] = typeURI
            return element
        }

        init(element: Node) throws {
            self.id = try element.value(forAttribute: "Id")
            self.target = try element.value(forAttribute: "Target")
            self.typeURI = try element.value(forAttribute: "Type")
        }
    }
}

extension Relationships {
    static let archiveFileURL = URL(string: "_rels/.rels")!
}

