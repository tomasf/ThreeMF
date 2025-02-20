import Foundation
import Nodal

internal protocol XMLStringConvertible {
    var xmlStringValue: String { get }
    init (xmlString: String) throws(Error)
}
/*
extension RawRepresentable<String> {
    var xmlStringValue: String { rawValue }

    init(xmlString: String) throws(Error) {
        guard let element = Self(rawValue: xmlString) else {
            throw .malformedAttributeValue(xmlString)
        }
        self = element
    }
}
*/
extension Sequence where Element: XMLStringConvertible {
    var string: String {
        map { $0.xmlStringValue }.joined(separator: " ")
    }
}

extension Int: XMLStringConvertible {
    var xmlStringValue: String {
        String(self)
    }

    init(xmlString: String) throws(Error) {
        guard let int = Int(xmlString) else {
            throw .malformedInteger(xmlString)
        }
        self = int
    }
}

extension Double: XMLStringConvertible {
    var xmlStringValue: String {
        String(self)
    }

    init(xmlString: String) throws(Error) {
        guard let int = Double(xmlString) else {
            throw .malformedInteger(xmlString)
        }
        self = int
    }
}

extension String: XMLStringConvertible {
    var xmlStringValue: String { self }
    init(xmlString: String) throws(Error) { self = xmlString }
}


extension Bool: XMLStringConvertible {
    var xmlStringValue: String {
        self ? "1" : "0"
    }

    init(xmlString: String) throws(Error) {
        if xmlString == "true" || xmlString == "1" { self = true }
        else if xmlString == "false" || xmlString == "0" { self = false }
        else {
            throw .malformedAttributeValue(xmlString)
        }
    }
}
