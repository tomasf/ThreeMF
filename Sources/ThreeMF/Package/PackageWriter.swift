import Foundation
import Zip
import Nodal

public class PackageWriter<Target> {
    private let archive: ZipArchive<Target>
    private var contentTypes = ContentTypes()
    private var relationships = Relationships()
    private var modelFileRelationships = Relationships()
    private var additionalModels: [String: Model] = [:]

    public var model = Model()
    public var compressionLevel = CompressionLevel.default

    private init(archive: ZipArchive<Target>) {
        self.archive = archive
        contentTypes.add(mimeType: MimeType.relationships.rawValue, for: "rels")
    }
}

public extension PackageWriter<URL> {
    convenience init(url fileURL: URL) throws {
        try self.init(archive: ZipArchive(url: fileURL, mode: .overwrite))
    }

    // Write the 3MF file to disk
    func finalize() throws {
        try writeMainFiles()
        try archive.finalize()
    }
}

public extension PackageWriter<Data> {
    convenience init() {
        self.init(archive: ZipArchive())
    }

    // Generate the 3MF data
    func finalize() throws -> Data {
        try writeMainFiles()
        try writeMetaFiles()
        return try archive.finalize()
    }

    // Generate the 3MF data
    func finalize() async throws -> Data {
        try await writeMainFiles()
        try writeMetaFiles()
        return try archive.finalize()
    }
}

public extension PackageWriter {
    func addFile(
        at url: URL,
        contentType mimeType: String?,
        relationshipType: String?,
        relativeToRootModel: Bool = false,
        data: Data
    ) throws {
        if let mimeType {
            contentTypes.add(mimeType: mimeType, for: url)
        }
        if let relationshipType {
            if relativeToRootModel {
                modelFileRelationships.add(target: url, type: relationshipType)
            } else {
                relationships.add(target: url, type: relationshipType)
            }
        }
        try addFile(at: url, data: data)
    }

    func addTexture(data: Data) throws -> URL {
        try addNumberedFile(
            base: "Textures/Texture",
            contentType: MimeType.modelTexture.rawValue,
            relationshipType: RelationshipType.texture.rawValue,
            data: data
        )
    }

    func addThumbnail(data: Data, mimeType: String) throws -> URL {
        try addNumberedFile(
            base: "Metadata/Thumbnail",
            contentType: mimeType,
            relationshipType: RelationshipType.thumbnail.rawValue,
            data: data
        )
    }

    func addAdditionalModel(_ model: Model, named name: String) throws -> URL {
        var name = name
        var counter = 2
        while additionalModels[name] != nil {
            name = "\(name)-\(counter)"
            counter += 1
        }
        additionalModels[name] = model

        guard let modelURL = URL(string: "/3D/\(name).model") else {
            throw ThreeMFError.invalidModelName(name)
        }

        return modelURL
    }
}

internal extension PackageWriter {
    func addNumberedFile(base: String, contentType mimeType: String, relationshipType: String, data: Data) throws -> URL {
        let existingCount = relationships.count(ofType: relationshipType)
        guard let uri = URL(string: "\(base)\(existingCount + 1)") else {
            fatalError("Failed to create numbered URL")
        }
        try addFile(at: uri, contentType: mimeType, relationshipType: relationshipType, data: data)
        return uri
    }

    func addFile(at url: URL, data: Data) throws {
        var filePath = url.relativePath
        if filePath.hasPrefix("/") {
            filePath.removeFirst()
        }
        try archive.addFile(at: filePath, data: data, compression: compressionLevel)
    }

    static func xmlDocument(for model: Model) -> Document {
        let modelDocument = Document(model, elementName: Core.model)

        for (prefix, uri) in model.customNamespaces {
            modelDocument.documentElement?.declareNamespace(uri, forPrefix: prefix)
        }

        for namespaceName in modelDocument.undeclaredNamespaceNames {
            guard let namespace = Namespace.knownNamespace(for: namespaceName) else {
                assertionFailure("Unknown namespace \(namespaceName)")
                continue
            }
            modelDocument.documentElement?.declareNamespace(namespaceName, forPrefix: namespace.outputPrefix)
        }

        return modelDocument
    }

    struct WritableFile: Sendable {
        let url: URL
        let contentType: String?
        let relationshipType: String?
        let relativeToRootModel: Bool
        let dataProvider: @Sendable () throws -> Data

        init(
            url: URL,
            contentType: String? = nil,
            relationshipType: String? = nil,
            relativeToRootModel: Bool = false,
            dataProvider: @Sendable @escaping () throws -> Data
        ) {
            self.url = url
            self.contentType = contentType
            self.relationshipType = relationshipType
            self.relativeToRootModel = relativeToRootModel
            self.dataProvider = dataProvider
        }
    }

    func files() throws -> [WritableFile] {
        // Cura is sadly hard-coded to always read this file name, so keep it for compatibility
        guard let modelURL = URL(string: "/3D/3dmodel.model") else {
            fatalError("Failed to initialize model URL")
        }

        let model = self.model

        let rootModelFile = WritableFile(
            url: modelURL,
            contentType: MimeType.model.rawValue,
            relationshipType: RelationshipType.model.rawValue,
        ) {
            try Self.xmlDocument(for: model).xmlData()
        }

        let additionalModelFiles = try additionalModels.map { name, model in
            guard let modelURL = URL(string: "/3D/\(name).model") else {
                throw ThreeMFError.invalidModelName(name)
            }
            return WritableFile(
                url: modelURL,
                contentType: MimeType.model.rawValue,
                relationshipType: RelationshipType.model.rawValue,
                relativeToRootModel: true
            ) {
                try Self.xmlDocument(for: model).xmlData()
            }
        }

        return [rootModelFile] + additionalModelFiles
    }

    func writeMetaFiles() throws {
        guard let modelRelationshipsURL = URL(string: "/3D/_rels/3dmodel.model.rels") else {
            fatalError("Failed to initialize model URL")
        }

        try addFile(at: ContentTypes.archiveFileURL, data: try contentTypes.xmlDocument().xmlData())
        try addFile(at: Relationships.archiveFileURL, data: try relationships.xmlDocument().xmlData())
        if !modelFileRelationships.isEmpty {
            try addFile(at: modelRelationshipsURL, data: try modelFileRelationships.xmlDocument().xmlData())
        }
    }

    func writeMainFiles() throws {
        for file in try files() {
            try addFile(
                at: file.url,
                contentType: file.contentType,
                relationshipType: file.relationshipType,
                relativeToRootModel: file.relativeToRootModel,
                data: try file.dataProvider()
            )
        }
    }

    func writeMainFiles() async throws {
        let filesWithData = try await files().asyncMap {
            try (file: $0, data: $0.dataProvider())
        }
        for file in filesWithData {
            try addFile(
                at: file.file.url,
                contentType: file.file.contentType,
                relationshipType: file.file.relationshipType,
                relativeToRootModel: file.file.relativeToRootModel,
                data: file.data
            )
        }
    }
}
