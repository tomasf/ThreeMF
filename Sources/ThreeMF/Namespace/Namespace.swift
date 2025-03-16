import Foundation
import Nodal

public struct Namespace: Hashable, Sendable {
    public let uri: String
    internal let outputPrefix: String?

    internal init(uri: String, outputPrefix: String?) {
        self.uri = uri
        self.outputPrefix = outputPrefix
    }
}

internal extension Namespace {
    static var known: Set<Self> {
        [.core, .triangleSets, .mirroring, .materials, .volumetric, .implicit, .boolean, .displacement, .slice]
    }

    static func knownNamespace(for uri: String) -> Self? {
        return Self.known.first(where: { $0.uri == uri })
    }

    static func namespaces(forPrefixes prefixes: [String], in element: Node) -> Set<Namespace> {
        let namespaces = element.namespacesInScope

        return Set(prefixes.compactMap {
            namespaces[$0].map { Namespace.knownNamespace(for: $0) ?? Namespace(uri: $0, outputPrefix: nil) }
        })
    }
}

public extension Namespace {
    static let xml = Self(
        uri: "http://www.w3.org/XML/1998/namespace",
        outputPrefix: "xml"
    )

    static let core = Self(
        uri: "http://schemas.microsoft.com/3dmanufacturing/core/2015/02",
        outputPrefix: nil
    )

    static let triangleSets = Self(
        uri: "http://schemas.microsoft.com/3dmanufacturing/trianglesets/2021/07",
        outputPrefix: "t"
    )

    static let materials = Self(
        uri: "http://schemas.microsoft.com/3dmanufacturing/material/2015/02",
        outputPrefix: "m"
    )

    static let mirroring = Self(
        uri: "http://schemas.microsoft.com/3dmanufacturing/mirroring/2021/07",
        outputPrefix: "mm"
    )

    static let volumetric = Self(
        uri: "http://schemas.3mf.io/3dmanufacturing/volumetric/2022/01",
        outputPrefix: "v"
    )

    static let implicit = Self(
        uri: "http://schemas.3mf.io/3dmanufacturing/implicit/2023/12",
        outputPrefix: "i"
    )

    static let boolean = Self(
        uri: "http://schemas.3mf.io/3dmanufacturing/booleanoperations/2023/07",
        outputPrefix: "bo"
    )

    static let displacement = Self(
        uri: "http://schemas.3mf.io/3dmanufacturing/displacement/2023/10",
        outputPrefix: "d"
    )

    static let slice = Self(
        uri: "http://schemas.microsoft.com/3dmanufacturing/slice/2015/07",
        outputPrefix: "s"
    )
}

internal protocol NamespaceSpecification {
    static var namespace: Namespace { get }
}

extension NamespaceSpecification {
    static func attributeName(_ localName: String) -> ExpandedName {
        ExpandedName(namespaceName: namespace.uri, localName: localName)
    }

    static func elementName(_ localName: String) -> ExpandedName {
        ExpandedName(namespaceName: namespace.uri, localName: localName)
    }
}

internal struct XML: NamespaceSpecification {
    static let namespace = Namespace.xml
    static let lang = attributeName("lang")
}
