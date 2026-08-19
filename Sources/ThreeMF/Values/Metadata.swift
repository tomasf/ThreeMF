import Foundation
import Nodal

// metadata
/// A named piece of information attached to a model, object or build item.
///
/// The spec defines a set of well-known names for things like the title and designer; anything else
/// goes in under a name of your own with ``Name/custom(_:)``.
public struct Metadata: Sendable, XMLElementCodable {
    /// What this piece of metadata is.
    public let name: Name

    /// Its value, as text.
    public let value: String

    /// Whether a consumer that edits the file should keep this entry even if it doesn't understand it.
    public let preserve: Bool?

    /// The type of ``value``, as an XML Schema type name, when it isn't plain text.
    public let type: String?

    /// Creates a piece of metadata.
    /// - Parameters:
    ///   - name: What the metadata is.
    ///   - value: Its value, as text.
    ///   - preserve: Whether an editing consumer should keep it.
    ///   - type: The XML Schema type of the value, if not plain text.
    public init(name: Name, value: String, preserve: Bool? = nil, type: String? = nil) {
        self.name = name
        self.value = value
        self.preserve = preserve
        self.type = type
    }

    /// The name of a piece of metadata.
    ///
    /// The cases other than ``custom(_:)`` are the names the 3MF spec defines; each is written in the
    /// spelling the spec gives it.
    public enum Name: Hashable, Sendable, XMLValueCodable {
        /// The model's title.
        case title

        /// Who designed the model.
        case designer

        /// A description of the model.
        case description

        /// The copyright notice.
        case copyright

        /// The terms the model is licensed under.
        case licenseTerms

        /// A rating for the model.
        case rating

        /// When the model was created.
        case creationDate

        /// When the model was last changed.
        case modificationDate

        /// The application that wrote the model.
        case application

        /// A name of your own, outside the set the spec defines. Namespace it to avoid clashing with
        /// other producers.
        case custom (String)

        public func xmlStringValue(for node: Node) -> String {
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

        public init(xmlStringValue string: String, for node: Node) throws {
            let wellknown: [Self] = [.title, .designer, .description, .copyright, .licenseTerms, .rating, .creationDate, .modificationDate, .application]
            if let match = wellknown.first(where: { $0.xmlStringValue(for: node) == string }) {
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
