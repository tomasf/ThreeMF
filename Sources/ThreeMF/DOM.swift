import Foundation
import Nodal

// Element ID -> String
extension Node {
    subscript(element: ElementIdentifier) -> Node {
        get throws(Error) {
            guard let result = self[element: element.identifier] else {
                throw .missingElement(name: element.identifier)
            }
            return result
        }
    }

    subscript(elements: ElementIdentifier) -> [Node] {
        self[elements: elements.identifier]
    }
}

// Element ID -> XMLConvertible
extension Node {
    subscript<T: XMLConvertible>(element: ElementIdentifier) -> T {
        get throws(Error) {
            let element: Node = try self[element]
            return try T(xmlElement: element)
        }
    }

    subscript<T: XMLConvertible>(_ id: ElementIdentifier) -> [T] {
        get throws(Error) {
            let elements: [Node] = self[id]
            return try elements.map { e throws(Error) in try T(xmlElement: e) }
        }
    }
}

// Attribute ID -> String
extension Node {
    subscript(attribute: AttributeIdentifier) -> String {
        get throws(Error) {
            // If the namespace matches the element, then the attribute may also appear unprefixed. Yay, 3MF.
            if attribute.identifier.namespaceName == self.expandedName.namespaceName {
                let alternativeName = ExpandedName(namespaceName: nil, localName: attribute.identifier.localName)
                if let alternativeValue = self[attribute: alternativeName] {
                    return alternativeValue
                }
            }
            guard attribute.identifier.namespaceName != defaultNamespaceName else {
                // Attribute has default namespace, but wasn't found unprefixed. It must be missing.
                throw .missingAttribute(name: attribute.identifier)
            }
            guard let value = self[attribute: attribute.identifier] else {
                throw .missingAttribute(name: attribute.identifier)
            }
            return value
        }
    }
}

// Attribute ID -> XMLStringConvertible
extension Node {
    subscript<T: XMLStringConvertible>(attribute: AttributeIdentifier) -> T {
        get throws(Error) {
            let string: String = try self[attribute]
            return try T(xmlString: string)
        }
    }

    subscript<T: XMLStringConvertible>(attribute: AttributeIdentifier) -> [T] {
        get throws(Error) {
            let string: String = try self[attribute]
            return try string.split(separator: " ").map { i throws(Error) in try T(xmlString: String(i)) }
        }
    }

    subscript<T: XMLStringConvertible>(attribute: AttributeIdentifier) -> Set<T> {
        get throws(Error) {
            Set(try self[attribute] as [T])
        }
    }
}

extension Node {
    var identifier: ElementIdentifier {
        .init(identifier: expandedName)
    }
}
