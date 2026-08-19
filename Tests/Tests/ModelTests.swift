import Testing
import Nodal
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
    // the wire, so use different values for each and an accidental aliasing between them is caught.
    @Test func `xmlLanguageCode and languageCode round trip independently`() throws {
        let model = Model(xmlLanguageCode: "en-US", languageCode: "sv", build: Build(items: []))
        let decoded = try roundTrip(model)
        #expect(decoded.xmlLanguageCode == "en-US")
        #expect(decoded.languageCode == "sv")
    }

    @Test func `custom attributes on the model round trip`() throws {
        let plainAttribute = ExpandedName(namespaceName: nil, localName: "vendorflag")
        let namespacedAttribute = ExpandedName(namespaceName: "http://example.com/x", localName: "custom")
        let model = Model(
            customAttributes: [plainAttribute: "on", namespacedAttribute: "value"],
            build: Build(items: [])
        )
        let decoded = try roundTrip(model)
        #expect(decoded.customAttributes == [plainAttribute: "on", namespacedAttribute: "value"])
    }

    // Namespace declarations sit among an element's attributes, and <model> is the element that
    // carries them all, so collecting unrecognized attributes has to leave them alone.
    @Test func `namespace declarations are not collected as custom attributes`() throws {
        var model = Model(build: Build(items: []))
        model.customNamespaces = ["ext": "http://example.com/custom"]
        let decoded = try roundTrip(model)
        #expect(decoded.customAttributes.isEmpty)
    }

    // The known-attribute exclusion matches whole expanded names, so an attribute that shares a
    // known local name but sits in a foreign namespace is a custom attribute, not the known one.
    @Test func `a custom attribute sharing a known local name is kept separate`() throws {
        let foreignUnit = ExpandedName(namespaceName: "http://example.com/x", localName: "unit")
        let model = Model(unit: .meter, customAttributes: [foreignUnit: "furlong"], build: Build(items: []))
        let decoded = try roundTrip(model)
        #expect(decoded.unit == .meter)
        #expect(decoded.customAttributes == [foreignUnit: "furlong"])
    }
}
