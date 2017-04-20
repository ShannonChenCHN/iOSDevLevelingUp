Reading *[View Programming Guide for iOS](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40009503)*
-----------


## Content
- [Introduction](#introduction)

- [View and Window Achitecture](#view-and-window-achitecture)

- [Windows](#windows)

- [Views](#views)

- [Animations](#animations)

### Introduction(About Windows and Views)

- At a Glance
	- Views Manage Your Application’s Visual Content
	- Windows Coordinate the Display of Your Views
	- Animations Provide the User with Visible Feedback for Interface Changes
	- The Role of Interface Builder
	
### View and Window Achitecture

- View Architecture Fundamentals
	- View Hierarchies and Subview Management
	- The View Drawing Cycle
	- Content Modes
	- Stretchable Views
	- Built-In Animation Support
- View Geometry and Coordinate Systems
	- The Relationship of the Frame, Bounds, and Center Properties
	- Coordinate System Transformations
	- Points Versus Pixels
- The Runtime Interaction Model for Views
	- Tips for Using Views Effectively
	- Views Do Not Always Have a Corresponding View Controller
	- Minimize Custom Drawing
	- Take Advantage of Content Modes
	- Declare Views as Opaque Whenever Possible
	- Adjust Your View’s Drawing Behavior When Scrolling
	- Do Not Customize Controls by Embedding Subviews

### Windows

- Tasks That Involve Windows
- Creating and Configuring a Window
	- Creating Windows in Interface Builder
	- Creating a Window Programmatically
	- Adding Content to Your Window
	- Changing the Window Level
- Monitoring Window Changes
- Displaying Content on an External Display
	- Handling Screen Connection and Disconnection Notifications
	- Configuring a Window for an External Display
	- Configuring the Screen Mode of an External Display

### Views

- Responsibilities
- Creating and Configuring View Objects
	- Creating View Objects Using Interface Builder
	- Creating View Objects Programmatically
	- Setting the Properties of a View
	- Tagging Views for Future Identification
- Creating and Managing a View Hierarchy
	- Adding and Removing Subviews
	- Hiding Views
	- Locating Views in a View Hierarchy
	- Translating, Scaling, and Rotating Views
	- Converting Coordinates in the View Hierarchy
- Adjusting the Size and Position of Views at Runtime
	- Being Prepared for Layout Changes
	- Handling Layout Changes Automatically Using Autoresizing Rules
	- Tweaking the Layout of Your Views Manually
- Modifying Views at Runtime
- Interacting with Core Animation Layers
	- Changing the Layer Class Associated with a View
	- Embedding Layer Objects in a View
- Defining a Custom View
	- Checklist for Implementing a Custom View
	- Initializing Your Custom View
	- Implementing Your Drawing Code
	- Responding to Events
	- Cleaning Up After Your View

### Animations

- What Can Be Animated?
- Animating Property Changes in a View
	- Starting Animations Using the Block-Based Methods(for iOS 4 or later)
	- Starting Animations Using the Begin/Commit Methods(for iOS 3.2 and earlier)
		- Configuring the Parameters for Begin/Commit Animations
		- Configuring an Animation Delegate
	- Nesting Animation Blocks
	- Implementing Animations That Reverse Themselves
- Creating Animated Transitions Between Views
	- When to use
	- Changing the Subviews of a View
	- Replacing a View with a Different View
- Linking Multiple Animations Together
- Animating View and Layer Changes Together

### See Also
	- [View Controller Programming Guide for iOS](https://developer.apple.com/library/content/featuredarticles/ViewControllerPGforiPhoneOS/index.html#//apple_ref/doc/uid/TP40007457)
	- [Event Handling Guide for UIKit Apps](https://developer.apple.com/library/content/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/index.html#//apple_ref/doc/uid/TP40009541)
	- [Drawing and Printing Guide for iOS](https://developer.apple.com/library/content/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010156)
	- [Core Animation Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40004514)