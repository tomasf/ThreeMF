import Foundation
import Nodal

internal struct Core: NamespaceSpecification {
    static let namespace = Namespace.core

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
}
