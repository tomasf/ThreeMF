import Testing
import Nodal
@testable import ThreeMF

struct ColorTests {
    @Test func `opaque color round trips`() throws {
        let color = Color(red: 0x12, green: 0x34, blue: 0x56)
        let decoded = try roundTrip(color)
        #expect(decoded.red == 0x12)
        #expect(decoded.green == 0x34)
        #expect(decoded.blue == 0x56)
        #expect(decoded.alpha == 0xFF)
    }

    // Four distinct byte values, so a component transposition bug (e.g. red/alpha swapped) would be caught.
    @Test func `translucent color round trips with distinct components`() throws {
        let color = Color(red: 0x11, green: 0x22, blue: 0x33, alpha: 0x44)
        let decoded = try roundTrip(color)
        #expect(decoded.red == 0x11)
        #expect(decoded.green == 0x22)
        #expect(decoded.blue == 0x33)
        #expect(decoded.alpha == 0x44)
    }

    @Test func `encode uses lowercase hex`() throws {
        let document = Document()
        let root = document.makeDocumentElement(name: "test")
        #expect(Color(red: 0xFF, green: 0, blue: 0).xmlStringValue(for: root) == "#ff0000")
    }

    @Test func `decode accepts uppercase hex`() throws {
        let color = try decodeAttribute(Color.self, from: "#FF00FF")
        #expect(color.red == 0xFF)
        #expect(color.green == 0x00)
        #expect(color.blue == 0xFF)
    }

    @Test func `decode without leading hash throws`() {
        #expect(throws: XMLValueError.self) {
            try decodeAttribute(Color.self, from: "ff0000")
        }
    }

    @Test(arguments: ["#fff", "#fffff"])
    func `decode with wrong digit count throws`(hexString: String) {
        #expect(throws: XMLValueError.self) {
            try decodeAttribute(Color.self, from: hexString)
        }
    }

    @Test func `decode with non-hex characters throws`() {
        #expect(throws: XMLValueError.self) {
            try decodeAttribute(Color.self, from: "#zzzzzz")
        }
    }

    @Test func `white is fully opaque white`() {
        #expect(Color.white == Color(red: 0xFF, green: 0xFF, blue: 0xFF))
    }

    @Test func `isOpaque reflects alpha`() {
        #expect(Color(red: 0, green: 0, blue: 0, alpha: 0xFF).isOpaque)
        #expect(Color(red: 0, green: 0, blue: 0, alpha: 0xFE).isOpaque == false)
    }
}
