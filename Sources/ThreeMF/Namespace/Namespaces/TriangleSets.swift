import Foundation
import Nodal

internal struct TriangleSets: NamespaceSpecification {
    static let namespace = Namespace.triangleSets

    static let triangleSets = elementName("trianglesets")
    static let triangleSet = elementName("triangleset")
    static let ref = elementName("ref")
    static let refRange = elementName("refrange")
}
