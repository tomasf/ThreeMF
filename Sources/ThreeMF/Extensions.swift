import Foundation
import Nodal

internal extension Dictionary {
    static func +(lhs: Self, rhs: Self) -> Self {
        lhs.merging(rhs, uniquingKeysWith: { $1 })
    }
}

internal extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    var nonEmpty: Self? {
        isEmpty ? nil : self
    }
}

internal extension Double {
    /// Prints integral values without a decimal point or exponent, avoiding needless bytes for
    /// the mesh coordinates and indices that land on whole numbers
    var compactXMLString: String {
        if let integer = Int64(exactly: self) {
            return String(integer)
        }
        return description
    }
}

internal extension URL {
    /// Identifies a part within a package: the path with any leading slash removed, which is also
    /// the form the ZIP archive keys its entries by.
    ///
    /// `/3D/3dmodel.model` and `3D/3dmodel.model` name the same part, so anything that decides
    /// whether two URLs refer to the same file — staged files, content types, relationships — has
    /// to compare this rather than the URLs themselves.
    var packagePartPath: String {
        var path = relativePath
        if path.hasPrefix("/") {
            path.removeFirst()
        }
        return path
    }

    /// The OPC part name for this URL: the part path made absolute.
    ///
    /// Part names are required to start with a slash, so this is the form content type overrides
    /// have to be written in, whichever way the URL that named the part was spelled.
    var packagePartName: String {
        "/" + packagePartPath
    }
}

extension Collection where Element: Sendable {
    func asyncMap<T: Sendable>(_ transform: @Sendable @escaping (Element) async throws -> T) async rethrows -> [T] {
        try await withThrowingTaskGroup(of: (Int, T).self) { group in
            for (index, element) in self.enumerated() {
                group.addTask {
                    let value = try await transform(element)
                    return (index, value)
                }
            }

            var results = Array<T?>(repeating: nil, count: self.count)
            for try await (index, result) in group {
                results[index] = result
            }

            return results.map { $0! }
        }
    }
}

