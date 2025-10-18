import Foundation
import Zip
import Nodal

/// Reads 3MF packages from either a file URL or in‑memory data and provides access to parsed models and file contents.
///
/// PackageReader abstracts the underlying ZIP archive and exposes high‑level methods to:
/// - Load the root model or a model at a specific path inside the package
/// - Read raw file data from a given URL within the package
///
/// Usage:
/// - Initialize with a URL or Data
/// - Call `model()` to load the root model, or `model(at:)` to load a specific model file
/// - Use `readFile(at:)` to access arbitrary file contents inside the package
/// 
public struct PackageReader<Target> {
    private let archive: ZipArchive<Target>

    private init(archive: ZipArchive<Target>) throws {
        self.archive = archive
    }
}

public extension PackageReader<URL> {
    /// Creates a reader that opens a 3MF package from a file URL.
    ///
    /// - Parameter fileURL: The URL of the 3MF package to open.
    /// - Throws: An error if the archive cannot be opened.
    init(url fileURL: URL) throws {
        try self.init(archive: ZipArchive(url: fileURL, mode: .readOnly))
    }

    /// Closes the underlying archive and releases associated resources.
    ///
    /// Call this when you are done reading from the package to ensure resources are freed promptly.
    func invalidate() {
        archive.close()
    }
}

public extension PackageReader<Data> {
    /// Creates a reader that opens a 3MF package from in‑memory data.
    ///
    /// - Parameter data: The 3MF package data.
    /// - Throws: An error if the archive cannot be opened.
    init(data: Data) throws {
        try self.init(archive: ZipArchive(data: data))
    }
}

internal extension PackageReader {
    func startPartURL() throws(ThreeMFError) -> URL {
        let relationships = try Relationships(zipArchive: archive)

        guard let url = relationships.firstTarget(ofType: RelationshipType.model.rawValue) else {
            throw ThreeMFError.malformedRelationships(nil)
        }
        return url
    }

    func modelRootElement(at path: URL?) throws(ThreeMFError) -> Node {
        let resolvedPath = if let path { path } else { try startPartURL() }

        guard let modelData = try? readFile(at: resolvedPath) else {
            throw .failedToReadArchiveFile(name: resolvedPath.relativePath, error: nil)
        }

        let modelDocument: Document
        do {
            modelDocument = try Document(data: modelData)
        } catch {
            throw .failedToReadArchiveFile(name: resolvedPath.relativePath, error: error)
        }

        guard let root = modelDocument.documentElement else {
            throw .failedToReadArchiveFile(name: resolvedPath.relativePath, error: nil)
        }
        return root
    }
}

public extension PackageReader {
    /// Loads and parses a 3MF model from the package.
    ///
    /// - Parameter path: The URL of a specific model within the package. If `nil`, the package's root model is loaded.
    /// - Returns: A parsed `Model` instance.
    /// - Throws: Errors related to reading or parsing the model from the package.
    func model(at path: URL? = nil) throws -> Model {
        return try Model(from: modelRootElement(at: path))
    }

    /// Reads raw data for a file stored within the package.
    ///
    /// - Parameter url: The URL of the file within the package (e.g., a texture or auxiliary asset).
    /// - Returns: The file data if present, or `nil` if the file cannot be found.
    /// - Throws: An error if the archive cannot be read.
    func readFile(at url: URL) throws -> Data? {
        var filePath = url.path
        if filePath.hasPrefix("/") {
            filePath.removeFirst()
        }
        return try archive.fileContents(at: filePath)
    }
}
