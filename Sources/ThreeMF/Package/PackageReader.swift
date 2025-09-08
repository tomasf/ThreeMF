import Foundation
import Zip
import Nodal

public struct PackageReader<Target> {
    private let archive: ZipArchive<Target>

    private init(archive: ZipArchive<Target>) throws {
        self.archive = archive
    }
}

public extension PackageReader<URL> {
    init(url fileURL: URL) throws {
        try self.init(archive: ZipArchive(url: fileURL, mode: .readOnly))
    }

    func invalidate() {
        archive.close()
    }
}

public extension PackageReader<Data> {
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

    func modelRootElement() throws(ThreeMFError) -> Node {
        let startPart = try startPartURL()
        guard let modelData = try? readFile(at: startPart) else {
            throw .failedToReadArchiveFile(name: startPart.relativePath, error: nil)
        }

        let modelDocument: Document
        do {
            modelDocument = try Document(data: modelData)
        } catch {
            throw .failedToReadArchiveFile(name: startPart.relativePath, error: error)
        }

        guard let root = modelDocument.documentElement else {
            throw .failedToReadArchiveFile(name: startPart.relativePath, error: nil)
        }
        return root
    }
}

public extension PackageReader {
    func model() throws -> Model {
        return try Model(from: modelRootElement())
    }

    func readFile(at url: URL) throws -> Data? {
        var filePath = url.path
        if filePath.hasPrefix("/") {
            filePath.removeFirst()
        }
        return try archive.fileContents(at: filePath)
    }
}
