import Foundation
import Nodal

/// Something a model defines and can refer to by id: an object, a material group, a texture.
///
/// Resources live in ``Model/resources``. A ``Item`` or ``Component`` refers to an object by its
/// ``id``, and property groups are referred to the same way.
public protocol Resource: Sendable, XMLElementCodable {
    /// This resource's id, unique among the resources of its model file.
    ///
    /// ``ResourceContainer/add(resource:)`` assigns one for you.
    var id: ResourceID { get set }

    /// The XML element this resource is written as.
    static var elementName: ExpandedName { get }
}

/// A reference to one entry of a property group: which group, and which entry within it.
///
/// Multiproperties uses these to combine, say, a color from one group with a material from another.
public struct PropertyReference: Hashable, Sendable {
    /// The id of the group being referred to.
    public let groupID: ResourceID

    /// The index of the entry within that group.
    public let index: ResourceIndex

    /// Creates a reference to one entry of a property group.
    /// - Parameters:
    ///   - groupID: The id of the group.
    ///   - index: The index of the entry within it.
    public init(groupID: ResourceID, index: ResourceIndex) {
        self.groupID = groupID
        self.index = index
    }
}

internal typealias ResourceInternal = (Resource & XMLElementCodable)

internal let allResourceTypes: [any ResourceInternal.Type] = [
    Object.self, ColorGroup.self, BaseMaterialGroup.self,
    Multiproperties.self, Texture2D.self, Texture2DGroup.self,
    CompositeMaterialGroup.self, TranslucentDisplayProperties.self,
    MetallicDisplayProperties.self, SpecularDisplayProperties.self,
    SpecularTextureDisplayProperties.self, MetallicTextureDisplayProperties.self,
]

internal let resourceTypePerElementIdentifier: [ExpandedName: any ResourceInternal.Type] = {
    Dictionary(uniqueKeysWithValues: allResourceTypes.map { ($0.elementName, $0) })
}()
