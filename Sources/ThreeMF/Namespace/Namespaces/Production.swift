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

/// How exact an object's geometry is, from the alternatives extension.
public enum ModelResolution: String, Sendable, Hashable, XMLValueCodable {
    /// The real geometry, at full precision.
    case full = "fullres"

    /// A reduced-precision version, for preview or for sharing with less detail.
    case low = "lowres"

    /// Geometry deliberately degraded so it can be shown but not reproduced.
    case obfuscated
}
