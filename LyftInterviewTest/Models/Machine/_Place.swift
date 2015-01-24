// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Place.swift instead.

import CoreData

enum PlaceAttributes: String {
    case displayName = "displayName"
    case latitude = "latitude"
    case longitude = "longitude"
}

enum PlaceRelationships: String {
    case endTrip = "endTrip"
    case startTrip = "startTrip"
}

@objc
class _Place: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Place"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Place.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var displayName: String?

    // func validateDisplayName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var latitude: NSNumber?

    // func validateLatitude(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var longitude: NSNumber?

    // func validateLongitude(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var endTrip: Trip?

    // func validateEndTrip(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var startTrip: Trip?

    // func validateStartTrip(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

