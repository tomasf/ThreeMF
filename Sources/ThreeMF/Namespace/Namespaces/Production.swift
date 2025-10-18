import Foundation
import Nodal

internal struct Production: NamespaceSpecification {
    static let namespace = Namespace.production

    static let path = attributeName("path")
    static let UUID = attributeName("UUID")
}

internal struct Alternatives: NamespaceSpecification {
    static let namespace = Namespace.alternatives

    static let alternatives = elementName("alternatives")
    static let alternative = elementName("alternative")

    static let modelResolution = attributeName("modelresolution")
}

public enum ModelResolution: String, Sendable, Hashable, XMLValueCodable {
    case full = "fullres"
    case low = "lowres"
    case obfuscated
}
