import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

internal extension XMLElement {
    // The built-in method for finding attributes does not seem to work
    // properly in swift-corelibs-foundation's FoundationXML
    func attributeValue(forName name: String) -> String? {
        attributes?.first(where: { $0.name == name })?.stringValue
    }

    // Attributes inherit the namespace of their element if unprefixed.
    // This is contrary to XML spec, but we need to follow the 3MF standard
    func attributeValue(localName: String, namespace uri: String) -> String? {
        attributes?.first(where: {
            $0.localName == localName && ($0.uri == uri || ($0.uri == nil && self.uri == uri))
        })?.stringValue
    }

    func element(localName: String, namespace uri: String) -> XMLElement? {
        children?.first(where: {
            $0.kind == .element && $0.localName == localName && $0.uri == uri
        }) as? XMLElement
    }

    func elements(localName: String, namespace uri: String) -> [XMLElement] {
        children?.compactMap {
            guard let element = $0 as? XMLElement else { return nil }
            guard element.localName == localName && element.uri == uri else { return nil }
            return element
        } ?? []
    }

    var elements: [XMLElement] {
        (children ?? []).compactMap { $0 as? XMLElement }
    }

    convenience init(
        _ elementID: ElementIdentifier,
        _ attributes: [AttributeIdentifier: (any XMLStringConvertible)?] = [:],
        children childElements: [(any XMLConvertible)?]? = nil,
        text: String? = nil
    ) {
        self.init(name: elementID.qualifiedNameWithStandardPrefix, uri: elementID.identifier.uri)
        if let childElements {
            setChildren(childElements.compactMap { $0?.xmlElement })
        }

        for (id, convertibleValue) in attributes {
            guard let value = convertibleValue?.xmlStringValue else {
                continue
            }
            if id.identifier.uri == elementID.identifier.uri {
                let attribute = (XMLNode.attribute(
                    withName: id.name(in: elementID),
                    stringValue: value
                ) as! XMLNode)
                addAttribute(attribute)
            } else {
                let attribute = (XMLNode.attribute(
                    withName: id.name(in: elementID),
                    uri: id.identifier.uri,
                    stringValue: value
                ) as! XMLNode)
                addAttribute(attribute)
            }
        }

        if let text {
            self.stringValue = text
        }
    }
}

internal extension XMLElement {
    func string(forAttribute attributeName: String) throws(Error) -> String {
        guard let string = attributeValue(forName: attributeName) else {
            throw Error.missingAttribute(name: attributeName)
        }
        return string
    }
}

internal extension XMLElement {
    subscript(attribute: String) -> String {
        get throws(Error) {
            try string(forAttribute: attribute)
        }
    }

    subscript<T: XMLStringConvertible>(attribute: String) -> T {
        get throws(Error) {
            try T(xmlString: string(forAttribute: attribute))
        }
    }

    subscript<T: XMLStringConvertible>(attribute: String) -> [T] {
        get throws(Error) {
            try string(forAttribute: attribute)
                .components(separatedBy: " ")
                .map { s throws(Error) in
                    try T(xmlString: s)
                }
        }
    }

    subscript<T: XMLStringConvertible>(attribute: String, default defaultValue: T) -> T {
        get throws(Error) {
            guard let s = try? string(forAttribute: attribute) else {
                return defaultValue
            }
            return try T(xmlString: s)
        }
    }
}

internal extension XMLElement {
    func elements<T>(named name: String, map: (XMLElement) throws(Error) -> T) throws(Error) -> [T] {
        try elements(forName: name).map { e throws(Error) in
            try map(e)
        }
    }

    subscript<T: XMLConvertible>(elements name: String) -> [T] {
        get throws(Error) {
            try elements(forName: name).map { e throws(Error) in
                try T(xmlElement: e)
            }
        }
    }

    subscript(element name: String) -> XMLElement {
        get throws(Error) {
            guard let childElement = elements(forName: name).first else {
                throw Error.missingElement(name: name)
            }
            return childElement
        }
    }

    func element(named name: String, where attributeName: String, is value: String) -> XMLElement? {
        elements(forName: name).first(where: {
            $0.attributeValue(forName: attributeName) == value
        })
    }
}

internal extension XMLNode {
    var urisInTree: Set<String> {
        var set: Set<String> = if let uri { [uri] } else { [] }
        for child in children ?? [] {
            set.formUnion(child.urisInTree)
        }
        return set
    }
}

internal extension XMLElement {
    func declareNamespace(_ uri: String, prefix: String? = nil) {
        addNamespace(XMLNode.namespace(withName: prefix ?? "", stringValue: uri) as! XMLNode)
    }
}

internal extension XMLElement {
    convenience init(_ name: String, _ attributes: [String: String?] = [:], children childElements: [XMLElement?]? = nil, text: String? = nil) {
        self.init(name: name)
        if let childElements {
            setChildren(childElements.compactMap { $0 })
        }
        setAttributesWith(attributes.compactMapValues { $0 })
        if let text {
            self.stringValue = text
        }
    }

    convenience init(
        _ name: String,
        _ attributes: [String: String?] = [:],
        children: [any XMLConvertible],
        text: String? = nil
    ) {
        self.init(name, attributes, children: children.map(\.xmlElement), text: text)
    }
}
