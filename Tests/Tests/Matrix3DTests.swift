import Testing
import Nodal
@testable import ThreeMF

struct Matrix3DTests {
    // Values chosen to survive xmlStringValue's "%g" (6-significant-digit) formatting exactly,
    // so this test is a genuine round trip rather than being confounded by precision loss.
    @Test func `matrix with %g-safe values round trips exactly`() throws {
        let matrix = Matrix3D(values: [[1, 2, 3], [4, 5, -6], [7.5, 0, 100], [0, -0.25, 12]])
        let decoded = try roundTrip(matrix)
        #expect(decoded.values == matrix.values)
    }

    // Characterization test: xmlStringValue truncates to 6 significant digits via "%g", so this
    // documents the current lossy behavior deliberately rather than letting it regress silently.
    @Test func `encoding truncates to 6 significant digits`() throws {
        let matrix = Matrix3D(values: [[1.0 / 3.0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]])
        let encoded = matrix.xmlStringValue(for: try scratchNode())
        #expect(encoded.contains("0.333333"))
        #expect(encoded.contains("0.3333333333333333") == false)

        let decoded = try roundTrip(matrix)
        #expect(decoded.values[0][0] == 0.333333)
        #expect(decoded.values[0][0] != 1.0 / 3.0)
    }

    @Test func `fewer than 12 numbers throws invalidFormat`() {
        let elevenNumbers = Array(repeating: "1", count: 11).joined(separator: " ")
        #expect(throws: XMLValueError.self) {
            try decodeAttribute(Matrix3D.self, from: elevenNumbers)
        }
    }

    // 12 space-separated tokens, but one is non-numeric: compactMap(Double.init) silently drops it,
    // so the resulting count (11) still trips the count check rather than throwing immediately.
    @Test func `non-numeric token among 12 throws invalidFormat`() {
        var tokens = Array(repeating: "1", count: 12)
        tokens[5] = "abc"
        #expect(throws: XMLValueError.self) {
            try decodeAttribute(Matrix3D.self, from: tokens.joined(separator: " "))
        }
    }

    @Test func `wrong shape triggers a precondition failure`() async {
        await #expect(processExitsWith: .failure) {
            _ = Matrix3D(values: [[1, 2, 3]])
        }
    }
}

private func scratchNode() throws -> Node {
    let document = Document()
    return document.makeDocumentElement(name: "test")
}
