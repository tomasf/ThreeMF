import Testing
import Nodal
@testable import ThreeMF

struct MetadataTests {
    @Test(arguments: [
        (Metadata.Name.title, "Title"),
        (.designer, "Designer"),
        (.description, "Description"),
        (.copyright, "Copyright"),
        (.licenseTerms, "LicenseTerms"),
        (.rating, "Rating"),
        (.creationDate, "CreationDate"),
        (.modificationDate, "ModificationDate"),
        (.application, "Application"),
    ])
    func `well-known name round trips through its wire string`(name: Metadata.Name, wireValue: String) throws {
        let document = Document()
        let root = document.makeDocumentElement(name: "test")
        #expect(name.xmlStringValue(for: root) == wireValue)
        #expect(try roundTrip(name) == name)
    }

    @Test func `custom name round trips to itself`() throws {
        #expect(try roundTrip(Metadata.Name.custom("MyThing")) == .custom("MyThing"))
    }

    // Encoding always produces the fixed capitalized strings above; decoding compares with a
    // literal == against those exact strings, so a lowercase match (e.g. "title") doesn't hit any
    // well-known case and comes back as .custom instead, an easy-to-miss encode/decode asymmetry.
    @Test func `lowercase well-known name decodes as custom, not the matching case`() throws {
        #expect(try decodeAttribute(Metadata.Name.self, from: "title") == .custom("title"))
    }

    @Test func `full element round trips with every field populated`() throws {
        let metadata = Metadata(name: .custom("MyField"), value: "some value", preserve: true, type: "xs:string")
        let decoded = try roundTrip(metadata)
        #expect(decoded.name == metadata.name)
        #expect(decoded.value == metadata.value)
        #expect(decoded.preserve == true)
        #expect(decoded.type == "xs:string")
    }

    @Test func `preserve and type default to nil`() throws {
        let metadata = Metadata(name: .title, value: "x")
        let decoded = try roundTrip(metadata)
        #expect(decoded.preserve == nil)
        #expect(decoded.type == nil)
    }

    // Only roundTripThroughText goes through actual text serialization/parsing, where escaping matters.
    @Test func `content survives special characters through real XML text`() throws {
        let value = "Tomás \"3MF\" <v1> & Ω"
        let metadata = Metadata(name: .title, value: value)
        let decoded = try roundTripThroughText(metadata)
        #expect(decoded.value == value)
    }
}
