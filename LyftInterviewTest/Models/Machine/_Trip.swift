// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Trip.swift instead.

import CoreData

enum TripAttributes: String {
    case endTime = "endTime"
    case startTime = "startTime"
}

enum TripRelationships: String {
    case end = "end"
    case start = "start"
}

@objc
class _Trip: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Trip"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Trip.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var endTime: NSDate?

    // func validateEndTime(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var startTime: NSDate?

    // func validateStartTime(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var end: Place?

    // func validateEnd(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var start: Place?

    // func validateStart(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

