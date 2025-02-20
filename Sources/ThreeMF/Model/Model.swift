import Foundation
import Nodal

public struct Model: XMLElementCodable {
    public var unit: Unit?
    public var xmlLanguageCode: String?
    public var languageCode: String?
    public var requiredExtensionPrefixes: Set<Extension.Prefix>?
    public var recommendedExtensionPrefixes: Set<Extension.Prefix>?

    public var metadata: [Metadata]
    public var resources: ResourceContainer
    public var buildItems: [Item]

    public init(
        unit: Unit? = nil,
        xmlLanguageCode: String? = nil,
        languageCode: String? = nil,
        requiredExtensionPrefixes: Set<Extension.Prefix>? = nil,
        recommendedExtensionPrefixes: Set<Extension.Prefix>? = nil,
        metadata: [Metadata] = [],
        resources: [any Resource] = [],
        buildItems: [Item] = []
    ) {
        self.unit = unit
        self.xmlLanguageCode = xmlLanguageCode
        self.languageCode = languageCode
        self.requiredExtensionPrefixes = requiredExtensionPrefixes
        self.recommendedExtensionPrefixes = recommendedExtensionPrefixes

        self.metadata = metadata
        self.resources = ResourceContainer(resources: resources)
        self.buildItems = buildItems
    }

    public func encode(to element: Node) {
        element.setValue(unit, forAttribute: .unit)
        element.setValue(xmlLanguageCode, forAttribute: XML.lang)
        element.setValue(languageCode, forAttribute: .language)
        element.setValue(requiredExtensionPrefixes.map { Array($0) }, forAttribute: .requiredExtensions)
        element.setValue(recommendedExtensionPrefixes.map { Array($0) }, forAttribute: .recommendedExtensions)
        element.encode(metadata, elementName: Core.metadata)
        element.encode(resources, elementName: Core.resources)
        element.encode(buildItems, elementName: Core.item, containedIn: Core.build)
    }

    public init(from element: Node) throws {
        unit = try element.value(forAttribute: .unit)
        xmlLanguageCode = try element.value(forAttribute: XML.lang)
        languageCode = try element.value(forAttribute: .language)
        requiredExtensionPrefixes = try element.value(forAttribute: .requiredExtensions).map { Set($0) }
        recommendedExtensionPrefixes = try element.value(forAttribute: .recommendedExtensions).map { Set($0) }
        metadata = try element.decode(elementName: Core.metadata)
        resources = try element.decode(elementName: Core.resources)
        buildItems = try element.decode(elementName: Core.item, containedIn: Core.build)
    }
}
