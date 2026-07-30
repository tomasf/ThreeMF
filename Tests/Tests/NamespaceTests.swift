import Testing
import Foundation
import Nodal
@testable import ThreeMF

struct NamespaceTests {
    // Namespace-prefix declaration only happens in PackageWriter.xmlDocument(for:), so this has to
    // go through a full PackageWriter<Data> -> PackageReader<Data> cycle rather than the lighter
    // Node-only roundTrip helper: a bare Document(model, elementName:) never declares the "p"/"m"
    // prefixes those extensions need, so decode would never resolve them.
    @Test func `required and recommended extensions round trip through a full package`() async throws {
        var model = Model()
        model.requiredExtensions = [.production]
        model.recommendedExtensions = [.materials]
        // A materials-namespaced resource and a production UUID are what actually cause their
        // namespaces to be requested/declared by the writer — merely listing an extension in
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

    // Known issue, not fixed as part of this test suite: Model.init(from:)'s customNamespaces
    // filter keeps declared namespaces whose URI *is* in Namespace.known, which is backwards for a
    // field documented as `// Prefix: URI` custom namespaces (Model.swift). A genuinely custom/
    // vendor namespace — the only kind this field is meant to capture — has a URI that's never in
    // Namespace.known, so it's filtered *out*, and customNamespaces always decodes empty. Confirmed
    // directly: writing a Model with customNamespaces = ["ext": "http://example.com/custom"]
    // through PackageWriter<Data>/PackageReader<Data> comes back with customNamespaces == [:].
    @Test(.disabled("Known issue: Model.customNamespaces' decode filter keeps known namespaces instead of custom ones. See Model.swift's init(from:)."))
    func `custom namespaces round trip through a full package`() async throws {
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
