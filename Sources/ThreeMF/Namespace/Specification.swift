import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

internal struct NamespacedIdentifier: Hashable {
    let uri: String
    let localName: String

    init(uri: String, localName: String) {
        self.uri = uri
        self.localName = localName
    }

    init(namespace: Namespace, localName: String) {
        self.uri = namespace.uri
        self.localName = localName
    }

    var qualifiedNameWithStandardPrefix: String {
        if let prefix = Namespace.namespace(for: uri)?.standardPrefix {
            return prefix + ":" + localName
        } else {
            return localName
        }
    }
}

internal struct AttributeIdentifier: Hashable {
    let identifier: NamespacedIdentifier

    var qualifiedNameWithStandardPrefix: String { identifier.qualifiedNameWithStandardPrefix }

    // Attributes inherit the namespace of their element if unprefixed.
    // This is contrary to XML spec, but we need to follow the 3MF standard
    func name(in elementIdentifier: ElementIdentifier) -> String {
        if identifier.uri == elementIdentifier.identifier.uri {
            return identifier.localName
        } else {
            return qualifiedNameWithStandardPrefix
        }
    }
}

internal struct ElementIdentifier: Hashable {
    let identifier: NamespacedIdentifier

    var qualifiedNameWithStandardPrefix: String { identifier.qualifiedNameWithStandardPrefix }
}

internal protocol NamespaceSpecification {
    static var namespace: Namespace { get }
}

extension NamespaceSpecification {
    static func attribute(_ localName: String) -> AttributeIdentifier {
        .init(identifier: .init(namespace: namespace, localName: localName))
    }

    static func element(_ localName: String) -> ElementIdentifier {
        .init(identifier: .init(namespace: namespace, localName: localName))
    }
}

extension XMLNode {
    var identifier: ElementIdentifier {
        .init(identifier: .init(uri: uri ?? "", localName: localName ?? ""))
    }
}

internal struct XML: NamespaceSpecification {
    static let namespace = Namespace.xml
    static let lang = attribute("lang")
}
