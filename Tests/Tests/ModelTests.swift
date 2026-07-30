import Testing
@testable import ThreeMF

struct ModelTests {
    @Test func `model round trips with every top-level field populated`() throws {
        let model = Model(
            unit: .centimeter,
            xmlLanguageCode: "en-US",
            languageCode: "en",
            metadata: [Metadata(name: .title, value: "A model")],
            resources: [meshObject(id: 1)],
            buildItems: [Item(objectID: 1)]
        )
        let decoded = try roundTrip(model)
        #expect(decoded.unit == .centimeter)
        #expect(decoded.xmlLanguageCode == "en-US")
        #expect(decoded.languageCode == "en")
        #expect(decoded.metadata.map(\.value) == ["A model"])
        #expect(decoded.resources.resources.count == 1)
        #expect(decoded.resources.resources.first?.id == 1)
        #expect(decoded.build.items.map(\.objectID) == [1])
    }

    @Test func `minimal model round trips to an equivalent minimal model`() throws {
        let model = Model(build: Build(items: []))
        let decoded = try roundTrip(model)
        #expect(decoded.unit == nil)
        #expect(decoded.resources.resources.isEmpty)
        #expect(decoded.build.items.isEmpty)
    }

    // xml:lang (a namespaced attribute) and the plain "language" attribute are distinct fields on
    // the wire — use different values for each so an accidental aliasing between them is caught.
    @Test func `xmlLanguageCode and languageCode round trip independently`() throws {
        let model = Model(xmlLanguageCode: "en-US", languageCode: "sv", build: Build(items: []))
        let decoded = try roundTrip(model)
        #expect(decoded.xmlLanguageCode == "en-US")
        #expect(decoded.languageCode == "sv")
    }
}
