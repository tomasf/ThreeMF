@testable import ThreeMF

// Small builders to keep ModelLoaderTests/ObjectTests readable. Expand ad hoc as needed
// rather than anticipating every shape up front.

func triangleMesh(vertexOffset: Double = 0) -> Mesh {
    Mesh(
        vertices: [
            .init(x: 0 + vertexOffset, y: 0, z: 0),
            .init(x: 1 + vertexOffset, y: 0, z: 0),
            .init(x: 0 + vertexOffset, y: 1, z: 0),
        ],
        triangles: [.init(v1: 0, v2: 1, v3: 2, propertyIndex: nil)]
    )
}

func meshObject(
    id: ResourceID,
    mesh: Mesh = triangleMesh(),
    name: String? = nil,
    partNumber: String? = nil,
    pid: ResourceID? = nil,
    pIndex: ResourceIndex? = nil
) -> Object {
    Object(id: id, partNumber: partNumber, name: name, propertyGroupID: pid, propertyIndex: pIndex, content: .mesh(mesh))
}

func componentsObject(id: ResourceID, name: String? = nil, _ components: [Component]) -> Object {
    Object(id: id, name: name, content: .components(components))
}
