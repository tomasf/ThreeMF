import Foundation
import Nodal

extension AttributeName where Self == ExpandedName {
    static private func attribute(_ localName: String) -> ExpandedName {
        ExpandedName(namespaceName: nil, localName: localName)
    }

    // MARK: - Core
    static var id: Self { attribute("id") }
    static var name: Self { attribute("name") }
    static var type: Self { attribute("type") }

    static var thumbnail: Self { attribute("thumbnail") }
    static var partNumber: Self { attribute("partnumber") }
    static var displayColor: Self { attribute("displaycolor") }

    static var unit: Self { attribute("unit") }

    static var language: Self { attribute("language") }
    static var requiredExtensions: Self { attribute("requiredextensions") }
    static var recommendedExtensions: Self { attribute("recommendedextensions") }

    static var preserve: Self { attribute("preserve") }
    static var transform: Self { attribute("transform") }
    static var objectID: Self { attribute("objectid") }

    static var v1: Self { attribute("v1") }
    static var v2: Self { attribute("v2") }
    static var v3: Self { attribute("v3") }

    static var x: Self { attribute("x") }
    static var y: Self { attribute("y") }
    static var z: Self { attribute("z") }

    static var pid: Self { attribute("pid") }
    static var pIndex: Self { attribute("pindex") }
    static var p1: Self { attribute("p1") }
    static var p2: Self { attribute("p2") }
    static var p3: Self { attribute("p3") }

    // MARK: - Materials
    static var displayPropertiesID: Self { attribute("displaypropertiesid") }
    static var values: Self { attribute("values") }
    static var path: Self { attribute("path") }
    static var contentType: Self { attribute("contenttype") }
    static var color: Self { attribute("color") }

    static var matID: Self { attribute("matid") }
    static var matIndices: Self { attribute("matindices") }
    static var pids: Self { attribute("pids") }
    static var pIndices: Self { attribute("pindices") }
    static var blendMethods: Self { attribute("blendmethods") }
    static var filter: Self { attribute("filter") }
    static var texID: Self { attribute("texid") }
    static var u: Self { attribute("u") }
    static var v: Self { attribute("v") }

    static var tileStyleU: Self { attribute("tilestyleu") }
    static var tileStyleV: Self { attribute("tilestylev") }

    static var metallicness: Self { attribute("metallicness") }
    static var roughness: Self { attribute("roughness") }

    static var metallicTextureID: Self { attribute("metallictextureid") }
    static var roughnessTextureID: Self { attribute("roughnesstextureid") }
    static var baseColorFactor: Self { attribute("basecolorfactor") }
    static var metallicFactor: Self { attribute("metallicfactor") }
    static var roughnessFactor: Self { attribute("roughnessfactor") }

    static var specularColor: Self { attribute("specularcolor") }
    static var glossiness: Self { attribute("glossiness") }

    static var specularTextureID: Self { attribute("speculartextureid") }
    static var glossinessTextureID: Self { attribute("glossinesstextureid") }
    static var diffuseFactor: Self { attribute("diffusefactor") }
    static var specularFactor: Self { attribute("specularfactor") }
    static var glossinessFactor: Self { attribute("glossinessfactor") }

    static var attenuation: Self { attribute("attenuation") }
    static var refractiveIndex: Self { attribute("refractiveindex") }

    // MARK: - Triangle sets
    static var index: Self { attribute("index") }
    static var startIndex: Self { attribute("startindex") }
    static var endIndex: Self { attribute("endindex") }
    static var identifier: Self { attribute("identifier") }
}
