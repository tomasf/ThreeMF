import Testing
import Foundation
import Nodal
@testable import ThreeMF

struct BuildAndItemTests {
    @Test func `build round trips with multiple items and a uuid`() throws {
        let uuid = UUID()
        let build = Build(items: [Item(objectID: 1), Item(objectID: 2)], uuid: uuid)
        let decoded = try roundTrip(build)
        #expect(decoded.items.map(\.objectID) == [1, 2])
        #expect(decoded.uuid == uuid)
    }

    @Test func `item round trips with every field populated`() throws {
        let foreignAttribute = ExpandedName(namespaceName: "http://example.com/x", localName: "custom")
        let item = Item(
            objectID: 5,
            transform: Matrix3D(values: [[1, 0, 0], [0, 1, 0], [0, 0, 1], [1, 2, 3]]),
            partNumber: "PN-9",
            metadata: [Metadata(name: .title, value: "Item title")],
            customAttributes: [foreignAttribute: "value"],
            path: URL(string: "/3D/other.model"),
            uuid: UUID()
        )
        let decoded = try roundTripAsChild(item)
        #expect(decoded.objectID == 5)
        #expect(decoded.transform?.values == item.transform?.values)
        #expect(decoded.partNumber == "PN-9")
        #expect(decoded.metadata.map(\.value) == ["Item title"])
        #expect(decoded.customAttributes == [foreignAttribute: "value"])
        #expect(decoded.path == item.path)
        #expect(decoded.uuid == item.uuid)
    }

    // The "known attributes" exclusion set in Item.init(from:) only excludes the exact expanded
    // names it knows about. A same-named attribute in a different (foreign) namespace shouldn't
    // get swallowed by that exclusion.
    @Test func `custom attributes are not swallowed by a same-named known attribute`() throws {
        let foreignObjectID = ExpandedName(namespaceName: "http://example.com/x", localName: "objectid")
        let item = Item(objectID: 5, customAttributes: [foreignObjectID: "not the real objectID"])
        let decoded = try roundTripAsChild(item)
        #expect(decoded.objectID == 5)
        #expect(decoded.customAttributes == [foreignObjectID: "not the real objectID"])
    }

    @Test func `item with all optional fields nil round trips with no spurious attributes`() throws {
        let item = Item(objectID: 7)
        let decoded = try roundTripAsChild(item)
        #expect(decoded.objectID == 7)
        #expect(decoded.transform == nil)
        #expect(decoded.partNumber == nil)
        #expect(decoded.metadata.isEmpty)
        #expect(decoded.customAttributes.isEmpty)
        #expect(decoded.path == nil)
        #expect(decoded.uuid == nil)
    }
}
