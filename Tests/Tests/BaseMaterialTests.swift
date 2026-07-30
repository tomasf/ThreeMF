import Testing
@testable import ThreeMF

struct BaseMaterialTests {
    @Test func `base material group round trips with multiple materials`() throws {
        let group = BaseMaterialGroup(id: 1, displayPropertiesID: 5, properties: [
            BaseMaterial(name: "Red", displayColor: Color(red: 0xFF, green: 0, blue: 0)),
            BaseMaterial(name: "Blue", displayColor: Color(red: 0, green: 0, blue: 0xFF)),
        ])
        let decoded = try roundTrip(group)
        #expect(decoded.id == 1)
        #expect(decoded.displayPropertiesID == 5)
        #expect(decoded.properties.map(\.name) == ["Red", "Blue"])
        #expect(decoded.properties.map(\.displayColor) == [Color(red: 0xFF, green: 0, blue: 0), Color(red: 0, green: 0, blue: 0xFF)])
    }

    @Test func `single base material round trips`() throws {
        let material = BaseMaterial(name: "Green", displayColor: Color(red: 0, green: 0xFF, blue: 0))
        let decoded = try roundTrip(material)
        #expect(decoded.name == "Green")
        #expect(decoded.displayColor == material.displayColor)
    }
}
