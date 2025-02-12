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

            let document = Document()
            let root = document.makeRootElement(name: "")
            model.build(element: root)

            xmlInput.expectEquivalence(with: root)

            let writer = PackageWriter()
            writer.model = model
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

extension XMLNode {
    static let numericalAttributes = Set(["x", "y", "z", "transform"])
    var attributeValue: String {
        let string = stringValue ?? ""
        if Self.numericalAttributes.contains(localName ?? "") {
            return string.split(separator: " ").map {
                String(format: "%g", Double($0) ?? 0)
            }.joined(separator: " ")
        } else {
            return string
        }
    }
}

extension Node {
    var canonicalElements: [ExpandedName: [Element]] {
        elements.reduce(into: [:]) { result, element in
            result[element.expandedName, default: []].append(element)
        }
    }

    func expectEquivalence(with other: Node) {
        #expect(attributes == other.attributes, "Attributes differ: \(path ?? "")")
        guard attributes == other.attributes else { return }
        #expect(concatenatedText == other.concatenatedText, "Element text differs: \(path ?? "")")
        guard concatenatedText == other.concatenatedText else { return }

        let elements1 = canonicalElements
        let elements2 = other.canonicalElements
        let allIdentities = Set(elements1.keys).union(elements2.keys)
        #expect(elements1.count == elements2.count, "Number of element types differs in \(path). \(elements1.keys) vs. \(elements2.keys)")
        guard elements1.count == elements2.count else { return }

        for identity in allIdentities {
            let elements = elements1[identity] ?? []
            let otherElements = elements2[identity] ?? []
            #expect(elements.count == otherElements.count, "Number of elements of type \(identity) differs: \(path ?? "")")

            guard elements.count == otherElements.count else { return }
            for (index, element) in elements.enumerated() {
                let otherElement = otherElements[index]
                element.expectEquivalence(with: otherElement)
            }
        }
    }
}
