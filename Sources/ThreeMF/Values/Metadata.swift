import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// metadata
public struct Metadata {
    public let name: Name
    public let value: String
    public let preserve: Bool?
    public let type: String?

    public init(name: Name, value: String, preserve: Bool = false, type: String? = nil) {
        self.name = name
        self.value = value
        self.preserve = preserve
        self.type = type
    }

    public enum Name: Hashable, XMLStringConvertible {
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

        var xmlStringValue: String {
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

        init(xmlString: String) {
            let wellknown: [Self] = [.title, .designer, .description, .copyright, .licenseTerms, .rating, .creationDate, .modificationDate, .application]
            if let match = wellknown.first(where: { $0.xmlStringValue == xmlString }) {
                self = match
            } else {
                self = .custom(xmlString)
            }
        }
    }
}

extension Metadata: XMLElementComposable {
    static let elementIdentifier = Core.metadata

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            Core.name: name,
            Core.preserve: preserve,
            Core.type: type
        ]
    }

    var text: String? { value }

    init(xmlElement: XMLElement) throws(Error) {
        name = try xmlElement[Core.name]
        preserve = try? xmlElement[Core.preserve]
        type = try? xmlElement[Core.type]
        value = xmlElement.stringValue ?? ""
    }
}
