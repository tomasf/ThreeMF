import Foundation
import Nodal

internal protocol XMLConvertible {
    func build(element: Node)
    init(xmlElement: Node) throws(Error)
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

    func build(element: Node) {
        element.expandedName = Self.elementIdentifier.identifier

        for (id, convertibleValue) in attributes {
            guard let value = convertibleValue?.xmlStringValue else {
                continue
            }
            let effectiveName: ExpandedName
            if id.identifier.namespaceName == Self.elementIdentifier.identifier.namespaceName {
                effectiveName = ExpandedName(namespaceName: nil, localName: id.identifier.localName)
            } else {
                effectiveName = id.identifier
            }

            element[attribute: effectiveName] = value
        }

        for child in (children.compactMap { $0 }) {
            let childElement = element.addElement("")
            child.build(element: childElement)
        }

        if let text {
            element.addText(text)
        }
    }
}

struct ElementSequence<S: Sequence>: XMLConvertible where S.Element: XMLConvertible {
    let elementIdentifier: ElementIdentifier
    let sequence: S

    func build(element: Node) {
        element.expandedName = elementIdentifier.identifier
        for child in sequence {
            let childElement = element.addElement("")
            child.build(element: childElement)
        }
    }

    init(elementIdentifier: ElementIdentifier, sequence: S) {
        self.elementIdentifier = elementIdentifier
        self.sequence = sequence
    }

    init(xmlElement: Node) throws(Error) {
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
