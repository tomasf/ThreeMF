import Foundation
import Nodal

public typealias ResourceID = Int
public typealias ResourceIndex = Int
public typealias ResourceIndices = [ResourceIndex]

public enum Error: Swift.Error {
    case failedToReadArchiveFile (name: String, error: Swift.Error?)
    case malformedRelationships ((any Swift.Error)?)

    case missingElement (name: ExpandedName)
    case missingAttribute (name: ExpandedName)
    case missingObjectContent

    case malformedAttribute (name: String)
    case malformedTransform (String)
    case malformedColorString (String)
    case malformedInteger (String)

    case malformedAttributeValue (String)
}

enum MimeType: String {
    case model = "application/vnd.ms-package.3dmanufacturing-3dmodel+xml"
    case relationships = "application/vnd.openxmlformats-package.relationships+xml"
    case modelTexture = "application/vnd.ms-package.3dmanufacturing-3dmodeltexture"
}

enum RelationshipType: String {
    case model = "http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"
    case thumbnail = "http://schemas.openxmlformats.org/package/2006/relationships/metadata/thumbnail"
    case printTicket = "http://schemas.microsoft.com/3dmanufacturing/2013/01/printticket"
    case mustPreserve = "http://schemas.openxmlformats.org/package/2006/relationships/mustpreserve"
    case texture = "http://schemas.microsoft.com/3dmanufacturing/2013/01/3dtexture"
}
