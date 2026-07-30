import Testing
import Nodal
@testable import ThreeMF

struct UnitTests {
    @Test(arguments: [
        (Unit.micron, 0.001),
        (.millimeter, 1),
        (.centimeter, 10),
        (.inch, 25.4),
        (.foot, 304.8),
        (.meter, 1000),
    ])
    func `millimetersPerUnit matches the expected conversion factor`(unit: Unit, expected: Double) {
        #expect(unit.millimetersPerUnit == expected)
    }

    @Test func `default unit is millimeter`() {
        #expect(Unit.default == .millimeter)
    }

    @Test(arguments: [Unit.micron, .millimeter, .centimeter, .inch, .foot, .meter])
    func `every case round trips`(unit: Unit) throws {
        #expect(try roundTrip(unit) == unit)
    }

    @Test func `unrecognized string throws invalidFormat`() {
        #expect(throws: XMLValueError.self) {
            try decodeAttribute(Unit.self, from: "parsec")
        }
    }
}
