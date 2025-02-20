import Foundation
import Nodal

extension ExpandedName {
    var qualifiedNameWithStandardPrefix: String {
        if let namespaceName, let prefix = Namespace.namespace(for: namespaceName)?.standardPrefix {
            return prefix + ":" + localName
        } else {
            return localName
        }
    }
}

internal struct AttributeIdentifier: Hashable {
    let identifier: ExpandedName

    var qualifiedNameWithStandardPrefix: String { identifier.qualifiedNameWithStandardPrefix }

    // Attributes inherit the namespace of their element if unprefixed.
    // This is contrary to XML spec, but we need to follow the 3MF standard
    func name(in elementIdentifier: ElementIdentifier) -> String {
        if identifier.namespaceName == elementIdentifier.identifier.namespaceName {
            return identifier.localName
        } else {
            return qualifiedNameWithStandardPrefix
        }
    }
}

internal struct ElementIdentifier: Hashable {
    let identifier: ExpandedName

    var qualifiedNameWithStandardPrefix: String { identifier.qualifiedNameWithStandardPrefix }
}

internal protocol NamespaceSpecification {
    static var namespace: Namespace { get }
}

extension NamespaceSpecification {
    static func attribute(_ localName: String) -> ExpandedName {
        ExpandedName(namespaceName: namespace.uri, localName: localName)
    }

    static func element(_ localName: String) -> ExpandedName {
        ExpandedName(namespaceName: namespace.uri, localName: localName)
    }
}

extension XMLNode {
    var identifier: ElementIdentifier {
        .init(identifier: .init(namespaceName: uri ?? "", localName: localName ?? ""))
    }
}

internal struct XML: NamespaceSpecification {
    static let namespace = Namespace.xml
    static let lang = attribute("lang")
}
