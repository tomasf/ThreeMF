import Foundation
import Nodal
import Testing
@testable import ThreeMF

struct Tests {
    @Test
    func test() throws {
        let files = URL.threeMFResources
        print("Testing \(files.count) 3MF files")
        for url in files {
            print("Reading \(url.lastPathComponent)")
            let inData = try Data(contentsOf: url)
            let package = try PackageReader(data: inData)

            let xmlInput = try package.modelRootElement()
            let model = try package.model()

            let writer = PackageWriter()
            writer.model = model
            let document = writer.xmlDocument()

            xmlInput.expectEquivalence(with: document.documentElement!)

            let outData = try writer.finalize()
            print("Read: \(inData.count) bytes. Written: \(outData.count) bytes.")
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

extension String {
    var canonicalNumerical: String {
        return split(separator: " ").map {
            String(format: "%g", Double($0) ?? 0)
        }.joined(separator: " ")
    }
}

extension Node {
    var canonicalElements: [ExpandedName: [Node]] {
        elements.reduce(into: [:]) { result, element in
            result[element.expandedName, default: []].append(element)
        }
    }

    var canonicalAttributes: [[String]] {
        let numericalAttributes = Set(["x", "y", "z", "transform"])

        return attributes.sorted(by: { $0.name < $1.name }).map { name, value in
            if numericalAttributes.contains(name) {
                return [name, value.canonicalNumerical]
            } else {
                return [name, value.lowercased()]
            }
        }
    }

    func expectEquivalence(with other: Node) {
        #expect(canonicalAttributes == other.canonicalAttributes, "Attributes differ: \(xPath ?? "")")
        guard canonicalAttributes == other.canonicalAttributes else { return }
        #expect(textContent == other.textContent, "Element text differs: \(xPath ?? "")")
        guard textContent == other.textContent else {
            return
        }

        let elements1 = canonicalElements
        let elements2 = other.canonicalElements
        let allIdentities = Set(elements1.keys).union(elements2.keys)
        #expect(elements1.count == elements2.count, "Number of element types differs in \(xPath). \(elements1.keys) vs. \(elements2.keys)")
        guard elements1.count == elements2.count else { return }

        for identity in allIdentities {
            let elements = elements1[identity] ?? []
            let otherElements = elements2[identity] ?? []
            #expect(elements.count == otherElements.count, "Number of elements of type \(identity) differs: \(xPath ?? "")")

            guard elements.count == otherElements.count else { return }
            for (index, element) in elements.enumerated() {
                let otherElement = otherElements[index]
                element.expectEquivalence(with: otherElement)
            }
        }
    }
}
