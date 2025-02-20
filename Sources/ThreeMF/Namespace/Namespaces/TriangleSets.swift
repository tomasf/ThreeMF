import Foundation
import Nodal

internal struct TriangleSets: NamespaceSpecification {
    static let namespace = Namespace.triangleSets

    static let triangleSets = element("trianglesets")
    static let triangleSet = element("triangleset")
    static let ref = element("ref")
    static let refRange = element("refrange")
}
