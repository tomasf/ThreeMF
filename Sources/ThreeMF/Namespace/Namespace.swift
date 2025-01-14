import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

internal struct Namespace: Hashable {
    let uri: String
    let standardPrefix: String?
    let name: String

    init(uri: String, standardPrefix: String?, name: String) {
        self.uri = uri
        self.standardPrefix = standardPrefix
        self.name = name
    }
}

extension Namespace {
    static var known: Set<Self> {
        [.core, .triangleSets, .mirroring, .materials, .volumetric, .implicit, .boolean, .displacement, .slice]
    }

    static func namespace(for uri: String) -> Self? {
        return Self.known.first(where: { $0.uri == uri })
    }
}

extension Namespace {
    static let xml = Self(
        uri: "http://www.w3.org/XML/1998/namespace",
        standardPrefix: "xml",
        name: "XML"
    )

    static let core = Self(
        uri: "http://schemas.microsoft.com/3dmanufacturing/core/2015/02",
        standardPrefix: nil,
        name: "Core"
    )

    static let triangleSets = Self(
        uri: "http://schemas.microsoft.com/3dmanufacturing/trianglesets/2021/07",
        standardPrefix: "t",
        name: "Triangle Sets"
    )

    static let materials = Self(
        uri: "http://schemas.microsoft.com/3dmanufacturing/material/2015/02",
        standardPrefix: "m",
        name: "Materials and Properties"
    )

    static let mirroring = Self(
        uri: "http://schemas.microsoft.com/3dmanufacturing/mirroring/2021/07",
        standardPrefix: "mm",
        name: "Mirroring"
    )

    static let volumetric = Self(
        uri: "http://schemas.3mf.io/3dmanufacturing/volumetric/2022/01",
        standardPrefix: "v",
        name: "Volumetric"
    )

    static let implicit = Self(
        uri: "http://schemas.3mf.io/3dmanufacturing/implicit/2023/12",
        standardPrefix: "i",
        name: "Implicit"
    )

    static let boolean = Self(
        uri: "http://schemas.3mf.io/3dmanufacturing/booleanoperations/2023/07",
        standardPrefix: "bo",
        name: "Boolean Operations"
    )

    static let displacement = Self(
        uri: "http://schemas.3mf.io/3dmanufacturing/displacement/2023/10",
        standardPrefix: "d",
        name: "Displacement"
    )

    static let slice = Self(
        uri: "http://schemas.microsoft.com/3dmanufacturing/slice/2015/07",
        standardPrefix: "s",
        name: "Slice"
    )
}
