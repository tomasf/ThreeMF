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

    // Several additional models and a couple of loose files, all added in non-alphabetical order,
    // plus the unordered collections that end up in the root model's XML: extension prefixes, custom
    // namespaces and an item's custom attributes.
    private func multiModelPackage() throws -> Data {
        var rootModel = Model(build: Build(items: []))
        // Two extensions each, to exercise the ordering of the prefix lists they're written as. Not
        // the production extension, though: that mints a fresh UUID per serialization by design, so
        // a model using it can't serialize identically twice in the first place.
        rootModel.requiredExtensions = [.materials, .boolean, .slice]
        rootModel.recommendedExtensions = [.mirroring, .triangleSets]
        // Four of each, rather than the two it takes to show the bug: an unordered collection has to
        // come out in exactly the sorted order to slip past, and four names make that unlikely enough
        // that a regression doesn't need several runs to show up.
        rootModel.customNamespaces = ["zed": "urn:zed", "ay": "urn:ay", "em": "urn:em", "queue": "urn:queue"]
        rootModel.resources.resources = [ColorGroup(id: 1, colors: [.white]), meshObject(id: 2, name: "Part")]
        rootModel.build.items = [Item(objectID: 2, customAttributes: [
            ExpandedName(namespaceName: "urn:zed", localName: "fourth"): "4",
            ExpandedName(namespaceName: "urn:queue", localName: "third"): "3",
            ExpandedName(namespaceName: "urn:em", localName: "second"): "2",
            ExpandedName(namespaceName: "urn:ay", localName: "first"): "1",
        ])]

        let writer = PackageWriter<Data>()
        writer.model = rootModel
        for name in ["gamma", "alpha", "epsilon", "beta", "delta"] {
            var additionalModel = Model()
            additionalModel.metadata = [Metadata(name: .title, value: name)]
            _ = try writer.addAdditionalModel(additionalModel, named: name)
        }
        writer.addFile(at: URL(string: "/Metadata/z.txt")!, contentType: "text/plain", relationshipType: nil, data: Data("z".utf8))
        writer.addFile(at: URL(string: "/Metadata/a.txt")!, contentType: "text/plain", relationshipType: nil, data: Data("a".utf8))
        return try writer.finalize()
    }

    // Asserts that every substring is present, each one after the last.
    private func assertOrder(of substrings: [String], in text: String) throws {
        var remainder = Substring(text)
        for substring in substrings {
            let found = try #require(remainder.range(of: substring), "\(substring) is missing or out of order")
            remainder = remainder[found.upperBound...]
        }
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

    @Test func `packages with several additional models are written deterministically`() throws {
        // The model entries, the staged files and a model's namespace declarations were all walked
        // in the order their dictionary or set happened to hash them into, so relationship IDs, the
        // archive layout and the model XML itself varied from one run to the next. Comparing the
        // whole archives byte for byte would drag in the entry timestamps, so this compares what the
        // writer actually decides: the order of the entries and the bytes within each one.
        let first = try multiModelPackage()
        let second = try multiModelPackage()

        let firstEntries = try ZipArchive(data: first).entries.map(\.path)
        #expect(try firstEntries == ZipArchive(data: second).entries.map(\.path))
        #expect(firstEntries == [
            "3D/3dmodel.model", "3D/alpha.model", "3D/beta.model", "3D/delta.model", "3D/epsilon.model",
            "3D/gamma.model", "Metadata/a.txt", "Metadata/z.txt", "[Content_Types].xml", "_rels/.rels",
            "3D/_rels/3dmodel.model.rels",
        ])

        let firstReader = try PackageReader<Data>(data: first)
        let secondReader = try PackageReader<Data>(data: second)
        for path in firstEntries {
            let url = URL(string: "/" + path)!
            #expect(try firstReader.readFile(at: url) == secondReader.readFile(at: url), "\(path) differs")
        }

        // Comparing two packages built in the same process catches an unordered set only by chance,
        // since two sets holding the same names often do iterate alike, so the order each unordered
        // collection is written in is also pinned directly.
        let rootModelData = try #require(try firstReader.readFile(at: URL(string: "/3D/3dmodel.model")!))
        let rootModelXML = try #require(String(data: rootModelData, encoding: .utf8))
        try assertOrder(of: ["xmlns:ay=", "xmlns:em=", "xmlns:queue=", "xmlns:zed="], in: rootModelXML)
        try assertOrder(of: [
            "http://schemas.microsoft.com/3dmanufacturing/core/2015/02",
            "http://schemas.microsoft.com/3dmanufacturing/material/2015/02",
        ], in: rootModelXML)
        try assertOrder(of: ["ay:first=", "em:second=", "queue:third=", "zed:fourth="], in: rootModelXML)
        #expect(rootModelXML.contains(#"requiredextensions="bo m s""#))
        #expect(rootModelXML.contains(#"recommendedextensions="mm t""#))

        let relsData = try #require(try firstReader.readFile(at: URL(string: "/3D/_rels/3dmodel.model.rels")!))
        let targets = try Document(data: relsData).documentElement?[elements: "Relationship"]
            .sorted { ($0[attribute: "Id"] ?? "") < ($1[attribute: "Id"] ?? "") }
            .map { $0[attribute: "Target"] ?? "" }

        #expect(targets == [
            "/3D/alpha.model", "/3D/beta.model", "/3D/delta.model", "/3D/epsilon.model", "/3D/gamma.model",
        ])
    }

    @Test func `textures and thumbnails are written with incrementing numbers and readable back`() throws {
        let writer = PackageWriter<Data>()
        writer.model = Model(build: Build(items: []))

        let texture1Data = Data("texture-1".utf8)
        let texture2Data = Data("texture-2".utf8)
        let thumbnailData = Data("thumbnail".utf8)

        let texture1URL = writer.addTexture(data: texture1Data)
        let texture2URL = writer.addTexture(data: texture2Data)
        let thumbnailURL = writer.addThumbnail(data: thumbnailData, mimeType: "image/png")

        #expect(texture1URL.relativePath.hasSuffix("Texture1"))
        #expect(texture2URL.relativePath.hasSuffix("Texture2"))

        let data = try writer.finalize()
        let reader = try PackageReader<Data>(data: data)
        #expect(try reader.readFile(at: texture1URL) == texture1Data)
        #expect(try reader.readFile(at: texture2URL) == texture2Data)
        #expect(try reader.readFile(at: thumbnailURL) == thumbnailData)
    }

    @Test func `content type part names are absolute whichever way the part was named`() throws {
        // OPC part names have to start with a slash, so what the caller passed — or what the
        // automatic numbering produced — can't be written through verbatim.
        let writer = PackageWriter<Data>()
        writer.model = Model(build: Build(items: []))

        let textureURL = writer.addTexture(data: Data("texture".utf8))
        #expect(textureURL.relativePath.hasPrefix("/"))
        writer.addFile(at: URL(string: "Metadata/relative.txt")!, contentType: "text/plain", relationshipType: nil, data: Data("x".utf8))

        let data = try writer.finalize()
        let reader = try PackageReader<Data>(data: data)
        let contentTypesData = try #require(try reader.readFile(at: URL(string: "/[Content_Types].xml")!))
        let partNames = try Document(data: contentTypesData).documentElement?[elements: "Override"].map {
            $0[attribute: "PartName"] ?? ""
        }

        #expect(partNames?.contains("/Textures/Texture1") == true)
        #expect(partNames?.contains("/Metadata/relative.txt") == true)
        #expect(partNames?.allSatisfy { $0.hasPrefix("/") } == true)
    }

    @Test func `readFile returns nil for a file that was never added`() throws {
        let writer = PackageWriter<Data>()
        writer.model = Model(build: Build(items: []))
        let data = try writer.finalize()
        let reader = try PackageReader<Data>(data: data)
        #expect(try reader.readFile(at: URL(string: "/never/added")!) == nil)
    }

    @Test func `addFile replaces an existing path instead of throwing`() throws {
        let writer = PackageWriter<Data>()
        writer.model = Model(build: Build(items: []))

        let url = URL(string: "/Metadata/test.config")!
        writer.addFile(at: url, contentType: nil, relationshipType: nil, data: Data("first".utf8))
        writer.addFile(at: url, contentType: nil, relationshipType: nil, data: Data("second".utf8))

        let data = try writer.finalize()
        let reader = try PackageReader<Data>(data: data)
        #expect(try reader.readFile(at: url) == Data("second".utf8))
    }

    @Test func `fileContents reads back a file added this session`() throws {
        let writer = PackageWriter<Data>()
        writer.model = Model(build: Build(items: []))

        let url = URL(string: "/Metadata/test.config")!
        writer.addFile(at: url, contentType: nil, relationshipType: nil, data: Data("hello".utf8))

        #expect(try writer.fileContents(at: url) == Data("hello".utf8))
    }

    @Test func `fileContents returns nil for a path nothing has staged`() throws {
        let writer = PackageWriter<Data>()
        writer.model = Model(build: Build(items: []))
        #expect(try writer.fileContents(at: URL(string: "/never/added")!) == nil)
    }

    @Test func `fileContents lazily serializes the root model on first read`() throws {
        let writer = PackageWriter<Data>()
        writer.model = sampleModel()

        let modelData = try #require(try writer.fileContents(at: URL(string: "/3D/3dmodel.model")!))
        let document = try Document(data: modelData)
        #expect(document.documentElement?.name == "model")
    }

    @Test func `replacing the root model's raw bytes via addFile changes what finalize writes`() throws {
        // The whole point of exposing raw read/write access to the model file: a caller can read the
        // current XML, do its own surgery (e.g. with Nodal directly), and write the result back,
        // entirely bypassing the structured Model/Object/Item types.
        let writer = PackageWriter<Data>()
        writer.model = sampleModel()

        let modelURL = URL(string: "/3D/3dmodel.model")!
        let originalXML = try #require(try writer.fileContents(at: modelURL))
        let document = try Document(data: originalXML)
        document.documentElement?[attribute: "surgically-added"] = "yes"

        writer.addFile(at: modelURL, contentType: nil, relationshipType: nil, data: try document.xmlData())

        let data = try writer.finalize()
        let reader = try PackageReader<Data>(data: data)
        let rawModelData = try #require(try reader.readFile(at: modelURL))
        let rereadDocument = try Document(data: rawModelData)
        #expect(rereadDocument.documentElement?[attribute: "surgically-added"] == "yes")
    }

    @Test func `async finalize also reflects a raw replacement of the root model`() async throws {
        let writer = PackageWriter<Data>()
        writer.model = sampleModel()

        let modelURL = URL(string: "/3D/3dmodel.model")!
        let originalXML = try #require(try writer.fileContents(at: modelURL))
        let document = try Document(data: originalXML)
        document.documentElement?[attribute: "surgically-added"] = "yes"
        writer.addFile(at: modelURL, contentType: nil, relationshipType: nil, data: try document.xmlData())

        let data = try await writer.finalize()
        let reader = try PackageReader<Data>(data: data)
        let rawModelData = try #require(try reader.readFile(at: modelURL))
        let rereadDocument = try Document(data: rawModelData)
        #expect(rereadDocument.documentElement?[attribute: "surgically-added"] == "yes")
    }

    @Test func `content type overrides do not accumulate duplicates when a path is replaced`() throws {
        let writer = PackageWriter<Data>()
        writer.model = Model(build: Build(items: []))

        let url = URL(string: "/Metadata/test.txt")!
        writer.addFile(at: url, contentType: "text/plain", relationshipType: nil, data: Data("first".utf8))
        writer.addFile(at: url, contentType: "text/plain", relationshipType: nil, data: Data("second".utf8))

        let data = try writer.finalize()
        let reader = try PackageReader<Data>(data: data)
        let contentTypesData = try #require(try reader.readFile(at: URL(string: "/[Content_Types].xml")!))
        let document = try Document(data: contentTypesData)
        let overridesForPath = document.documentElement?[elements: "Override"].filter {
            $0[attribute: "PartName"] == url.relativePath
        }
        #expect(overridesForPath?.count == 1)
    }

    @Test func `relationship ids stay unique when a related path is replaced`() throws {
        let writer = PackageWriter<Data>()
        writer.model = Model(build: Build(items: []))

        // Replacing the first file drops its ID, so an ID derived from the remaining count would
        // collide with the second file's still-in-use ID.
        let first = URL(string: "/Metadata/first.txt")!
        let second = URL(string: "/Metadata/second.txt")!
        writer.addFile(at: first, contentType: "text/plain", relationshipType: "urn:test", data: Data("a".utf8))
        writer.addFile(at: second, contentType: "text/plain", relationshipType: "urn:test", data: Data("b".utf8))
        writer.addFile(at: first, contentType: "text/plain", relationshipType: "urn:test", data: Data("c".utf8))

        let data = try writer.finalize()
        let reader = try PackageReader<Data>(data: data)
        let relsData = try #require(try reader.readFile(at: URL(string: "/_rels/.rels")!))
        let document = try Document(data: relsData)
        let ids = try #require(document.documentElement?[elements: "Relationship"].map { $0[attribute: "Id"] })

        #expect(ids.count == 3)
        #expect(Set(ids).count == ids.count)
    }

    @Test func `writing the root model's bytes without reading first still yields a readable package`() throws {
        // Same raw-XML workflow as above, minus the fileContents() call that would incidentally
        // register the model's relationship and content type on the way through.
        let writer = PackageWriter<Data>()
        writer.model = Model(build: Build(items: []))

        let modelURL = URL(string: "/3D/3dmodel.model")!
        let xml = try sampleModel().xmlDocument().xmlData()
        writer.addFile(at: modelURL, contentType: nil, relationshipType: nil, data: xml)

        let data = try writer.finalize()
        let reader = try PackageReader<Data>(data: data)
        assertMatchesSample(try reader.model())

        let contentTypesData = try #require(try reader.readFile(at: URL(string: "/[Content_Types].xml")!))
        let overrides = try Document(data: contentTypesData).documentElement?[elements: "Override"].filter {
            $0[attribute: "PartName"] == modelURL.relativePath
        }
        #expect(overrides?.count == 1)
    }

    @Test func `the same part written with and without a leading slash is one file, one relationship and one override`() throws {
        let writer = PackageWriter<Data>()
        writer.model = Model(build: Build(items: []))

        let absolute = URL(string: "/Metadata/a.txt")!
        let relative = URL(string: "Metadata/a.txt")!
        writer.addFile(at: absolute, contentType: "text/plain", relationshipType: "urn:test", data: Data("first".utf8))
        writer.addFile(at: relative, contentType: "text/plain", relationshipType: "urn:test", data: Data("second".utf8))

        let data = try writer.finalize()
        let reader = try PackageReader<Data>(data: data)
        #expect(try reader.readFile(at: absolute) == Data("second".utf8))

        let relsData = try #require(try reader.readFile(at: URL(string: "/_rels/.rels")!))
        let testRelationships = try Document(data: relsData).documentElement?[elements: "Relationship"].filter {
            $0[attribute: "Type"] == "urn:test"
        }
        #expect(testRelationships?.count == 1)

        let contentTypesData = try #require(try reader.readFile(at: URL(string: "/[Content_Types].xml")!))
        let overrides = try Document(data: contentTypesData).documentElement?[elements: "Override"].filter {
            $0[attribute: "ContentType"] == "text/plain"
        }
        #expect(overrides?.count == 1)
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
