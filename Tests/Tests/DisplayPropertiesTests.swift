import Testing
@testable import ThreeMF

struct DisplayPropertiesTests {
    @Test func `metallic display properties round trips and addMetallic appends`() throws {
        var group = MetallicDisplayProperties(id: 1)
        #expect(group.addMetallic(Metallic(name: "M1", metallicness: 0.1, roughness: 0.2)) == 0)
        #expect(group.addMetallic(Metallic(name: "M2", metallicness: 0.3, roughness: 0.4)) == 1)

        let decoded = try roundTrip(group)
        #expect(decoded.id == 1)
        #expect(decoded.metallics == group.metallics)
    }

    @Test func `specular display properties round trips with values nil and populated`() throws {
        var group = SpecularDisplayProperties(id: 1)
        group.addSpecular(Specular(name: "S1"))
        group.addSpecular(Specular(name: "S2", specularColor: Color(red: 1, green: 2, blue: 3), glossiness: 0.5))

        let decoded = try roundTrip(group)
        #expect(decoded.speculars == group.speculars)

        let nilSpecular = decoded.speculars[0]
        #expect(nilSpecular.specularColor == nil)
        #expect(nilSpecular.glossiness == nil)
        #expect(nilSpecular.effectiveValues.specularColor == Color(red: 0x38, green: 0x38, blue: 0x38))
        #expect(nilSpecular.effectiveValues.glossiness == 0)
    }

    @Test func `translucent display properties round trips including multi-value lists`() throws {
        let group = TranslucentDisplayProperties(id: 1, translucents: [
            Translucent(name: "T1", attenuation: [0.1, 0.2, 0.3], refractiveIndices: [1.1, 1.2, 1.3], roughness: 0.4),
            Translucent(name: "T2", attenuation: [], refractiveIndices: [], roughness: nil),
        ])
        let decoded = try roundTrip(group)
        #expect(decoded.translucents.map(\.name) == ["T1", "T2"])
        #expect(decoded.translucents[0].attenuation == [0.1, 0.2, 0.3])
        #expect(decoded.translucents[0].refractiveIndices == [1.1, 1.2, 1.3])
        #expect(decoded.translucents[0].roughness == 0.4)
        #expect(decoded.translucents[1].roughness == nil)
    }

    @Test func `metallic texture display properties round trips and defaults independently`() throws {
        let properties = MetallicTextureDisplayProperties(
            id: 1, name: "MT", metallicTextureID: 2, roughnessTextureID: 3,
            baseColorFactor: Color(red: 9, green: 9, blue: 9), metallicFactor: 0.7, roughnessFactor: 0.8
        )
        let decoded = try roundTrip(properties)
        #expect(decoded.metallicTextureID == 2)
        #expect(decoded.roughnessTextureID == 3)
        #expect(decoded.baseColorFactor == properties.baseColorFactor)
        #expect(decoded.metallicFactor == 0.7)
        #expect(decoded.roughnessFactor == 0.8)

        let defaults = MetallicTextureDisplayProperties(id: 1, name: "MT", metallicTextureID: 2, roughnessTextureID: 3)
        #expect(defaults.effectiveFactors.baseColorFactor == .white)
        #expect(defaults.effectiveFactors.metallicFactor == 1)
        #expect(defaults.effectiveFactors.roughnessFactor == 1)
    }

    @Test func `specular texture display properties round trips and defaults independently`() throws {
        let properties = SpecularTextureDisplayProperties(
            id: 1, name: "ST", specularTextureID: 2, glossinessTextureID: 3,
            diffuseFactor: Color(red: 1, green: 2, blue: 3), specularFactor: Color(red: 4, green: 5, blue: 6), glossinessFactor: 0.9
        )
        let decoded = try roundTrip(properties)
        #expect(decoded.specularTextureID == 2)
        #expect(decoded.glossinessTextureID == 3)
        #expect(decoded.diffuseFactor == properties.diffuseFactor)
        #expect(decoded.specularFactor == properties.specularFactor)
        #expect(decoded.glossinessFactor == 0.9)

        let defaults = SpecularTextureDisplayProperties(id: 1, name: "ST", specularTextureID: 2, glossinessTextureID: 3)
        #expect(defaults.effectiveFactors.diffuseFactor == .white)
        #expect(defaults.effectiveFactors.specularFactor == .white)
        #expect(defaults.effectiveFactors.glossinessFactor == 1)
    }
}
