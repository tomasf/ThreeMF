import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

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
    func xmlDocument() -> XMLDocument {
        let root = XMLElement("Types", children: items.map { item in
            switch item {
            case .default (let fileExtension, let mimeType):
                XMLElement("Default", [
                    "ContentType": mimeType,
                    "Extension": fileExtension
                ])
            case .override(let part, let mimeType):
                XMLElement("Override", [
                    "PartName": part.relativePath,
                    "ContentType": mimeType
                ])
            }
        })

        root.declareNamespace("http://schemas.openxmlformats.org/package/2006/content-types")
        return XMLDocument(rootElement: root)
    }
}

internal extension ContentTypes {
    static let archiveFileURL = URL(string: "/[Content_Types].xml")!
}
