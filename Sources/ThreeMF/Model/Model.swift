import Foundation
import Nodal

public struct Model: Sendable, XMLElementCodable {
    public var unit: Unit?
    public var xmlLanguageCode: String?
    public var languageCode: String?

    public var requiredExtensions: Set<Namespace>
    public var recommendedExtensions: Set<Namespace>
    public var customNamespaces: [String: String]

    public var metadata: [Metadata]
    public var resources: ResourceContainer
    public var buildItems: [Item]

    public init(
        unit: Unit? = nil,
        xmlLanguageCode: String? = nil,
        languageCode: String? = nil,
        requiredExtensions: Set<Namespace> = [],
        recommendedExtensions: Set<Namespace> = [],
        customNamespaces: [String: String] = [:], // Prefix: URI
        metadata: [Metadata] = [],
        resources: [any Resource] = [],
        buildItems: [Item] = []
    ) {
        self.unit = unit
        self.xmlLanguageCode = xmlLanguageCode
        self.languageCode = languageCode
        self.requiredExtensions = requiredExtensions
        self.recommendedExtensions = recommendedExtensions
        self.customNamespaces = customNamespaces

        self.metadata = metadata
        self.resources = ResourceContainer(resources: resources)
        self.buildItems = buildItems
    }

    public func encode(to element: Node) {
        element.setValue(unit, forAttribute: .unit)
        element.setValue(xmlLanguageCode, forAttribute: XML.lang)
        element.setValue(languageCode, forAttribute: .language)
        element.setValue(requiredExtensions.compactMap(\.outputPrefix).nonEmpty, forAttribute: .requiredExtensions)
        element.setValue(recommendedExtensions.compactMap(\.outputPrefix).nonEmpty, forAttribute: .recommendedExtensions)
        element.encode(metadata, elementName: Core.metadata)
        element.encode(resources, elementName: Core.resources)
        element.encode(buildItems, elementName: Core.item, containedIn: Core.build)
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
        customNamespaces = element.declaredNamespaces.filter { $0 != nil && knownNamespaces.contains($1) } as! [String: String]

        metadata = try element.decode(elementName: Core.metadata)
        resources = try element.decode(elementName: Core.resources)
        buildItems = try element.decode(elementName: Core.item, containedIn: Core.build)
    }
}
