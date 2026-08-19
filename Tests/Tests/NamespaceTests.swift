import Testing
import Foundation
import Nodal
@testable import ThreeMF

struct NamespaceTests {
    // Namespace-prefix declaration only happens in Model.xmlDocument(), so this has to
    // go through a full PackageWriter<Data> -> PackageReader<Data> cycle rather than the lighter
    // Node-only roundTrip helper: a bare Document(model, elementName:) never declares the "p"/"m"
    // prefixes those extensions need, so decode would never resolve them.
    @Test func `required and recommended extensions round trip through a full package`() async throws {
        var model = Model()
        model.requiredExtensions = [.production]
        model.recommendedExtensions = [.materials]

        // A materials-namespaced resource and a production UUID are what actually cause their
        // namespaces to be requested/declared by the writer. Merely listing an extension in
        // requiredExtensions/recommendedExtensions doesn't by itself use its namespace anywhere.
        model.resources.resources = [ColorGroup(id: 1, colors: [.white])]
        model.build.uuid = UUID()

        let writer = PackageWriter<Data>()
        writer.model = model
        let data = try await writer.finalize()

        let reader = try PackageReader<Data>(data: data)
        let readModel = try reader.model()
        #expect(readModel.requiredExtensions == [.production])
        #expect(readModel.recommendedExtensions == [.materials])

        // Known (built-in) namespaces like these shouldn't show up as "custom" ones.
        #expect(readModel.customNamespaces.isEmpty)
    }

    // The written <model> root carries every namespace declaration the package uses (the default
    // core one, the custom prefix, and "m" for the color group), so this is where a declaration
    // being mistaken for a custom attribute would show up.
    @Test func `custom attributes in a custom namespace round trip through a full package`() throws {
        let customAttribute = ExpandedName(namespaceName: "http://example.com/custom", localName: "flag")
        var model = Model(build: Build(items: []))
        model.customNamespaces = ["ext": "http://example.com/custom"]
        model.customAttributes = [customAttribute: "yes"]
        model.resources.resources = [ColorGroup(id: 1, colors: [.white])]

        let writer = PackageWriter<Data>()
        writer.model = model
        let data = try writer.finalize()

        let readModel = try PackageReader<Data>(data: data).model()
        #expect(readModel.customAttributes == [customAttribute: "yes"])
        #expect(readModel.customNamespaces == ["ext": "http://example.com/custom"])
    }

    // Writing an attribute in a namespace the model never declared a prefix for is a programmer
    // error, not something to paper over with an invented prefix: the resulting XML couldn't
    // resolve it.
    @Test func `a custom attribute in an undeclared namespace traps`() async {
        await #expect(processExitsWith: .failure) {
            let customAttribute = ExpandedName(namespaceName: "http://example.com/x", localName: "flag")
            var model = Model(build: Build(items: []))
            model.customAttributes = [customAttribute: "yes"]

            // Only building the document, not serializing it: writing it out fails on the
            // unresolvable prefix either way, so that wouldn't tell the trap apart from an error.
            _ = model.xmlDocument()
        }
    }

    @Test(arguments: [
        (ModelResolution.full, "fullres"),
        (.low, "lowres"),
        (.obfuscated, "obfuscated"),
    ])
    func `model resolution round trips through its wire string`(resolution: ModelResolution, wireValue: String) throws {
        let document = Document()
        let root = document.makeDocumentElement(name: "test")
        #expect(resolution.xmlStringValue(for: root) == wireValue)
        #expect(try roundTrip(resolution) == resolution)
    }

    @Test func `custom namespaces round trip through a full package`() async throws {
        var model = Model()
        model.customNamespaces = ["ext": "http://example.com/custom"]

        let writer = PackageWriter<Data>()
        writer.model = model
        let data = try await writer.finalize()

        let reader = try PackageReader<Data>(data: data)
        let readModel = try reader.model()
        #expect(readModel.customNamespaces == ["ext": "http://example.com/custom"])
    }
}
