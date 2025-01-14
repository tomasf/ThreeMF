import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

internal extension XMLElement {
    subscript(_ elementID: ElementIdentifier) -> XMLElement {
        get throws(Error) {
            guard let match = self.element(
                localName: elementID.identifier.localName,
                namespace: elementID.identifier.uri
            ) else {
                throw .missingElement(name: elementID.identifier.localName)
            }
            return match
        }
    }

    subscript(elements: ElementIdentifier) -> [XMLElement] {
        self.elements(
            localName: elements.identifier.localName,
            namespace: elements.identifier.uri
        )
    }

    subscript<T: XMLConvertible>(element: ElementIdentifier) -> T {
        get throws(Error) {
            return try T(xmlElement: self[element])
        }
    }

    subscript<T: XMLConvertible>(elements: ElementIdentifier) -> [T] {
        get throws(Error) {
            try (self[elements] as [XMLElement]).map { e throws(Error) in
                try T(xmlElement: e)
            }
        }
    }

    subscript<T: XMLConvertible & Hashable>(elements: ElementIdentifier) -> Set<T> {
        get throws(Error) {
            try Set(self[elements] as [T])
        }
    }
}
