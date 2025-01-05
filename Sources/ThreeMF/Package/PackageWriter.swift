import Foundation
import Zip
#if canImport(FoundationXML)
import FoundationXML
#endif

public struct PackageWriter<Target> {
    private let archive: ZipArchive<Target>
    public var model: Model = Model()

    private init(archive: ZipArchive<Target>) {
        self.archive = archive
    }
}

public extension PackageWriter<URL> {
    init(url fileURL: URL) throws {
        try self.init(archive: ZipArchive(url: fileURL, mode: .overwrite))
    }

    // Write the 3MF file to disk
    func finalize() throws {
        try archive.finalize()
    }
}

public extension PackageWriter<Data> {
    init() {
        self.init(archive: ZipArchive())
    }

    // Generate the 3MF data
    func finalize() throws -> Data {
        try archive.finalize()
    }
}

public extension PackageWriter {
    // Add additional files such as thumbnails or textures
    func addFile(at url: URL, data: Data) throws {
        var filePath = url.path
        if filePath.hasPrefix("/") {
            filePath.removeFirst()
        }
        return try archive.addFile(at: filePath, data: data)
    }
}

internal extension PackageWriter {
    func writeMainFiles() throws {
        
    }
}
