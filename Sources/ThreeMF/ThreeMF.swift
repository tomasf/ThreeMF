import Foundation
import Nodal

/// Identifies a resource within a model file.
///
/// Resource IDs are unique among the resources of a single model, and are what an ``Item`` or
/// ``Component`` refers to. Use ``ResourceContainer/resource(for:)`` to look one up.
public typealias ResourceID = Int

/// A zero-based index into a group resource, such as one of the colors in a ``ColorGroup``.
public typealias ResourceIndex = Int

/// A list of indices into a group resource, one per triangle vertex where properties vary across
/// a triangle.
public typealias ResourceIndices = [ResourceIndex]

/// An error encountered while reading or writing a 3MF package.
public enum ThreeMFError: Error {
    /// A file inside the package couldn't be read, either because it isn't there or because reading
    /// it failed. `error` carries the underlying failure when there was one.
    case failedToReadArchiveFile (name: String, error: Swift.Error?)

    /// The package's relationships part is missing, unparseable, or doesn't name a root model.
    case malformedRelationships ((any Swift.Error)?)

    /// A model name can't be turned into a usable path inside the package.
    case invalidModelName (String)

    /// An element the spec requires wasn't present.
    case missingElement (name: ExpandedName)

    /// An attribute the spec requires wasn't present.
    case missingAttribute (name: ExpandedName)

    /// An ``Object`` has neither a mesh nor components, one of which it must have.
    case missingObjectContent

    /// An attribute's value couldn't be parsed as the type it should hold.
    case malformedAttribute (name: String)

    /// A transform attribute isn't twelve space-separated numbers.
    case malformedTransform (String)

    /// A color attribute isn't `#RRGGBB` or `#RRGGBBAA`.
    case malformedColorString (String)

    /// An attribute that should hold an integer doesn't.
    case malformedInteger (String)

    /// An attribute's value isn't one the spec allows for it.
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
