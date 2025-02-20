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
        try self.init(archive: ZipArchive(url: fileURL))
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

public extension PackageReader {
    private var relationshipsFile: String { "_rels/.rels" }

    func startPartURL() throws(Error) -> URL {
        let relsData: Data
        do {
            relsData = try archive.fileContents(at: relationshipsFile)
        } catch {
            throw .failedToReadArchiveFile(name: relationshipsFile, error: error)
        }

        let relsDocument: Document
        do {
            relsDocument = try Document(data: relsData)
        } catch {
            throw .malformedRelationships(error)
        }

        let modelURI = "http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"

        guard let relationships = relsDocument.documentElement,
              let modelRelationship = relationships[elements: "Relationship"].first(where: { $0[attribute: "Type"] == modelURI }),
              let target: String = modelRelationship[attribute: "Target"],
              let url = URL(string: target)
        else {
            throw Error.malformedRelationships(nil)
        }

        return url
    }

    internal func modelRootElement() throws(Error) -> Node {
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
