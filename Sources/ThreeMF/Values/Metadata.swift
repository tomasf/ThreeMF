import Foundation
import Nodal

// metadata
public struct Metadata: XMLElementCodable {
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

    public enum Name: Hashable, XMLValueCodable {
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

        public var xmlStringValue: String {
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

        public init(xmlStringValue string: String) {
            let wellknown: [Self] = [.title, .designer, .description, .copyright, .licenseTerms, .rating, .creationDate, .modificationDate, .application]
            if let match = wellknown.first(where: { $0.xmlStringValue == string }) {
                self = match
            } else {
                self = .custom(string)
            }
        }
    }

    public func encode(to element: Node) {
        element.setValue(name, forAttribute: .name)
        element.setContent(value)
        element.setValue(preserve, forAttribute: .preserve)
        element.setValue(type, forAttribute: .type)
    }

    public init(from element: Node) throws {
        name = try element.value(forAttribute: .name)
        value = try element.content()
        preserve = try element.value(forAttribute: .preserve)
        type = try element.value(forAttribute: .type)
    }
}
