import Foundation
import Nodal

// metadata
@XMLCodable
public struct Metadata {
    @Attribute(.name) public let name: Name
    @TextContent public let value: String
    @Attribute(.preserve) public let preserve: Bool?
    @Attribute(.type) public let type: String?

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
}
