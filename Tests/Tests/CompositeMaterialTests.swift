import Testing
@testable import ThreeMF

struct CompositeMaterialTests {
    // Distinct values in every position, so a row/column transposition would be caught.
    @Test func `composite material group round trips with row and column order preserved`() throws {
        let group = CompositeMaterialGroup(
            id: 1,
            baseMaterialGroupID: 2,
            baseMaterialIndices: [10, 20, 30],
            displayPropertiesID: 7,
            composites: [
                [0.1, 0.2, 0.7],
                [0.4, 0.5, 0.1],
            ]
        )
        let decoded = try roundTrip(group)
        #expect(decoded.id == 1)
        #expect(decoded.baseMaterialGroupID == 2)
        #expect(decoded.baseMaterialIndices == [10, 20, 30])
        #expect(decoded.displayPropertiesID == 7)
        #expect(decoded.composites == group.composites)
    }
}
