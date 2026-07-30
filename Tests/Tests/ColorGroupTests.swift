import Testing
@testable import ThreeMF

struct ColorGroupTests {
    @Test func `color group round trips with several distinct colors`() throws {
        var group = ColorGroup(id: 1, displayPropertiesID: 9, colors: [])
        group.addColor(Color(red: 0x11, green: 0x22, blue: 0x33))
        group.addColor(Color(red: 0x44, green: 0x55, blue: 0x66))

        let decoded = try roundTrip(group)
        #expect(decoded.id == 1)
        #expect(decoded.displayPropertiesID == 9)
        #expect(decoded.colors == group.colors)
    }

    @Test func `addColor returns the appended index`() {
        var group = ColorGroup(id: 1)
        #expect(group.addColor(Color(red: 1, green: 1, blue: 1)) == 0)
        #expect(group.addColor(Color(red: 2, green: 2, blue: 2)) == 1)
        #expect(group.colors.count == 2)
    }

    @Test func `empty colors round trips with no child elements`() throws {
        let group = ColorGroup(id: 1, colors: [])
        let decoded = try roundTrip(group)
        #expect(decoded.colors.isEmpty)
    }
}
