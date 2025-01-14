import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

internal struct Core: NamespaceSpecification {
    static let namespace = Namespace.core

    // Elements
    static let model = element("model")
    static let metadata = element("metadata")
    static let metadataGroup = element("metadatagroup")
    static let resources = element("resources")
    static let build = element("build")
    static let item = element("item")

    static let mesh = element("mesh")
    static let triangles = element("triangles")
    static let vertex = element("vertex")
    static let vertices = element("vertices")
    static let triangle = element("triangle")
    static let object = element("object")
    static let component = element("component")
    static let components = element("components")
    static let baseMaterials = element("basematerials")
    static let base = element("base")

    // Attributes
    static let id = attribute("id")
    static let name = attribute("name")
    static let type = attribute("type")

    static let thumbnail = attribute("thumbnail")
    static let partNumber = attribute("partnumber")
    static let displayColor = attribute("displaycolor")

    static let unit = attribute("unit")
    static let language = attribute("language")
    static let requiredExtensions = attribute("requiredextensions")
    static let recommendedExtensions = attribute("recommendedextensions")

    static let preserve = attribute("preserve")
    static let transform = attribute("transform")
    static let objectID = attribute("objectid")

    static let v1 = attribute("v1")
    static let v2 = attribute("v2")
    static let v3 = attribute("v3")

    static let x = attribute("x")
    static let y = attribute("y")
    static let z = attribute("z")

    static let pid = attribute("pid")
    static let pIndex = attribute("pindex")
    static let p1 = attribute("p1")
    static let p2 = attribute("p2")
    static let p3 = attribute("p3")

    // This is a Prusa extension. It should live in its own proper namespace, but alas, it does not
    static let printable = attribute("printable")
}

extension AttributeIdentifier {
    static let core = Core.self
}

extension ElementIdentifier {
    static let core = Core.self
}

