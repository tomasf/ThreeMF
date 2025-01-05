import Foundation
import ThreeMF
import Testing

struct Tests {
    @Test
    func test() throws {
        for url in URL.threeMFResources {
            print("Reading \(url)")
            let package = try PackageReader(url: url)
            let _ = try package.model()
        }
    }
}

extension URL {
    static func threeMFResource(named name: String) -> URL {
        Bundle.module.url(forResource: name, withExtension: "3mf", subdirectory: "3MF")!
    }

    static var threeMFResources: [URL] {
        guard let resources = Bundle.module.resourceURL?.appending(component: "3MF") else { return [] }
        guard let enumerator = FileManager().enumerator(at: resources, includingPropertiesForKeys: []) else { return [] }
        return enumerator.compactMap {
            guard let url = $0 as? URL else { return nil }
            if url.lastPathComponent.hasSuffix(".3mf") {
                return url
            } else {
                return nil
            }
        }
    }
}
