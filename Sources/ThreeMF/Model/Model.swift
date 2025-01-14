import Foundation
import Zip
#if canImport(FoundationXML)
import FoundationXML
#endif

public struct Model {
    public var unit: Unit?
    public var xmlLanguageCode: String?
    public var languageCode: String?
    public var requiredExtensionPrefixes: Set<Extension.Prefix>?
    public var recommendedExtensionPrefixes: Set<Extension.Prefix>?
    public var metadata: [Metadata]
    public var resources: [any Resource]
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
        self.resources = resources
        self.buildItems = buildItems
    }
}

public extension Model {
    func resource(for id: ResourceID) -> (any Resource)? {
        resources.first(where: { $0.id == id })
    }

    var nextFreeResourceID: ResourceID {
        (resources.map(\.id).max() ?? 0) + 1
    }

    mutating func add(resource: any Resource) -> ResourceID {
        var mutable = resource
        mutable.id = nextFreeResourceID
        resources.append(mutable)
        return resource.id
    }
}

extension Model: XMLElementComposable {
    static let elementIdentifier = Core.model
    
    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            Core.unit: unit,
            XML.lang: xmlLanguageCode,
            Core.language: languageCode,
            Core.requiredExtensions: requiredExtensionPrefixes?.string,
            Core.recommendedExtensions: recommendedExtensionPrefixes?.string
        ]
    }

    var children: [(any XMLConvertible)?] {
        guard let xmlConvertibles = resources as? [any XMLConvertible] else {
            fatalError("Resources must conform to XMLCConvertible")
        }
        return [
            XMLElement(Core.resources, children: xmlConvertibles).literal,
            buildItems.wrapped(in: Core.build),
        ]
    }

#warning("temp")
    public init(xmlElement element: XMLElement) throws(Error) {
        unit = try? element[Core.unit]
        xmlLanguageCode = try? element[XML.lang]
        languageCode = try? element[Core.language]
        requiredExtensionPrefixes = try? element[Core.requiredExtensions]
        recommendedExtensionPrefixes = try? element[Core.recommendedExtensions]

        metadata = try element[Core.metadata]

        let resourcesElement: XMLElement = try element[Core.resources]

        self.resources = try resourcesElement.elements.map { e throws(Error) in
            guard let resourceType = resourceTypePerElementIdentifier[e.identifier] else {
                return nil // Unknown resource element type
            }
            return try resourceType.init(xmlElement: e)
        }.compactMap { $0 }

        buildItems = try element[Core.build][Core.item]
    }
}
