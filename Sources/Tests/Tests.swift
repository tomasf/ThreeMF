import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif
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
            let xmlOutput = model.xmlElement

            xmlInput.expectEquivalence(with: xmlOutput)

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
    var canonicalIdentity: String? {
        let local = localName ?? ""
        if let uri {
            guard uri != "http://schemas.openxmlformats.org/markup-compatibility/2006" else { return nil }
            return uri + " " + local
        } else {
            return local
        }
    }

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

extension XMLElement {
    var text: String {
        (children ?? []).filter { $0.kind == .text }.compactMap(\.stringValue).joined()
    }

    var canonicalAttributes: [String: String] {
        Dictionary(uniqueKeysWithValues: (attributes ?? []).compactMap {
            guard let id = $0.canonicalIdentity else { return nil }
            return (id, $0.attributeValue)
        })
    }

    var canonicalElements: [String: [XMLElement]] {
        (children ?? []).compactMap { $0 as? XMLElement }.reduce(into: [:]) { result, element in
            guard let id = element.canonicalIdentity else { return }
            result[id, default: []].append(element)
        }
    }

    func expectEquivalence(with other: XMLElement) {
        #expect(canonicalAttributes == other.canonicalAttributes, "Attributes differ: \(xPath ?? "")")
        guard canonicalAttributes == other.canonicalAttributes else { return }
        #expect(text == other.text, "Element text differs: \(xPath ?? "")")
        guard stringValue == other.stringValue else { return }

        let elements1 = canonicalElements
        let elements2 = other.canonicalElements
        let allIdentities = Set(elements1.keys).union(elements2.keys)
        #expect(elements1.count == elements2.count, "Number of element types differs")
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
