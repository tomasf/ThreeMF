import Testing
@testable import ThreeMF

struct MultipropertiesTests {
    @Test func `multiproperties round trips`() throws {
        let multiproperties = Multiproperties(
            id: 1,
            propertyGroupIDs: [10, 20, 30],
            blendMethods: [.multiply, .mix],
            multis: [[1, 2, 3], [4, 5, 6]]
        )
        let decoded = try roundTrip(multiproperties)
        #expect(decoded.id == 1)
        #expect(decoded.propertyGroupIDs == [10, 20, 30])
        #expect(decoded.blendMethods == [.multiply, .mix])
        #expect(decoded.multis == [[1, 2, 3], [4, 5, 6]])
    }

    @Test func `multiproperties without blendMethods round trips to nil`() throws {
        let multiproperties = Multiproperties(id: 1, propertyGroupIDs: [10], blendMethods: nil, multis: [[1]])
        let decoded = try roundTrip(multiproperties)
        #expect(decoded.blendMethods == nil)
    }

    @Test func `layerSequences fills missing multi entries with index 0`() {
        let multiproperties = Multiproperties(id: 1, propertyGroupIDs: [10, 20], blendMethods: nil, multis: [[7]])
        let sequences = multiproperties.layerSequences
        #expect(sequences.count == 1)
        #expect(sequences[0].map(\.property.groupID) == [10, 20])
        #expect(sequences[0].map(\.property.index) == [7, 0])
    }

    @Test func `layerSequences always uses mix for the first layer regardless of blendMethods`() {
        let multiproperties = Multiproperties(id: 1, propertyGroupIDs: [10, 20], blendMethods: [.multiply, .multiply], multis: [[1, 2]])
        let sequences = multiproperties.layerSequences
        #expect(sequences[0][0].blendMethod == .mix)
        #expect(sequences[0][1].blendMethod == .multiply)
    }

    @Test func `layerSequences falls back to mix when blendMethods is shorter than needed`() {
        let multiproperties = Multiproperties(id: 1, propertyGroupIDs: [10, 20, 30], blendMethods: [.multiply], multis: [[1, 2, 3]])
        let sequences = multiproperties.layerSequences
        #expect(sequences[0].map(\.blendMethod) == [.mix, .multiply, .mix])
    }

    @Test func `layerSequences uses mix for every layer when blendMethods is nil`() {
        let multiproperties = Multiproperties(id: 1, propertyGroupIDs: [10, 20, 30], blendMethods: nil, multis: [[1, 2, 3]])
        let sequences = multiproperties.layerSequences
        #expect(sequences[0].allSatisfy { $0.blendMethod == .mix })
    }
}
