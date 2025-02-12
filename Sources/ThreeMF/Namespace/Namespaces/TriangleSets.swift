import Foundation
import Nodal

internal struct TriangleSets: NamespaceSpecification {
    static let namespace = Namespace.triangleSets

    // Elements
    static let triangleSets = element("trianglesets")
    static let triangleSet = element("triangleset")
    static let ref = element("ref")
    static let refRange = element("refrange")

    // Attributes
    static let index = attribute("index")
    static let startIndex = attribute("startindex")
    static let endIndex = attribute("endindex")

    static let name = attribute("name")
    static let identifier = attribute("identifier")
}

extension AttributeIdentifier {
    static let t = TriangleSets.self
}

extension ElementIdentifier {
    static let t = TriangleSets.self
}
