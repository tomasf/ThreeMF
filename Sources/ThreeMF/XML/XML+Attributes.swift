import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

internal extension XMLElement {
    subscript(attribute: AttributeIdentifier) -> String {
        get throws(Error) {
            guard let value = attributeValue(
                localName: attribute.identifier.localName,
                namespace: attribute.identifier.uri
            ) else {
                throw .missingAttribute(name: attribute.identifier.localName)
            }
            return value
        }
    }

    subscript<T: XMLStringConvertible>(attribute: AttributeIdentifier) -> T {
        get throws(Error) {
            return try T(xmlString: self[attribute])
        }
    }

    subscript<T: XMLStringConvertible>(attribute: AttributeIdentifier) -> [T] {
        get throws(Error) {
            try self[attribute]
                .components(separatedBy: " ")
                .map { s throws(Error) in
                    try T(xmlString: s)
                }
        }
    }

    subscript<T: XMLStringConvertible & Hashable>(attribute: AttributeIdentifier) -> Set<T> {
        get throws(Error) {
            try Set(self[attribute] as [T])
        }
    }
}
