import Foundation
import Zip
import Nodal

public class PackageWriter<Target> {
    private let archive: ZipArchive<Target>
    private var contentTypes = ContentTypes()
    private var relationships = Relationships()

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
        return try archive.finalize()
    }
}

public extension PackageWriter {
    func addFile(at url: URL, contentType mimeType: String, relationshipType: String, data: Data) throws {
        contentTypes.add(mimeType: mimeType, for: url)
        relationships.add(target: url, type: relationshipType)
        try addFile(at: url, data: data)
    }

    func addTexture(data: Data) throws -> URL {
        try addNumberedFile(base: "Textures/Texture", contentType: MimeType.modelTexture.rawValue, relationshipType: RelationshipType.texture.rawValue, data: data)
    }

    func addThumbnail(data: Data, mimeType: String) throws -> URL {
        try addNumberedFile(base: "Metadata/Thumbnail", contentType: mimeType, relationshipType: RelationshipType.thumbnail.rawValue, data: data)
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

    func xmlDocument() -> Document {
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

    func writeMainFiles() throws {
        // Cura is sadly hard-coded to always read this file name, so keep it for compatibility
        guard let modelURL = URL(string: "/3D/3dmodel.model") else {
            fatalError("Failed to initialize model URL")
        }

        try addFile(
            at: modelURL,
            contentType: MimeType.model.rawValue,
            relationshipType: RelationshipType.model.rawValue,
            data: try xmlDocument().xmlData()
        )

        try addFile(at: ContentTypes.archiveFileURL, data: contentTypes.xmlDocument().xmlData())
        try addFile(at: Relationships.archiveFileURL, data: relationships.xmlDocument().xmlData())
    }
}
