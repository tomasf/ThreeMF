import Testing
import Foundation
@testable import ThreeMF

struct ComponentAndAlternativesTests {
    @Test func `component round trips with every field populated`() throws {
        let component = Component(
            objectID: 3,
            transform: Matrix3D(values: [[1, 0, 0], [0, 1, 0], [0, 0, 1], [10, 20, 30]]),
            path: URL(string: "/3D/other.model"),
            uuid: UUID()
        )
        let decoded = try roundTrip(component)
        #expect(decoded.objectID == 3)
        #expect(decoded.transform?.values == component.transform?.values)
        #expect(decoded.path == component.path)
        #expect(decoded.uuid == component.uuid)
    }

    @Test func `component with all optional fields nil round trips`() throws {
        let component = Component(objectID: 4)
        let decoded = try roundTrip(component)
        #expect(decoded.objectID == 4)
        #expect(decoded.transform == nil)
        #expect(decoded.path == nil)
        #expect(decoded.uuid == nil)
    }

    @Test func `alternative round trips with fields populated`() throws {
        let uuid = UUID()
        let alternative = Alternative(objectID: 7, uuid: uuid, path: URL(string: "/3D/alt.model"), modelResolution: .low)
        let decoded = try roundTrip(alternative)
        #expect(decoded.objectID == 7)
        #expect(decoded.uuid == uuid)
        #expect(decoded.path == alternative.path)
        #expect(decoded.modelResolution == .low)
    }

    @Test func `alternative with optional fields nil round trips`() throws {
        let alternative = Alternative(objectID: 8)
        let decoded = try roundTrip(alternative)
        #expect(decoded.objectID == 8)
        #expect(decoded.path == nil)
        #expect(decoded.modelResolution == nil)
    }

    @Test func `object alternatives and modelResolution round trip with multiple alternatives`() throws {
        let object = Object(
            id: 1,
            modelResolution: .full,
            alternatives: [
                Alternative(objectID: 2, path: URL(string: "/3D/a.model")),
                Alternative(objectID: 3, path: URL(string: "/3D/b.model")),
            ],
            content: .mesh(triangleMesh())
        )
        let decoded = try roundTrip(object)
        #expect(decoded.modelResolution == .full)
        #expect(decoded.alternatives.map(\.objectID) == [2, 3])
        #expect(decoded.alternatives.map(\.path) == [URL(string: "/3D/a.model"), URL(string: "/3D/b.model")])
    }
}
