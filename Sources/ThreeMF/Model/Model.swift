import Foundation
import Zip
#if canImport(FoundationXML)
import FoundationXML
#endif

public struct Model {
    public var unit: Unit?
    public var languageCode: String?
    public var requiredExtensionPrefixes: Set<Extension.Prefix>?
    public var recommendedExtensionPrefixes: Set<Extension.Prefix>?
    public var metadata: [Metadata]
    public var resources: [any Resource]
    public var buildItems: [Item]

    init(
        unit: Unit? = nil,
        languageCode: String? = nil,
        requiredExtensionPrefixes: Set<Extension.Prefix>? = nil,
        recommendedExtensionPrefixes: Set<Extension.Prefix>? = nil,
        metadata: [Metadata] = [],
        resources: [any Resource] = [],
        buildItems: [Item] = []
    ) {
        self.unit = unit
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

internal extension Model {
    var resourcesElement: XMLElement {
        guard let xmlConvertibles = resources as? [any XMLConvertible] else {
            fatalError("Resources must conform to XMLCConvertible")
        }
        return XMLElement("resources", children: xmlConvertibles.map(\.xmlElement))
    }

    var xmlElement: XMLElement {
        XMLElement("model", [
            "unit": unit?.rawValue,
            "language": languageCode,
            "requiredextensions": requiredExtensionPrefixes?.string,
            "recommendedextensions": recommendedExtensionPrefixes?.string,
        ], children: metadata.map(\.xmlElement) + [
            resourcesElement,
            XMLElement("build", children: buildItems.map(\.xmlElement))
        ])
    }

    init(xmlElement element: XMLElement) throws(Error) {
        unit = try? element["unit"]
        languageCode = try? element["language"]
        requiredExtensionPrefixes = (try? element["requiredextensions"]).map { Set($0) }
        recommendedExtensionPrefixes = (try? element["recommendedextensions"]).map { Set($0) }

        metadata = try element[elements: "metadata"]

        let resourcesElement = try element[element: "resources"]

        self.resources = try resourcesElement.elements.map { element throws(Error) in
            guard let resourceType = resourceTypePerElementName[element.name ?? ""] else {
                return nil // Unknown resource element type
            }
            return try resourceType.init(xmlElement: element)
        }.compactMap { $0 }

        buildItems = try element[element: "build"][elements: "item"]
    }
}
