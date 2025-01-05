import Foundation
import Zip
#if canImport(FoundationXML)
import FoundationXML
#endif

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

        let relsDocument: XMLDocument
        do {
            relsDocument = try XMLDocument(data: relsData)

            guard let target = try relsDocument.nodes(forXPath: "/Relationships/Relationship[@Type=\"http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel\"]/@Target").first?.stringValue else {
                throw Error.malformedRelationships(nil)
            }

            guard let url = URL(string: target) else {
                throw Error.malformedRelationships(nil)
            }
            return url
        } catch {
            throw .malformedRelationships(error)
        }
    }

    func model() throws(Error) -> Model {
        let startPart = try startPartURL()
        guard let modelData = try? readFile(at: startPart) else {
            throw .failedToReadArchiveFile(name: startPart.path, error: nil)
        }

        let modelDocument: XMLDocument
        do {
            modelDocument = try XMLDocument(data: modelData)
        } catch {
            throw .failedToReadArchiveFile(name: startPart.path, error: error)
        }

        guard let root = modelDocument.rootElement() else {
            throw .failedToReadArchiveFile(name: startPart.path, error: nil)
        }

        return try Model(xmlElement: root)
    }

    func readFile(at url: URL) throws -> Data? {
        var filePath = url.path
        if filePath.hasPrefix("/") {
            filePath.removeFirst()
        }
        return try archive.fileContents(at: filePath)
    }
}
