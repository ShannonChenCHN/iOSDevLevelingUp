Reading *[View Programming Guide for iOS](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40009503)*
-----------


## Content
- [Introduction](#introduction)

- [View and Window Achitecture](#view-and-window-achitecture)

- [Windows](#windows)

- [Views](#views)

- [Animations](#animations)

### Introduction(About Windows and Views)

- Introduction
	- What is windows and views used for: 
		- present your application’s content on the screen.
	- Windows: 
		- do not have any visible content themselves but provide a basic container for your application’s views.
	- Views:
		- define a portion of a window that you want to fill with some content.
		- organize and manage other views.
	- Every application has at least one window and one view for presenting its content.

- At a Glance
	- Views Manage Your Application’s Visual Content
		- What is view: an instance of the [UIView](https://developer.apple.com/reference/uikit/uiview) class (or one of its subclasses) and manages a rectangular area in your application window. 
		- Responsiblity
			- drawing content: using graphics technologies such as `Core Graphics`, `OpenGL ES`, or `UIKit` to draw shapes, images, and text inside a view’s rectangular area.
			- handling multitouch events: a view responds to touch events in its rectangular area either by *using gesture recognizers* or by handling *touch events* directly.
			- managing the layout of any subviews: parent views are responsible for positioning and sizing their child views.
	> Relevant Chapters: [View and Window Architecture](#view-and-window-achitecture), [Views](#views)
		
	- Windows Coordinate the Display of Your Views
		- What is window: an instance of the [UIWindow](https://developer.apple.com/reference/uikit/uiwindow) class and handles the **overall** presentation of your application’s user interface.
		- Responsiblity
			- Windows work with views (and their owning view controllers) to manage interactions with, and changes to, the visible view hierarchy. 
				-  After the window is created, it stays the same and only the views displayed by it change.
				- Every application has **at least one** window that displays the application’s user interface on a device’s **main screen**.
			- External display
	> Relevant Chapters: [Windows](#windows)
	
	- Animations Provide the User with Visible Feedback for Interface Changes
		- What is animation: animations provide users with visible feedback about changes to your view hierarchy.  
		- Approach
			- Standard animations: The system defines standard animations for presenting modal views and transitioning between different groups of views.
			- Animate view's attributes directly.
			- Work directly with the view’s underlying Core Animation `layer` object.
	> Relevant Chapters: [Animations](#animations)
	
	- The Role of Interface Builder
		- What is Interface Builder: an application that you use to graphically construct and configure your application’s windows and views.
		- How to use: assemble your views and place them in a nib file.
			- What is nib file: a resource file that stores a freeze-dried version of your views and other objects.
			- [Interface Builder User Guide]()
		- How does Interface Builder works: When you load a nib file at runtime, the objects inside it are reconstituted into actual objects that your code can then manipulate programmatically.
		- How view controllers manage the nib files containing their views: see Creating Custom Content View Controllers in *[View Controller Programming Guide for iOS](https://developer.apple.com/library/content/featuredarticles/ViewControllerPGforiPhoneOS/index.html#//apple_ref/doc/uid/TP40007457)*.
		- Benifits: Interface Builder greatly simplifies the work you have to do in creating your application’s user interface.
	> Relevant Resources: [WWDC-Interface Builder Core Concepts](https://developer.apple.com/videos/play/wwdc2013/405/), [WWDC-What's New in Auto Layout](https://developer.apple.com/videos/play/wwdc2016/236/), [What's New in Storyboards](https://developer.apple.com/videos/play/wwdc2015/215/)
	
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