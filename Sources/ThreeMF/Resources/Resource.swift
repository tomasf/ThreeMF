import Foundation
import Nodal

public protocol Resource {
    var id: ResourceID { get set }
}

public struct PropertyReference: Hashable {
    public let groupID: ResourceID
    public let index: ResourceIndex

    public init(groupID: ResourceID, index: ResourceIndex) {
        self.groupID = groupID
        self.index = index
    }
}

internal typealias ResourceInternal = (Resource & XMLElementComposable)

internal let allResourceTypes: [any ResourceInternal.Type] = [
    Object.self, ColorGroup.self, BaseMaterialGroup.self,
    Multiproperties.self, Texture2D.self, Texture2DGroup.self,
    CompositeMaterialGroup.self, TranslucentDisplayProperties.self,
    MetallicDisplayProperties.self, SpecularDisplayProperties.self,
    SpecularTextureDisplayProperties.self, MetallicTextureDisplayProperties.self,
]

internal let resourceTypePerElementIdentifier: [ElementIdentifier: any ResourceInternal.Type] = {
    Dictionary(uniqueKeysWithValues: allResourceTypes.map { ($0.elementIdentifier, $0) })
}()
