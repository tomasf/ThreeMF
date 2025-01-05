import Foundation

internal extension Dictionary {
    static func +(lhs: Self, rhs: Self) -> Self {
        lhs.merging(rhs, uniquingKeysWith: { $1 })
    }
}

internal extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
