import Testing
@testable import ThreeMF

// Note: Materials.tex2Coord is spelled "text2coord" (extra "t") in Namespaces/Materials.swift,
// which looks like a typo relative to the 3MF spec's <m:tex2coord>. A round trip can't catch this
// since encode/decode both use the same (mis)spelled name symmetrically. Flagging it here as a
// real-world-interop concern outside what a unit test can surface, not something fixed by this suite.
struct Texture2DGroupTests {
    @Test func `texture group round trips with distinct ordered coordinates`() throws {
        let group = Texture2DGroup(
            id: 1,
            texture2DID: 2,
            displayPropertiesID: 3,
            coordinates: [
                Texture2DGroup.Coordinate(u: 0.1, v: 0.2),
                Texture2DGroup.Coordinate(u: 0.3, v: 0.4),
            ]
        )
        let decoded = try roundTrip(group)
        #expect(decoded.id == 1)
        #expect(decoded.texture2DID == 2)
        #expect(decoded.displayPropertiesID == 3)
        #expect(decoded.coordinates.map(\.u) == [0.1, 0.3])
        #expect(decoded.coordinates.map(\.v) == [0.2, 0.4])
    }
}
