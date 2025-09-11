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

extension URL: XMLValueCodable {
    public var xmlStringValue: String {
        relativePath
    }

    public init(xmlStringValue string: String) throws {
        guard let url = URL(string: string) else {
            throw XMLValueError.invalidFormat(expected: "URI", found: string)
        }
        self = url
    }
}
