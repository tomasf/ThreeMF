import Foundation
import Nodal
@testable import ThreeMF

// Round-trips a value through the XMLValueCodable protocol via a scratch attribute,
// exercising the exact xmlStringValue(for:)/init(xmlStringValue:for:) path production code uses.
func roundTrip<T: XMLValueCodable>(_ value: T) throws -> T {
    let document = Document()
    let root = document.makeDocumentElement(name: "test")
    root.setValue(value, forAttribute: "value")
    return try root.value(forAttribute: "value")
}

// Decodes a raw attribute string directly, for malformed-input tests.
func decodeAttribute<T: XMLValueDecodable>(_ type: T.Type, from string: String) throws -> T {
    let document = Document()
    let root = document.makeDocumentElement(name: "test")
    root.appendValue(string, forAttribute: "value")
    return try root.value(forAttribute: "value")
}

// Builds a scratch document whose root has the 3MF core namespace declared as the default
// namespace, matching what PackageWriter sets up for a real <model> root. This matters for types
// that encode child elements via bare (unprefixed) names as a performance optimization (Mesh's
// vertices/triangles) — those only resolve back through a namespace-qualified decode lookup if a
// default namespace is actually in scope, same as in a real written package.
private func scratchDocument(elementName: String) -> Document {
    let document = Document()
    document.makeDocumentElement(name: elementName, defaultNamespace: Namespace.core.uri)
    return document
}

// Round-trips a value through the XMLElementCodable protocol using an in-memory Node tree only
// (no text serialization) — fast, and adequate whenever escaping/whitespace isn't in question.
func roundTrip<T: XMLElementCodable>(_ value: T, elementName: String = "test") throws -> T {
    let document = scratchDocument(elementName: elementName)
    value.encode(to: document.documentElement!)
    return try document.decoded(as: T.self)
}

// Round-trips a value through actual XML text (encode -> xmlData() -> parse -> decode),
// for cases where escaping of special characters (&, <, >, quotes, unicode) matters.
func roundTripThroughText<T: XMLElementCodable>(_ value: T, elementName: String = "test") throws -> T {
    let document = scratchDocument(elementName: elementName)
    value.encode(to: document.documentElement!)
    let data = try document.xmlData()
    return try Document(data: data).decoded(as: T.self)
}

// Like roundTrip, but encodes the value onto a *child* of the namespaced root rather than the
// root itself. Needed for types (like Item) whose decode enumerates every raw attribute on their
// own element (e.g. to recover unknown/custom attributes) — encoding straight onto the root would
// pick up the root's own "xmlns" declaration as a spurious "custom" attribute, which never happens
// in a real document since these types are always nested under a namespace-declaring ancestor, not
// the ancestor itself.
func roundTripAsChild<T: XMLElementCodable>(_ value: T, elementName: String = "child") throws -> T {
    let document = scratchDocument(elementName: "parent")
    let child = document.documentElement!.addElement(elementName)
    value.encode(to: child)
    return try T.init(from: child)
}
