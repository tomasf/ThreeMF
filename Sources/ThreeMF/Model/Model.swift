import Foundation
import Nodal

@TaskLocal internal var requiredExtensions: Set<Namespace> = []

internal extension UUID {
    static var uuidIfProduction: UUID? {
        requiredExtensions.contains(.production) ? UUID() : nil
    }
}

public struct Model: Sendable, XMLElementCodable {
    public var unit: Unit?
    public var xmlLanguageCode: String?
    public var languageCode: String?

    public var requiredExtensions: Set<Namespace>
    public var recommendedExtensions: Set<Namespace>
    public var customNamespaces: [String: String]

    /// Attributes on the `<model>` element that aren't part of 3MF itself, preserved as they are.
    ///
    /// An attribute in a namespace needs a prefix for that namespace in ``customNamespaces``;
    /// writing a model that uses an undeclared namespace is a programmer error and traps.
    public var customAttributes: [ExpandedName: String]

    public var metadata: [Metadata]
    public var resources: ResourceContainer
    public var build: Build

    public init(
        unit: Unit? = nil,
        xmlLanguageCode: String? = nil,
        languageCode: String? = nil,
        requiredExtensions: Set<Namespace> = [],
        recommendedExtensions: Set<Namespace> = [],
        customNamespaces: [String: String] = [:], // Prefix: URI
        customAttributes: [ExpandedName: String] = [:],
        metadata: [Metadata] = [],
        resources: [any Resource] = [],
        build: Build
    ) {
        self.unit = unit
        self.xmlLanguageCode = xmlLanguageCode
        self.languageCode = languageCode
        self.requiredExtensions = requiredExtensions
        self.recommendedExtensions = recommendedExtensions
        self.customNamespaces = customNamespaces
        self.customAttributes = customAttributes

        self.metadata = metadata
        self.resources = ResourceContainer(resources: resources)
        self.build = build
    }

    public init(
        unit: Unit? = nil,
        xmlLanguageCode: String? = nil,
        languageCode: String? = nil,
        requiredExtensions: Set<Namespace> = [],
        recommendedExtensions: Set<Namespace> = [],
        customNamespaces: [String: String] = [:], // Prefix: URI
        customAttributes: [ExpandedName: String] = [:],
        metadata: [Metadata] = [],
        resources: [any Resource] = [],
        buildItems: [Item] = []
    ) {
        let build = Build(items: buildItems)
        self.init(unit: unit, xmlLanguageCode: xmlLanguageCode, languageCode: languageCode, requiredExtensions: requiredExtensions, recommendedExtensions: recommendedExtensions, customNamespaces: customNamespaces, customAttributes: customAttributes, metadata: metadata, resources: resources, build: build)
    }

    public func encode(to element: Node) {
        $requiredExtensions.withValue(requiredExtensions) {
            element.setValue(unit, forAttribute: .unit)
            element.setValue(xmlLanguageCode, forAttribute: XML.lang)
            element.setValue(languageCode, forAttribute: .language)
            // Sorted because these are sets: the prefixes are unordered, but the attribute they're
            // written into is a list, and it shouldn't come out differently on every run.
            element.setValue(requiredExtensions.compactMap(\.outputPrefix).sorted().nonEmpty, forAttribute: .requiredExtensions)
            element.setValue(recommendedExtensions.compactMap(\.outputPrefix).sorted().nonEmpty, forAttribute: .recommendedExtensions)
            for (name, value) in customAttributes.sortedByName {
                element.setValue(value, forAttribute: name)
            }

            element.encode(metadata, elementName: Core.metadata)
            element.encode(resources, elementName: Core.resources)
            element.encode(build, elementName: Core.build)
        }
    }

    public init(from element: Node) throws {
        unit = try element.value(forAttribute: .unit)
        xmlLanguageCode = try element.value(forAttribute: XML.lang)
        languageCode = try element.value(forAttribute: .language)

        if let requiredExtensionPrefixes: [String] = try element.value(forAttribute: .requiredExtensions) {
            requiredExtensions = Namespace.namespaces(forPrefixes: requiredExtensionPrefixes, in: element)
        } else {
            requiredExtensions = []
        }

        if let recommendedExtensionPrefixes: [String] = try element.value(forAttribute: .recommendedExtensions) {
            recommendedExtensions = Namespace.namespaces(forPrefixes: recommendedExtensionPrefixes, in: element)
        } else {
            recommendedExtensions = []
        }

        let knownNamespaces = Set(Namespace.known.map(\.uri))
        customNamespaces = element.declaredNamespaces.filter { $0 != nil && !knownNamespaces.contains($1) } as! [String: String]

        let knownAttributes: Set<ExpandedName> = [.unit, XML.lang, .language, .requiredExtensions, .recommendedExtensions]
        customAttributes = element.customAttributes(besides: knownAttributes)

        metadata = try element.decode(elementName: Core.metadata)
        resources = try element.decode(elementName: Core.resources)
        build = try element.decode(elementName: Core.build)
    }
}

public extension Model {
    /// The model as an XML document, with every namespace it uses declared on the root element.
    ///
    /// This is the `3dmodel.model` payload of a 3MF package. ``PackageWriter`` uses it to serialize
    /// the root model and each additional one; it's public so a model can also be written on its own,
    /// for instance into an archive that something else is assembling.
    func xmlDocument() -> Document {
        let modelDocument = Document(self, elementName: Core.model)

        // Both of these are unordered collections, so they're sorted before being declared: the
        // order the declarations go on in is the order they're written out in, and a model that
        // serialized differently from one run to the next would make packages irreproducible.
        for (prefix, uri) in customNamespaces.sorted(by: { $0.key < $1.key }) {
            modelDocument.documentElement?.declareNamespace(uri, forPrefix: prefix)
        }

        for namespaceName in modelDocument.undeclaredNamespaceNames.sorted() {
            guard let namespace = Namespace.knownNamespace(for: namespaceName) else {
                // Either a built-in namespace is missing from Namespace.known, or a custom attribute
                // uses a namespace the model never declared a prefix for — see Model.customAttributes.
                assertionFailure("Undeclared namespace \(namespaceName)")
                continue
            }
            modelDocument.documentElement?.declareNamespace(namespaceName, forPrefix: namespace.outputPrefix)
        }

        return modelDocument
    }
}
