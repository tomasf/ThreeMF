import Foundation
import Zip
import Nodal

/// Writes 3MF packages to either a file URL or in‑memory data, managing models, related files, and relationships.
///
/// PackageWriter abstracts the underlying ZIP archive and handles:
/// - Writing the root model and any additional models
/// - Adding textures, thumbnails, and other related files with appropriate content types and relationships
/// - Finalizing to disk (URL) or returning in‑memory Data
///
/// Nothing is written to the underlying ZIP archive until ``finalize()``. Until then, every file —
/// the root model, additional models, and anything added via ``addFile(at:contentType:relationshipType:relativeToRootModel:data:)``
/// — lives in an in‑memory staging area, keyed by path. This is what lets ``addFile(at:contentType:relationshipType:relativeToRootModel:data:)``
/// freely replace a path that was already written, and what lets ``fileContents(at:)`` read back
/// anything staged so far (including the models, serialized on demand): the underlying ZIP writer
/// can only ever append an entry, never replace one, so actually writing to it is deferred as long
/// as possible and done exactly once per path.
///
/// Usage:
/// - Initialize with a URL (for on‑disk output) or with no parameters (for in‑memory output)
/// - Populate `model` and add any additional files or models
/// - Call `finalize()` to write the package
///
public class PackageWriter<Target> {
    private let archive: ZipArchive<Target>
    private var contentTypes = ContentTypes()
    private var relationships = Relationships()
    private var modelFileRelationships = Relationships()
    private var additionalModels: [String: Model] = [:]

    // Staged file contents, keyed by normalized path (no leading slash). The single source of truth
    // for everything that will end up in the archive; see the type's documentation for why.
    private var stagedFiles: [String: Data] = [:]

    /// The root model written as the package's primary model.
    public var model = Model()

    /// The compression level used for files added to the package.
    public var compressionLevel = CompressionLevel.default

    private init(archive: ZipArchive<Target>) {
        self.archive = archive
        contentTypes.add(mimeType: MimeType.relationships.rawValue, for: "rels")
    }
}

public extension PackageWriter<URL> {
    /// Creates a writer that outputs a 3MF package to a file URL.
    ///
    /// - Parameter fileURL: The destination file URL where the 3MF package will be written.
    /// - Throws: An error if the archive cannot be created or opened for writing.
    convenience init(url fileURL: URL) throws {
        try self.init(archive: ZipArchive(url: fileURL, mode: .overwrite))
    }

    /// Finalizes and writes the 3MF package to disk.
    ///
    /// After calling this method, the writer can no longer be used to add files.
    /// - Throws: An error if writing or finalizing the archive fails.
    func finalize() throws {
        try writeMainFiles()
        try writeMetaFiles()
        try archive.finalize()
    }
}

public extension PackageWriter<Data> {
    /// Creates a writer that builds a 3MF package in memory.
    convenience init() {
        self.init(archive: ZipArchive())
    }

    /// Finalizes and returns the 3MF package as data.
    ///
    /// - Returns: The generated 3MF archive data.
    /// - Throws: An error if writing or finalizing the archive fails.
    func finalize() throws -> Data {
        try writeMainFiles()
        try writeMetaFiles()
        return try archive.finalize()
    }

    /// Finalizes and returns the 3MF package as data.
    ///
    /// This async variant allows preparing files concurrently when needed.
    /// - Returns: The generated 3MF archive data.
    /// - Throws: An error if writing or finalizing the archive fails.
    func finalize() async throws -> Data {
        try await writeMainFiles()
        try writeMetaFiles()
        return try archive.finalize()
    }
}

public extension PackageWriter {
    /// Adds a file to the package at the specified URL, with optional content type and relationship metadata.
    ///
    /// If a file already exists at this path (whether added earlier this way, or the root/an additional
    /// model), it's replaced. Nothing is written to the underlying archive until ``finalize()``.
    ///
    /// - Parameters:
    ///   - url: The destination URL within the package.
    ///   - mimeType: The file's MIME type to be recorded in content types. Pass `nil` to skip.
    ///   - relationshipType: An optional relationship type to record. Pass `nil` to skip.
    ///   - relativeToRootModel: Whether to attach the relationship to the root model file instead of the package root.
    ///   - data: The file contents.
    func addFile(
        at url: URL,
        contentType mimeType: String?,
        relationshipType: String?,
        relativeToRootModel: Bool = false,
        data: Data
    ) {
        register(url: url, contentType: mimeType, relationshipType: relationshipType, relativeToRootModel: relativeToRootModel)
        stagedFiles[url.packagePartPath] = data
    }

    /// Reads the current staged contents of a file at the given URL, or `nil` if nothing is there.
    ///
    /// This includes anything added via ``addFile(at:contentType:relationshipType:relativeToRootModel:data:)``,
    /// as well as the root model and any additional model (registered via ``addAdditionalModel(_:named:)``)
    /// — those are serialized to their current XML on first access (by this method, or by ``finalize()``
    /// if nothing reads them first) and cached, so a later call sees whatever the most recent write left
    /// there, and ``finalize()`` writes exactly that.
    ///
    /// - Parameter url: The URL to read within the package.
    /// - Returns: The file's current contents, or `nil` if no file exists there.
    /// - Throws: An error if a model needs to be serialized to satisfy this read and that fails.
    func fileContents(at url: URL) throws -> Data? {
        try stageModelFilesIfNeeded()
        return stagedFiles[url.packagePartPath]
    }

    /// Adds a texture to the package and returns its assigned URL.
    ///
    /// The file is numbered automatically and registered with the appropriate content type and relationship.
    /// - Parameter data: The texture file data.
    /// - Returns: The URL assigned to the texture within the package.
    func addTexture(data: Data) -> URL {
        addNumberedFile(
            base: "Textures/Texture",
            contentType: MimeType.modelTexture.rawValue,
            relationshipType: RelationshipType.texture.rawValue,
            data: data
        )
    }

    /// Adds a thumbnail to the package and returns its assigned URL.
    ///
    /// The file is numbered automatically and registered with the appropriate content type and relationship.
    /// - Parameters:
    ///   - data: The thumbnail image data.
    ///   - mimeType: The thumbnail image MIME type (e.g., "image/png").
    /// - Returns: The URL assigned to the thumbnail within the package.
    func addThumbnail(data: Data, mimeType: String) -> URL {
        addNumberedFile(
            base: "Metadata/Thumbnail",
            contentType: mimeType,
            relationshipType: RelationshipType.thumbnail.rawValue,
            data: data
        )
    }

    /// Registers an additional model to be included in the package and returns the URL it will be written to.
    ///
    /// If a model with the same name already exists, a numeric suffix is added to ensure uniqueness.
    /// - Parameters:
    ///   - model: The additional model to include.
    ///   - name: The desired base name (without extension) of the model file.
    /// - Returns: The URL where the model will be written inside the package.
    /// - Throws: An error if the name is invalid.
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
    // Cura is sadly hard-coded to always read this file name, so keep it for compatibility
    static var rootModelURL: URL { URL(string: "/3D/3dmodel.model")! }

    // Records a file's content type and relationship without staging any bytes for it. Kept separate
    // from addFile so the model files can be registered even when their bytes are already staged.
    func register(url: URL, contentType mimeType: String?, relationshipType: String?, relativeToRootModel: Bool) {
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
    }

    func addNumberedFile(base: String, contentType mimeType: String, relationshipType: String, data: Data) -> URL {
        let existingCount = relationships.count(ofType: relationshipType)
        // Absolute, like every other part this writer names: the URL is handed back to the caller to
        // reference from the model, and it's what the content type override is written from.
        guard let uri = URL(string: "/\(base)\(existingCount + 1)") else {
            fatalError("Failed to create numbered URL")
        }
        addFile(at: uri, contentType: mimeType, relationshipType: relationshipType, data: data)
        return uri
    }

    // The root model plus every registered additional model, with the path each is (or would be)
    // staged at, and whether its relationship is relative to the root model file.
    var modelFileEntries: [(url: URL, model: Model, relativeToRootModel: Bool)] {
        var entries: [(url: URL, model: Model, relativeToRootModel: Bool)] = [(Self.rootModelURL, model, false)]
        for (name, additionalModel) in additionalModels {
            guard let modelURL = URL(string: "/3D/\(name).model") else { continue }
            entries.append((modelURL, additionalModel, true))
        }
        return entries
    }

    // Serializes and stages the root model and any additional model not already staged (i.e. not
    // already read via `fileContents(at:)` or overwritten via `addFile`). Safe to call repeatedly —
    // already-staged paths are left untouched, so anything staged with different content stays that way.
    func stageModelFilesIfNeeded() throws {
        registerModelFiles()
        for entry in modelFileEntries where stagedFiles[entry.url.packagePartPath] == nil {
            stagedFiles[entry.url.packagePartPath] = try entry.model.xmlDocument().xmlData(options: .raw)
        }
    }

    // A model's content type and relationship have to be recorded even when its bytes are already
    // staged: a caller can write a model file's raw XML with addFile before anything serializes it,
    // and skipping registration for it would leave the package with no model relationship at all,
    // which makes it unreadable.
    func registerModelFiles() {
        for entry in modelFileEntries {
            register(
                url: entry.url,
                contentType: MimeType.model.rawValue,
                relationshipType: RelationshipType.model.rawValue,
                relativeToRootModel: entry.relativeToRootModel
            )
        }
    }

    // Same as the synchronous version, but serializes any not-yet-staged models concurrently.
    func stageModelFilesIfNeededConcurrently() async throws {
        registerModelFiles()
        let pending = modelFileEntries.filter { stagedFiles[$0.url.packagePartPath] == nil }
        let staged = try await pending.asyncMap { entry in
            try (entry: entry, data: entry.model.xmlDocument().xmlData(options: .raw))
        }
        for (entry, data) in staged {
            stagedFiles[entry.url.packagePartPath] = data
        }
    }

    func writeMetaFiles() throws {
        guard let modelRelationshipsURL = URL(string: "/3D/_rels/3dmodel.model.rels") else {
            fatalError("Failed to initialize model URL")
        }

        try archive.addFile(at: ContentTypes.archiveFileURL.packagePartPath, data: contentTypes.xmlDocument().xmlData(), compression: compressionLevel)
        try archive.addFile(at: Relationships.archiveFileURL.packagePartPath, data: relationships.xmlDocument().xmlData(), compression: compressionLevel)
        if !modelFileRelationships.isEmpty {
            try archive.addFile(at: modelRelationshipsURL.packagePartPath, data: modelFileRelationships.xmlDocument().xmlData(), compression: compressionLevel)
        }
    }

    func writeMainFiles() throws {
        try stageModelFilesIfNeeded()
        for (path, data) in stagedFiles {
            try archive.addFile(at: path, data: data, compression: compressionLevel)
        }
    }

    func writeMainFiles() async throws {
        try await stageModelFilesIfNeededConcurrently()
        for (path, data) in stagedFiles {
            try archive.addFile(at: path, data: data, compression: compressionLevel)
        }
    }
}
