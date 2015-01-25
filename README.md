Code Challenge
==============

Intro
-----
This is the submission of John Tumminaro (aka me) for the code challenge I was presented.  There are some notes in this readme that describe the overall approach I used to meet the functional requirements as well as some gotchas I ran into.

This application is coded in Swift but the techniques are not very different from what I would use in Objective-C.

Getting Started
---------------
The application has a number of depedencies that will need to be installed before it can be run:

- Homebrew
- Bundler
- Cocoapods (0.36.0.beta.1 or later)
- Mogenerator

Third-party code
----------------
Because of the nature of the challenge I wanted to reduce the amount of third-party code to a minimum, however I did add a couple of depedencies that are unrelated to the core challenge.  

### MagicalRecord
I made use of MagicalRecord just to keep the boilerplate Core Data setup code down and to avoid cluttering the table view controller with a bunch of unnecessary NSFetchedResultsController code.

### Mogenerator
Not a third party lib per say (in that it doesn't link anything into the app) but this runtime tool is used for producing the concrete Core Data model files for this excercise.

### Cocoapods
Used to link the depedency of MagicalRecord so I didn't need to use a git submodule. 

Methodology
-----------
### Core Motion source
The requirements were clearly written around configuring and setting up CoreLocation but looking at the broader picture it was clear that such an application would be a pretty significant battery drain.  As such it makes sense to consider having two possible datasources for the start/end trip events: one based on pure CoreLocation APIs and one based on using CoreMotion on supported devices as the CoreMotion activities do a very good job of giving you the same indications with far less battery consumption.

Unfortunately, as I was experimenting with this path I found that CoreMotion activity changes are not delivered when the app is suspended.  This could have still worked since you can get timestamps of the transition between different CoreMotion activities but unfortunately the activity changes do not include any location data so it will not work for this purpose.  I considered ripping it out but instead I just disabled it and left it in so that you could better understand the thought process that went into it.

### Alerts/Errors
Because I wanted the view controller to manage the error display directly I went with a pattern that involved sending back NSError objects which would then be translated into UIAlertViews by the view controller itself.  The only complexity here was that location permissions errors need very specific error messaging with alerts that link into settings pages so I mapped them using an extension on UIAlertView and matching of error codes.

### Trip resuming
Although not mentioned in the functional requirements, because of the possibility of app termination I wanted to keep in-progress trips from being lost during app termination.  The method I used (saving the in progress start to the NSUserDefaults) has some edge cases and I would come up with a more robust implementation with more time but for now I stuck with something simple that prevents trips from being dropped on the floor.

### Notifications
There was nothing in the requirements about firing local notifications when a trip would start/end but it seems like a logical thing to include.  I didn't because I didn't want to overcomplexify things and add permissions that weren't necessary but I did consider it.

### In progress trips
Although there is accomodation in the models for displaying in progress trips, I decided against displaying them as it might be confusing.  In addition, I wanted to create a seperation between the sources and the TripManager and not create the Trip objects until the trip was complete, but this is easy enough to refactor should it be considered.  I'm only mentioning this because I did include code in the display strings to accomodate it and I didn't want that to be confusing.

Testing
-------
Because of the time constraints and the involved nature of doing tests for location I did not provide unit tests but I thought I would lay out the testing methodology I would use if I had the time to implement them.

### Source testing
Because of the coupling of the TripManager to its location stores through a protocol, it would be very easy to isolate it for testing by providing a fake test source.  This fake source would generate fake test data instantly (rather than relying on the platform APIs) and since the trip report information is entirely handled by the source the TripManager would not know the difference.  Then some conditions could be simulated which are difficult to reproduce with actual CoreLocation and CoreMotion APIs.

### Model testing
This would be pretty straightforward, but since so little validation is done currently it would really just be tests of the formatted display strings that are currently computed properties on the Trip model.

### View testing
Unnecessary in my opinion with such a simple app and I don't really see much value in view testing in the work I've done.  

Other Notes
-----------
### Geocoding
Because the geocoders return async and I don't want the context to save until they are complete, I used a dispatch_semaphore to ensure concurrency (the managing thread is off the main thread).  This may not be the most elegant approach but it has no inherent harm and it is efficient, I just might have considered wrapping it up a little differently if it was production code.  

### Logging
I'm just using println statements, if this were production code I would have used CocoaLumberjack or similar to prevent logging to the console and enable async logging but it seemed overkill since I was trying to limit 3rd party depedencies.

### Formatter caching
Because the display strings can theoretically be generated from threads other than main (they are core data objects after all) I cached the expensive formatter objects.  Most commonly people prefer doing this in a singleton but to prevent concurrency demands I cache them and lazily create them in the thread dictionary.  This might be a pattern that isn't commonly seen but in my experience it is much less of a headache than the alternatives and it does solve for cases where you might be doing background processing on a number of threads.