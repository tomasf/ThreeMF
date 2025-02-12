import Foundation
import Nodal

internal struct ContentTypes: Sendable {
    private var items: [Item] = []

    internal init() {}

    mutating func add(mimeType: String, for fileExtension: String) {
        items.append(.default(fileExtension: fileExtension, mimeType: mimeType))
    }

    mutating func add(mimeType: String, for part: URL) {
        items.append(.override(part: part, mimeType: mimeType))
    }

    private enum Item {
        case `default` (fileExtension: String, mimeType: String)
        case override (part: URL, mimeType: String)
    }
}

extension ContentTypes {
    func xmlDocument() -> Document {
        let document = Document()
        let root = document.makeDocumentElement(name: "Types", defaultNamespace: "http://schemas.openxmlformats.org/package/2006/content-types")

        for item in items {
            switch item {
            case .default (let fileExtension, let mimeType):
                let child = root.addElement("Default")
                child[attribute: "ContentType"] = mimeType
                child[attribute: "Extension"] = fileExtension
            case .override (let part, let mimeType):
                let child = root.addElement("Override")
                child[attribute: "PartName"] = part.relativePath
                child[attribute: "ContentType"] = mimeType
            }
        }
        return document
    }
}

internal extension ContentTypes {
    static let archiveFileURL = URL(string: "/[Content_Types].xml")!
}
