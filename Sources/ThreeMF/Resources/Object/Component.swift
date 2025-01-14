import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// component
public struct Component {
    public var objectID: ResourceID
    public var transform: Matrix3D?

    public init(objectID: ResourceID, transform: Matrix3D? = nil) {
        self.objectID = objectID
        self.transform = transform
    }
}

extension Component: XMLElementComposable {
    static let elementIdentifier = Core.component
    
    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            Core.objectID: objectID,
            Core.transform: transform
        ]
    }

    init(xmlElement: XMLElement) throws(Error) {
        objectID = try xmlElement[Core.objectID]
        transform = try? xmlElement[Core.transform]
    }
}
