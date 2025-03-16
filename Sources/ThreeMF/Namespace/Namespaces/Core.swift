import Foundation
import Nodal

internal struct Core: NamespaceSpecification {
    static let namespace = Namespace.core

    static let model = elementName("model")
    static let metadata = elementName("metadata")
    static let metadataGroup = elementName("metadatagroup")
    static let resources = elementName("resources")
    static let build = elementName("build")
    static let item = elementName("item")

    static let mesh = elementName("mesh")
    static let triangles = elementName("triangles")
    static let vertex = elementName("vertex")
    static let vertices = elementName("vertices")
    static let triangle = elementName("triangle")
    static let object = elementName("object")
    static let component = elementName("component")
    static let components = elementName("components")
    static let baseMaterials = elementName("basematerials")
    static let base = elementName("base")
}
