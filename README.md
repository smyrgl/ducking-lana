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

There is a single script that will take care of any depedencies that can be run from the project root using ``.

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
The requirements were clearly written around configuring and setting up CoreLocation but looking at the broader picture it was clear that such an application would be a pretty significant battery drain.  As such it makes sense to consider having two possible datasources for the start/end trip events: one based on pure CoreLocation APIs and one based on using CoreMotion on supported devices as the CoreMotion activities do a very good job of giving you the same indications with far less battery consumption (supposedly anyway, I did not have time for doing A/B tests).  

As such there is an optional codepath that uses CoreMotion and the TripManager will check the device capabilities at runtime and choose the best path that the device supports.  These sources are connected through a protocol to make the TripManager insensitive to the code path chosen, although the start/end triggers will be different.

I bring this up because the functional requirements mention specific triggers for what constitutes a start and end trip event which the CoreLocation path uses but the CoreMotion path does not.  The intent is the same and the CoreMotion path can be disabled from a configuration in the plist that I provided but I thought it was an important option to include. 

### Alerts/Errors
Because I wanted the view controller to manage the error display directly I went with a pattern that involved sending back NSError objects which would then be translated into UIAlertViews by the view controller itself.  The only complexity here was that location permissions errors need very specific error messaging with alerts that link into settings pages so I mapped them using an extension on UIAlertView and matching of error codes.

### Trip resuming
Although not mentioned in the functional requirements, because of the possibility of app termination I wanted to keep in-progress trips from being lost during app termination.  The method I used (saving the in progress start to the NSUserDefaults) has some edge cases and I would come up with a more robust implementation with more time but for now I stuck with something simple that prevents trips from being dropped on the floor.

### Notifications
There was nothing in the requirements about firing local notifications when a trip would start/end but it seems like a logical thing to include.  I didn't because I didn't want to overcomplexify things and add permissions that weren't necessary but I did consider it.

Testing
-------
Because of the time constraints and the involved nature of doing tests for location I did not provide unit tests but I thought I would lay out the testing methodology I would use if I had the time to implement them.

### Source testing
Because of the coupling of the TripManager to its location stores through a protocol, it would be very easy to isolate it for testing by providing a fake test source.  This fake source would generate fake test data instantly (rather than relying on the platform APIs) and since the trip report information is entirely handled by the source the TripManager would not know the difference.  Then some conditions could be simulated which are difficult to reproduce with actual CoreLocation and CoreMotion APIs.

### Model testing
This would be pretty straightforward, but since so little validation is done currently it would really just be tests of the formatted display strings that are currently computed properties on the Trip model.

### View testing
Unnecessary in my opinion with such a simple app and I don't really see much value in view testing in the work I've done.  