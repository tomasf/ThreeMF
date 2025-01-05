import Foundation

public struct Extension: Hashable, Sendable {
    public let name: String
    public let prefix: Prefix
    public let uri: String

    public init(name: String, prefix: String, uri: String) {
        self.name = name
        self.prefix = prefix
        self.uri = uri
    }
}

public extension Extension {
    typealias Prefix = String

    static var known: Set<Self> {
        [.triangleSets, .mirroring, .materials, .volumetric, .implicit, .boolean, .displacement, .slice]
    }

    init?(prefix: Prefix) {
        guard let preset = Self.known.first(where: { $0.prefix == prefix }) else {
            return nil
        }
        self = preset
    }
}

public extension Extension {
    static let triangleSets = Extension(
        name: "Triangle Sets",
        prefix: "t",
        uri: "http://schemas.microsoft.com/3dmanufacturing/trianglesets/2021/07"
    )

    static let materials = Extension(
        name: "Materials and Properties",
        prefix: "m",
        uri: "http://schemas.microsoft.com/3dmanufacturing/material/2015/02"
    )

    static let mirroring = Extension(
        name: "Mirroring",
        prefix: "mm",
        uri: "http://schemas.microsoft.com/3dmanufacturing/mirroring/2021/07"
    )

    static let volumetric = Extension(
        name: "Volumetric",
        prefix: "v",
        uri: "http://schemas.3mf.io/3dmanufacturing/volumetric/2022/01"
    )

    static let implicit = Extension(
        name: "Implicit",
        prefix: "i",
        uri: "http://schemas.3mf.io/3dmanufacturing/implicit/2023/12"
    )

    static let boolean = Extension(
        name: "Boolean Operations",
        prefix: "bo",
        uri: "http://schemas.3mf.io/3dmanufacturing/booleanoperations/2023/07"
    )

    static let displacement = Extension(
        name: "Displacement",
        prefix: "d",
        uri: "http://schemas.3mf.io/3dmanufacturing/displacement/2023/10"
    )

    static let slice = Extension(
        name: "Slice",
        prefix: "s",
        uri: "http://schemas.microsoft.com/3dmanufacturing/slice/2015/07"
    )
}

public extension Model {
    func unsupportedRequiredExtensions(supportedExtensions: Set<Extension.Prefix>) -> Set<Extension.Prefix> {
        (requiredExtensionPrefixes ?? []).subtracting(supportedExtensions)
    }

    func unsupportedRecommendedExtensions(supportedExtensions: Set<Extension.Prefix>) -> Set<Extension.Prefix> {
        (recommendedExtensionPrefixes ?? []).subtracting(supportedExtensions)
    }
}

// Extensions supported by this library
public extension Model {
    static let extensionPrefixesSupportedByLibrary: Set<Extension.Prefix> = [
        Extension.triangleSets.prefix, Extension.materials.prefix
    ]

    var librarySupportsRequiredExtensions: Bool {
        (requiredExtensionPrefixes ?? []).allSatisfy { Self.extensionPrefixesSupportedByLibrary.contains($0) }
    }

    var recommendedExtensionPrefixesUnsupportedByLibrary: Set<Extension.Prefix> {
        (recommendedExtensionPrefixes ?? []).filter { !Self.extensionPrefixesSupportedByLibrary.contains($0) }
    }
}
