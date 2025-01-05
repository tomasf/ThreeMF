import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public typealias ResourceID = Int
public typealias ResourceIndex = Int
public typealias ResourceIndices = [ResourceIndex]
public typealias Numbers = [Double]

public enum Error: Swift.Error {
    case failedToReadArchiveFile (name: String, error: Swift.Error?)
    case malformedRelationships ((any Swift.Error)?)

    case missingElement (name: String, parentXPath: String)
    case missingAttribute (name: String, parentXPath: String)

    case malformedAttribute (name: String, parentXPath: String)
    case malformedTransform (String)
    case malformedColorString (String)
    case malformedNumbers (String)
    case malformedIndices (String)
    case malformedBlendMethod (String)
    case malformedURI (String)
    case malformedInteger (String)

    case malformedAttributeValue (String)
}

internal protocol XMLConvertible {
    var xmlElement: XMLElement { get }
    init(xmlElement: XMLElement) throws(Error)
}

internal protocol XMLConvertibleNamed: XMLConvertible {
    static var elementName: String { get }
}

internal protocol StringConvertible {
    var string: String { get }
    init (string: String) throws(Error)
}

internal protocol StringConvertibleOptional {
    var string: String? { get }
    init (string: String?) throws(Error)
}

extension RawRepresentable<String> {
    var string: String { rawValue }

    init(string: String) throws(Error) {
        guard let element = Self(rawValue: string) else {
            throw .malformedAttributeValue(string)
        }
        self = element
    }
}

extension Sequence where Element: StringConvertible {
    var string: String {
        map { $0.string }.joined(separator: " ")
    }
}

extension Int: StringConvertible {
    var string: String {
        String(self)
    }

    init(string: String) throws(Error) {
        guard let int = Int(string) else {
            throw .malformedInteger(string)
        }
        self = int
    }
}

extension Double: StringConvertible {
    var string: String {
        String(self)
    }

    init(string: String) throws(Error) {
        guard let int = Double(string) else {
            throw .malformedInteger(string)
        }
        self = int
    }
}

extension String: StringConvertible {
    var string: String { self }
    init(string: String) throws(Error) { self = string }
}

