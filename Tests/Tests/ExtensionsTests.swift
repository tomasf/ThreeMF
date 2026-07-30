import Testing
@testable import ThreeMF

struct ExtensionsTests {
    @Test(arguments: [
        (5.0, "5"),
        (-3.0, "-3"),
        (0.0, "0"),
        (1.5, "1.5"),
        (0.1, "0.1"),
        (1_000_000.0, "1000000"),
    ])
    func `compactXMLString formats whole numbers without a decimal point`(value: Double, expected: String) {
        #expect(value.compactXMLString == expected)
    }

    @Test func `subscript safe returns element in range`() {
        #expect([10, 20, 30][safe: 1] == 20)
    }

    @Test func `subscript safe returns nil for negative index`() {
        #expect([10, 20, 30][safe: -1] == nil)
    }

    @Test func `subscript safe returns nil for out-of-range index`() {
        #expect([10, 20, 30][safe: 3] == nil)
    }

    @Test func `nonEmpty returns nil for empty collections`() {
        let empty: [Int] = []
        #expect(empty.nonEmpty == nil)
    }

    @Test func `nonEmpty returns itself for non-empty collections`() {
        #expect([1, 2].nonEmpty == [1, 2])
    }

    @Test func `dictionary plus lets the right-hand side win on key collisions`() {
        let merged = ["a": 1, "b": 2] + ["b": 20, "c": 3]
        #expect(merged == ["a": 1, "b": 20, "c": 3])
    }

    // asyncMap is the one concurrency-bearing utility in the package; its whole contract is
    // "preserves input order despite out-of-order completion," so this deliberately makes later
    // elements finish first to stress that guarantee rather than only exercising a trivial identity map.
    @Test func `asyncMap preserves input order even when completion order is scrambled`() async throws {
        let input = Array(0..<10)
        let result = try await input.asyncMap { value -> Int in
            try await Task.sleep(nanoseconds: UInt64(10 - value) * 1_000_000)
            return value * 2
        }
        #expect(result == input.map { $0 * 2 })
    }
}
