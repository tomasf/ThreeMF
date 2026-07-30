import Testing
import Foundation
@testable import ThreeMF

struct Texture2DTests {
    @Test func `texture round trips with all optional fields populated`() throws {
        let texture = Texture2D(
            id: 1,
            pathURL: URL(string: "/Textures/tex.png")!,
            contentType: .png,
            tileStyleU: .mirror,
            tileStyleV: .clamp,
            filter: .nearest
        )
        let decoded = try roundTrip(texture)
        #expect(decoded.id == 1)
        #expect(decoded.pathURL == texture.pathURL)
        #expect(decoded.contentType == .png)
        #expect(decoded.tileStyleU == .mirror)
        #expect(decoded.tileStyleV == .clamp)
        #expect(decoded.filter == .nearest)
    }

    @Test func `texture round trips with all optional fields nil`() throws {
        let texture = Texture2D(id: 1, pathURL: URL(string: "/Textures/tex.jpg")!, contentType: .jpeg)
        let decoded = try roundTrip(texture)
        #expect(decoded.tileStyleU == nil)
        #expect(decoded.tileStyleV == nil)
        #expect(decoded.filter == nil)
    }

    @Test func `effectiveTileStyles defaults independently per axis`() {
        let bothNil = Texture2D(id: 1, pathURL: URL(string: "/t.png")!, contentType: .png)
        #expect(bothNil.effectiveTileStyles.U == .wrap)
        #expect(bothNil.effectiveTileStyles.V == .wrap)

        let onlyU = Texture2D(id: 1, pathURL: URL(string: "/t.png")!, contentType: .png, tileStyleU: .clamp)
        #expect(onlyU.effectiveTileStyles.U == .clamp)
        #expect(onlyU.effectiveTileStyles.V == .wrap)

        // `.none` here would resolve to Optional.none (nil), not the TileStyle.none case — spell it
        // out explicitly to actually exercise the "no tiling" case rather than the "unset" one.
        let onlyV = Texture2D(id: 1, pathURL: URL(string: "/t.png")!, contentType: .png, tileStyleV: Texture2D.TileStyle.none)
        #expect(onlyV.effectiveTileStyles.U == .wrap)
        #expect(onlyV.effectiveTileStyles.V == Texture2D.TileStyle.none)
    }
}
