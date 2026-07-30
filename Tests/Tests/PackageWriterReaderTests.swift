import Testing
import Foundation
import Nodal
import Zip
@testable import ThreeMF

struct PackageWriterReaderTests {
    private func sampleModel() -> Model {
        var model = Model()
        model.unit = .centimeter
        model.metadata = [Metadata(name: .title, value: "A model")]
        model.resources.resources = [
            ColorGroup(id: 1, colors: [.white, Color(red: 1, green: 2, blue: 3)]),
            meshObject(id: 2, name: "Part"),
        ]
        model.build.items = [Item(objectID: 2)]
        return model
    }

    private func assertMatchesSample(_ model: Model) {
        #expect(model.unit == .centimeter)
        #expect(model.metadata.map(\.value) == ["A model"])
        #expect(model.resources.resources.count == 2)
        #expect(model.resources.resource(for: 1) is ColorGroup)
        #expect(model.resources.resource(for: 2) is Object)
        #expect(model.build.items.map(\.objectID) == [2])
    }

    @Test func `full round trip through the sync Data writer and reader`() throws {
        let writer = PackageWriter<Data>()
        writer.model = sampleModel()
        let data = try writer.finalize()

        let readModel = try PackageReader<Data>(data: data).model()
        assertMatchesSample(readModel)
    }

    // Covers the concurrent asyncMap-based write path (writeMainFiles() async throws), a separate
    // code path from the sync finalize() above.
    @Test func `full round trip through the async Data writer and reader`() async throws {
        let writer = PackageWriter<Data>()
        writer.model = sampleModel()
        let data = try await writer.finalize()

        let readModel = try PackageReader<Data>(data: data).model()
        assertMatchesSample(readModel)
    }

    @Test func `additional model registered via addAdditionalModel is written and read back`() throws {
        let writer = PackageWriter<Data>()
        writer.model = Model(build: Build(items: []))
        var additionalModel = Model()
        additionalModel.metadata = [Metadata(name: .title, value: "Additional")]
        let additionalURL = try writer.addAdditionalModel(additionalModel, named: "extra")
        writer.model.build.items = [Item(objectID: 1, path: additionalURL)]

        let data = try writer.finalize()
        let reader = try PackageReader<Data>(data: data)

        let rootModel = try reader.model()
        #expect(rootModel.build.items.first?.path == additionalURL)

        let readAdditionalModel = try reader.model(at: additionalURL)
        #expect(readAdditionalModel.metadata.map(\.value) == ["Additional"])
    }

    @Test func `duplicate additional model names get distinct numbered URLs`() throws {
        let writer = PackageWriter<Data>()
        writer.model = Model(build: Build(items: []))

        var first = Model()
        first.metadata = [Metadata(name: .title, value: "First")]
        var second = Model()
        second.metadata = [Metadata(name: .title, value: "Second")]

        let firstURL = try writer.addAdditionalModel(first, named: "extra")
        let secondURL = try writer.addAdditionalModel(second, named: "extra")
        #expect(firstURL != secondURL)

        let data = try writer.finalize()
        let reader = try PackageReader<Data>(data: data)
        #expect(try reader.model(at: firstURL).metadata.map(\.value) == ["First"])
        #expect(try reader.model(at: secondURL).metadata.map(\.value) == ["Second"])
    }

    @Test func `textures and thumbnails are written with incrementing numbers and readable back`() throws {
        let writer = PackageWriter<Data>()
        writer.model = Model(build: Build(items: []))

        let texture1Data = Data("texture-1".utf8)
        let texture2Data = Data("texture-2".utf8)
        let thumbnailData = Data("thumbnail".utf8)

        let texture1URL = try writer.addTexture(data: texture1Data)
        let texture2URL = try writer.addTexture(data: texture2Data)
        let thumbnailURL = try writer.addThumbnail(data: thumbnailData, mimeType: "image/png")

        #expect(texture1URL.relativePath.hasSuffix("Texture1"))
        #expect(texture2URL.relativePath.hasSuffix("Texture2"))

        let data = try writer.finalize()
        let reader = try PackageReader<Data>(data: data)
        #expect(try reader.readFile(at: texture1URL) == texture1Data)
        #expect(try reader.readFile(at: texture2URL) == texture2Data)
        #expect(try reader.readFile(at: thumbnailURL) == thumbnailData)
    }

    @Test func `readFile returns nil for a file that was never added`() throws {
        let writer = PackageWriter<Data>()
        writer.model = Model(build: Build(items: []))
        let data = try writer.finalize()
        let reader = try PackageReader<Data>(data: data)
        #expect(try reader.readFile(at: URL(string: "/never/added")!) == nil)
    }

    // -- Malformed packages, built directly with Zip since PackageWriter can't produce these --

    @Test func `missing _rels_.rels throws failedToReadArchiveFile`() throws {
        let archive = ZipArchive<Data>()
        try archive.addFile(at: "somefile.txt", data: Data())
        let data = try archive.finalize()

        #expect(throws: ThreeMFError.self) {
            _ = try PackageReader<Data>(data: data).model()
        }
    }

    @Test func `rels file with no model relationship throws malformedRelationships`() throws {
        let archive = ZipArchive<Data>()
        let relationships = Document()
        let root = relationships.makeDocumentElement(name: "Relationships", defaultNamespace: "http://schemas.openxmlformats.org/package/2006/relationships")
        let relationship = root.addElement("Relationship")
        relationship[attribute: "Target"] = "/somewhere"
        relationship[attribute: "Id"] = "rel1"
        relationship[attribute: "Type"] = "http://example.com/not-a-model"
        try archive.addFile(at: "_rels/.rels", data: try relationships.xmlData())
        let data = try archive.finalize()

        #expect {
            try PackageReader<Data>(data: data).model()
        } throws: { error in
            guard case ThreeMFError.malformedRelationships = error else { return false }
            return true
        }
    }

    @Test func `rels pointing at a nonexistent model part throws failedToReadArchiveFile`() throws {
        let archive = ZipArchive<Data>()
        try archive.addFile(at: "_rels/.rels", data: try modelRelationshipsDocument().xmlData())
        let data = try archive.finalize()

        #expect {
            try PackageReader<Data>(data: data).model()
        } throws: { error in
            guard case ThreeMFError.failedToReadArchiveFile = error else { return false }
            return true
        }
    }

    @Test func `invalid XML in the model part throws failedToReadArchiveFile`() throws {
        let archive = ZipArchive<Data>()
        try archive.addFile(at: "_rels/.rels", data: try modelRelationshipsDocument().xmlData())
        try archive.addFile(at: "3D/3dmodel.model", data: Data("not valid xml <<<".utf8))
        let data = try archive.finalize()

        #expect {
            try PackageReader<Data>(data: data).model()
        } throws: { error in
            guard case ThreeMFError.failedToReadArchiveFile = error else { return false }
            return true
        }
    }

    private func modelRelationshipsDocument() -> Document {
        let document = Document()
        let root = document.makeDocumentElement(name: "Relationships", defaultNamespace: "http://schemas.openxmlformats.org/package/2006/relationships")
        let relationship = root.addElement("Relationship")
        relationship[attribute: "Target"] = "/3D/3dmodel.model"
        relationship[attribute: "Id"] = "rel1"
        relationship[attribute: "Type"] = "http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"
        return document
    }

    // addAdditionalModel's invalidModelName error path is effectively unreachable in practice:
    // Foundation's URL(string:) percent-encodes essentially anything (spaces, control characters,
    // non-ASCII), so no input reliably fails `URL(string: "/3D/\(name).model")` construction. Not
    // covered by a test here rather than forcing a flaky or vacuous one.

    // -- URL-based writer/reader: minimal coverage, since PackageWriter<URL>/PackageReader<URL>
    // share all their logic with the Data variants above via the generic PackageWriter<Target>/
    // PackageReader<Target> — only init/finalize/invalidate differ per Target. --

    @Test func `file-based writer and reader round trip through a real file on disk`() throws {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".3mf")
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let writer = try PackageWriter<URL>(url: fileURL)
        writer.model = sampleModel()
        try writer.finalize()

        let reader = try PackageReader<URL>(url: fileURL)
        let readModel = try reader.model()
        assertMatchesSample(readModel)
        reader.invalidate()
    }
}
