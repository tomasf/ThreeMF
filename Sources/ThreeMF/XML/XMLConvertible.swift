import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

internal protocol XMLConvertible {
    var xmlElement: XMLElement { get }
    init(xmlElement: XMLElement) throws(Error)
}

internal protocol XMLElementComposable: XMLConvertible {
    static var elementIdentifier: ElementIdentifier { get }
    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] { get }
    var children: [(any XMLConvertible)?] { get }
    var text: String? { get }
}

extension XMLElementComposable {
    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] { [:] }
    var children: [(any XMLConvertible)?] { [] }
    var text: String? { nil }

    var xmlElement: XMLElement {
        XMLElement(Self.elementIdentifier, attributes, children: children, text: text)
    }
}

struct ElementSequence<S: Sequence>: XMLConvertible where S.Element: XMLConvertible {
    let elementIdentifier: ElementIdentifier
    let sequence: S

    var xmlElement: XMLElement {
        XMLElement(elementIdentifier, children: Array(sequence))
    }

    init(elementIdentifier: ElementIdentifier, sequence: S) {
        self.elementIdentifier = elementIdentifier
        self.sequence = sequence
    }

    init(xmlElement: XMLElement) throws(Error) {
        fatalError()
    }
}

extension Collection where Element: XMLConvertible {
    func wrapped(in id: ElementIdentifier) -> any XMLConvertible {
        ElementSequence(elementIdentifier: id, sequence: self)
    }

    func wrappedNonEmpty(in id: ElementIdentifier) -> (any XMLConvertible)? {
        isEmpty ? nil : ElementSequence(elementIdentifier: id, sequence: self)
    }
}

struct XMLLiteralElement: XMLConvertible {
    let element: XMLElement

    init(xmlElement: XMLElement) {
        self.element = xmlElement
    }

    var xmlElement: XMLElement { element }
}

extension XMLElement {
    var literal: XMLLiteralElement { .init(xmlElement: self) }
}
