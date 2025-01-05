import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

internal extension XMLElement {
    var elements: [XMLElement] {
        (children ?? []).compactMap { $0 as? XMLElement }
    }

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

    convenience init(_ name: String, _ attributes: [String: String?] = [:], children: [any XMLConvertible], text: String? = nil) {
        self.init(name, attributes, children: children.map(\.xmlElement), text: text)
    }
}

internal extension XMLElement {
    func elements<T>(named name: String, map: (XMLElement) throws(Error) -> T) throws(Error) -> [T] {
        try elements(forName: name).map { e throws(Error) in
            try map(e)
        }
    }
}

internal extension XMLElement {
    func string(forAttribute attributeName: String) throws(Error) -> String {
        guard let attribute = attribute(forName: attributeName),
              let string = attribute.stringValue else {
            throw Error.missingAttribute(name: attributeName, parentXPath: xPath ?? "")
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

    subscript(attribute: String) -> URL {
        get throws(Error) {
            let string = try string(forAttribute: attribute)
            guard let url = URL(string: string) else {
                throw .malformedAttribute(name: attribute, parentXPath: xPath ?? "")
            }
            return url
        }
    }

    subscript(attribute: String) -> Bool {
        get throws(Error) {
            let string = try string(forAttribute: attribute)
            if string == "true" || string == "1" { return true }
            if string == "false" || string == "0" { return false }
            throw Error.malformedAttribute(name: attribute, parentXPath: xPath ?? "")
        }
    }

    subscript(attribute: String) -> Double {
        get throws(Error) {
            guard let value = Double(try string(forAttribute: attribute)) else {
                throw Error.malformedAttribute(name: attribute, parentXPath: xPath ?? "")
            }
            return value
        }
    }

    subscript<T: StringConvertible>(attribute: String) -> T {
        get throws(Error) {
            try T(string: string(forAttribute: attribute))
        }
    }

    subscript<T: StringConvertible>(attribute: String) -> [T] {
        get throws(Error) {
            try string(forAttribute: attribute)
                .components(separatedBy: " ")
                .map { s throws(Error) in
                    try T(string: s)
                }
        }
    }

    subscript<T: StringConvertibleOptional>(attribute: String) -> T {
        get throws(Error) {
            try T(string: try? string(forAttribute: attribute))
        }
    }

    subscript<T: StringConvertible>(attribute: String, default defaultValue: T) -> T {
        get throws(Error) {
            guard let s = try? string(forAttribute: attribute) else {
                return defaultValue
            }
            return try T(string: s)
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
                throw Error.missingElement(name: name, parentXPath: xPath ?? "")
            }
            return childElement
        }
    }
}
