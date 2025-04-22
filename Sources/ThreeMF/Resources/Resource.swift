import Foundation
import Nodal

public protocol Resource: Sendable, XMLElementCodable {
    var id: ResourceID { get set }
    static var elementName: ExpandedName { get }
}

public struct PropertyReference: Hashable, Sendable {
    public let groupID: ResourceID
    public let index: ResourceIndex

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
