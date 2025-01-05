import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// metadata
public struct Metadata {
    let name: Name
    let value: String
    let preserve: Bool?
    let type: String?

    init(name: Name, value: String, preserve: Bool = false, type: String? = nil) {
        self.name = name
        self.value = value
        self.preserve = preserve
        self.type = type
    }

    enum Name: Hashable {
        case title
        case designer
        case description
        case copyright
        case licenseTerms
        case rating
        case creationDate
        case modificationDate
        case application
        case custom (String)

        var key: String {
            switch self {
            case .title: "Title"
            case .designer: "Designer"
            case .description: "Description"
            case .copyright: "Copyright"
            case .licenseTerms: "LicenseTerms"
            case .rating: "Rating"
            case .creationDate: "CreationDate"
            case .modificationDate: "ModificationDate"
            case .application: "Application"
            case .custom (let name): name
            }
        }

        init(key: String) {
            let wellknown: [Self] = [.title, .designer, .description, .copyright, .licenseTerms, .rating, .creationDate, .modificationDate, .application]
            if let match = wellknown.first(where: { $0.key == key }) {
                self = match
            } else {
                self = .custom(key)
            }
        }
    }
}

extension Metadata: XMLConvertible {
    var xmlElement: XMLElement {
        XMLElement("metadata", [
            "name": name.key,
            "preserve": preserve.map { $0 ? "1" : "0" },
            "type": type
        ], text: value)
    }

    init(xmlElement: XMLElement) throws(Error) {
        name = .init(key: try xmlElement["name"])
        preserve = (try? xmlElement["preserve"]) ?? false
        type = try? xmlElement["type"]
        value = xmlElement.stringValue ?? ""
    }
}

// metadatagroup
internal extension [Metadata] {
    var xmlElement: XMLElement? {
        isEmpty ? nil : XMLElement("metadatagroup", children: map(\.xmlElement))
    }

    init(xmlElement: XMLElement?) throws(Error) {
        if let xmlElement {
            self = try xmlElement[elements: "metadata"]
        } else {
            self = []
        }
    }
}
