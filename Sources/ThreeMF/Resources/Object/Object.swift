import Foundation
import Nodal

// object
/// A shape the model defines, either as a mesh or as an assembly of other objects.
///
/// An object is only output if a build item places it, directly or through another object's
/// components. Its ``content`` holds the geometry; the property attributes say what it's made of.
public struct Object: Resource {
    static public let elementName: ExpandedName = Core.object

    public var id: ResourceID

    /// What the object is for: part of the output, support, or something else.
    ///
    /// `nil` means the file doesn't say, which per the spec means ``ObjectType/model``.
    public var type: ObjectType?

    /// A part inside the package holding a thumbnail image of this object.
    public var thumbnail: URL?

    /// An identifier for the part this object represents, for consumers that track parts.
    public var partNumber: String?

    /// A human-readable name for the object.
    public var name: String?

    /// A stable identifier for this object, from the production extension.
    ///
    /// When the model requires that extension, the writer assigns one if you don't.
    public var uuid: UUID?

    /// How exact this object's geometry is, from the alternatives extension.
    ///
    /// Lets a file offer a low-resolution or obfuscated stand-in alongside the real geometry.
    public var modelResolution: ModelResolution?

    /// Other representations of this same object, from the alternatives extension.
    public var alternatives: [Alternative]

    /// The property group this object's material comes from, such as a ``ColorGroup`` or
    /// ``BaseMaterialGroup``.
    ///
    /// Applies to the whole object, and is what triangles fall back on when they don't name properties
    /// of their own.
    public var propertyGroupID: ResourceID?

    /// Which entry of ``propertyGroupID`` to use.
    public var propertyIndex: ResourceIndex?

    /// Metadata about this object.
    public var metadata: [Metadata]

    /// The object's geometry: either a mesh or a set of components.
    public var content: Content

    /// Creates an object.
    /// - Parameters:
    ///   - id: The object's id, unique within its model file.
    ///   - type: What the object is for. `nil` means part of the output.
    ///   - thumbnail: A package part holding a thumbnail image.
    ///   - partNumber: An identifier for the part this represents.
    ///   - name: A human-readable name.
    ///   - uuid: A stable identifier, for the production extension.
    ///   - modelResolution: How exact the geometry is, for the alternatives extension.
    ///   - alternatives: Other representations of this object.
    ///   - propertyGroupID: The property group the object's material comes from.
    ///   - propertyIndex: Which entry of that group to use.
    ///   - metadata: Metadata about the object.
    ///   - content: The object's geometry.
    public init(
        id: ResourceID,
        type: ObjectType? = nil,
        thumbnail: URL? = nil,
        partNumber: String? = nil,
        name: String? = nil,
        uuid: UUID? = nil,
        modelResolution: ModelResolution? = nil,
        alternatives: [Alternative] = [],
        propertyGroupID: ResourceID? = nil,
        propertyIndex: ResourceIndex? = nil,
        metadata: [Metadata] = [],
        content: Content
    ) {
        self.id = id
        self.type = type
        self.thumbnail = thumbnail
        self.partNumber = partNumber
        self.name = name
        self.uuid = uuid

        self.modelResolution = modelResolution
        self.alternatives = alternatives

        self.propertyGroupID = propertyGroupID
        self.propertyIndex = propertyIndex

        self.metadata = metadata
        self.content = content
    }
}

extension Object: XMLElementCodable {
    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.setValue(type, forAttribute: .type)
        element.setValue(thumbnail, forAttribute: .thumbnail)
        element.setValue(partNumber, forAttribute: .partNumber)
        element.setValue(name, forAttribute: .name)
        element.setValue(uuid ?? .uuidIfProduction, forAttribute: Production.UUID)

        element.setValue(modelResolution, forAttribute: Alternatives.modelResolution)
        element.encode(alternatives, elementName: Alternatives.alternative, containedIn: Alternatives.alternatives)

        element.setValue(propertyGroupID, forAttribute: .pid)
        element.setValue(propertyIndex, forAttribute: .pIndex)
        element.encode(metadata, elementName: Core.metadata)

        let contentElement = element.addElement("")
        content.encode(to: contentElement)
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        type = try element.value(forAttribute: .type)
        thumbnail = try element.value(forAttribute: .thumbnail)
        partNumber = try element.value(forAttribute: .partNumber)
        name = try element.value(forAttribute: .name)
        uuid = try element.value(forAttribute: Production.UUID)

        modelResolution = try element.value(forAttribute: Alternatives.modelResolution)
        alternatives = try element.decode(elementName: Alternatives.alternative, containedIn: Alternatives.alternatives)

        propertyGroupID = try element.value(forAttribute: .pid)
        propertyIndex = try element.value(forAttribute: .pIndex)
        metadata = try element.decode(elementName: Core.metadata)

        guard let contentElement = element[element: Core.mesh] ?? element[element: Core.components] else {
            throw XMLElementCodableError.expandedElementMissing(Core.mesh)
        }
        content = try .init(from: contentElement)
    }
}

/// An object's geometry and kind.
public extension Object {
    /// What an object is made of: geometry of its own, or other objects arranged together.
    enum Content: Sendable {
        /// Triangle geometry.
        case mesh (Mesh)

        /// Other objects, each placed by its own transform.
        case components ([Component])
    }

    /// What an object is for.
    enum ObjectType: String, Sendable, XMLValueCodable {
        /// Part of the model's output. The default when a file doesn't say.
        case model

        /// Support material, given as solid geometry.
        case solidSupport = "solidsupport"

        /// Support that isn't described as solid geometry.
        case support

        /// A surface rather than a solid volume.
        case surface

        /// Something else; a consumer shouldn't treat it as part of the output.
        case other

        /// The type an object has when the file doesn't say: ``ObjectType/model``.
        static let `default` = Self.model
    }
}

extension Object.Content: XMLElementCodable {
    public func encode(to element: Node) {
        switch self {
        case .mesh (let mesh):
            element.expandedName = Core.mesh
            mesh.encode(to: element)

        case .components (let components):
            element.expandedName = Core.components
            element.encode(components, elementName: Core.component)
        }
    }

    public init(from element: Node) throws {
        if element.expandedName == Core.mesh {
            self = .mesh(try Mesh(from: element))
        } else {
            self = .components(try element.decode(elementName: Core.component))
        }
    }
}
