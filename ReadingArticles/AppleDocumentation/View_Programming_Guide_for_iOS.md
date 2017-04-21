Reading *[View Programming Guide for iOS](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40009503)*
-----------


## Content
- [Introduction](#introduction)
	- Overview
	- At a Glance
- [View and Window Achitecture](#view-and-window-achitecture)
	- View Architecture Fundamentals
	- View Geometry and Coordinate Systems
	- The Runtime Interaction Model for Views
- [Windows](#windows)
	- Tasks That Involve Windows
	- Creating and Configuring a Window
	- Monitoring Window Changes
	- Displaying Content on an External Display
- [Views](#views)
	- Responsibilities
	- Creating and Configuring View Objects
	- Creating and Managing a View Hierarchy
	- Adjusting the Size and Position of Views at Runtime
	- Modifying Views at Runtime
	- Interacting with Core Animation Layers
	- Defining a Custom View
- [Animations](#animations)
	- What Can Be Animated?
	- Animating Property Changes in a View
	- Creating Animated Transitions Between Views
	- Linking Multiple Animations Together
	- Animating View and Layer Changes Together

### Introduction(About Windows and Views)

- Overview
	- What is windows and views used for: 
		- present your application’s content on the screen.
		- handle the interactions with your application’s user interface.
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
			- Core Animation: In places where the standard view animations are not sufficient, you can work directly with the view’s underlying Core Animation `layer` object.
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

- Inroduction
	- Understand the infrastructure provided by the [UIView](https://developer.apple.com/reference/uikit/uiview) and [UIWindow](https://developer.apple.com/reference/uikit/uiwindow) classes.
	- Understand those facilities provided by the [UIView](https://developer.apple.com/reference/uikit/uiview) and [UIWindow](https://developer.apple.com/reference/uikit/uiwindow) classes for managing the layout and presentation of views.

- View Architecture Fundamentals
	- Introduction
		- General feature
			- A view object defines a rectangular region on the screen and handles the drawing and touch events in that region.
			- A view can also act as a parent for other views and coordinate the placement and sizing of those views.
		- Core Animation layers
			- Views work in conjunction with Core Animation layers to handle the rendering and animating of a view’s content.
			- Every view in UIKit is backed by a layer object (usually an instance of the `CALayer` class), which manages the backing store for the view and handles view-related animations.Behind those layer objects are Core Animation rendering objects and ultimately the hardware buffers used to manage the actual bits on the screen.
			- in situations where you need more control over the rendering or animation behavior of your view, you can perform operations through its layer instead.
		- The use of Core Animation layer objects has important implications for performance. (?????)
			- The actual drawing code of a view object is called as little as possible
			- when the code is called, the results are cached by Core Animation and reused as much as possible later. 
			- Reusing already-rendered content eliminates the expensive drawing cycle usually needed to update views. 

	**Figure 1-1**  Architecture of the views in a sample application([example](https://developer.apple.com/library/content/samplecode/ViewTransitions/Introduction/Intro.html#//apple_ref/doc/uid/DTS40007411))
	
	![](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/Art/view-layer-store.jpg)

	- View Hierarchies and Subview Management
		- a view can act as a container for other views.
		- Visually, the content of a subview obscures all or part of the content of its parent view.
		- The superview-subview relationship also impacts several view behaviors. Changes that affect subviews include: 
			- changing the size of a parent view
			- hiding a superview
			- changing a superview’s alpha
			- applying a mathematical transform to a superview’s coordinate system.
		- The arrangement of views in a view hierarchy also determines how your application **responds to events**. 
			- responder chain
		- Create view hierarchies: see [Creating and Managing a View Hierarchy](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/CreatingViews/CreatingViews.html#//apple_ref/doc/uid/TP40009503-CH5-SW47).
	- [The View Drawing Cycle](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/WindowsandViews/WindowsandViews.html#//apple_ref/doc/uid/TP40009503-CH2-SW10)
		- The `UIView` class uses an **on-demand** drawing model for presenting content. 
		- When the contents of your view change, you do not redraw those changes directly. Instead, you invalidate the view using either the [setNeedsDisplay](https://developer.apple.com/reference/uikit/uiview/1622437-setneedsdisplay) or [setNeedsDisplayInRect:](https://developer.apple.com/reference/uikit/uiview/1622587-setneedsdisplay) method. 
		- Note: Changing a view’s geometry does not automatically cause the system to redraw the view’s content. 
		- Provide a view’s content
			- System views typically implement private drawing methods to render their content. 
			- For custom `UIView` subclasses, you typically override the `drawRect: `method of your view and use that method to draw your view’s content.
			- Setting the contents of the underlying layer directly.
		- How to draw content for custom views: see [Implementing Your Drawing Code](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/CreatingViews/CreatingViews.html#//apple_ref/doc/uid/TP40009503-CH5-SW3)
	- Content Modes
		- Content modes are good for recycling the contents of your view.
		- The value in the [contentMode](https://developer.apple.com/reference/uikit/uiview/1622619-contentmode) property determines whether the bitmap should be scaled to fit the new bounds or simply pinned to one corner or edge of the view.
		- The content mode of a view is applied whenever you do the following:
			- Change the width or height of the view’s `frame` or`bounds` rectangles.
			- Assign a transform that includes a scaling factor to the view’s `transform` property.
		- [UIViewContentModeRedraw](https://developer.apple.com/reference/uikit/uiviewcontentmode/uiviewcontentmoderedraw)
			-  Setting your view’s content mode to this value forces the system to call your view’s drawRect: method in response to geometry changes.
			- In general, you should avoid using this value whenever possible, and you should certainly not use it with the standard system views.
			
	**Figure 1-2** Content mode comparisons
	
	![](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/Art/scale_aspect.jpg)
	
	- Stretchable Views
		- Why we need stretchable views: You can designate **a portion of a view as stretchable** so that when the size of the view changes **only** the content in the stretchable portion is affected.
		- Usage
			- You typically use stretchable areas for buttons or other views where part of the view defines a **repeatable** pattern.
			- When stretching a view along two axes, the edges of the view must also define a **repeatable** pattern to avoid any distortion.
			-  The use of the `contentStretch` property is recommended over the creation of a stretchable UIImage object when specifying the background for a view.
		- [contentStretch](https://developer.apple.com/reference/uikit/uiview/1622511-contentstretch) property: The use of normalized values alleviates the need for you to update the `contentStretch` property every time the bounds of your view change.
		- Stretchable areas are only used when the **content mode** would cause the view’s content to be scaled.
		
	**Figure 1-3**  Stretching the background of a button
	
	![](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/Art/button_scale.jpg)

	- Built-In Animation Support
		- To perform an animation for one of animatable properties of `UIView` class, all you have to do is:
			1. Tell UIKit that you want to perform an animation.
			2. Change the value of the property.
		- Among the properties you can animate on a UIView object are the following:
			- `frame`
			- `bounds`
			- `center`
			- `transform`: Use this to rotate or scale the view.
			- `alpha`
			- `backgroundColor`
			- `contentStretch`
		- View Transition
			- View-controller-based
			- View-based
		- Create animations using Core Animation layers: Dropping down to the layer level gives you much more control over the **timing** and **properties** of your animations.
		- How to perform view-based animations: see [Animations](#animations).
		- How to create animations by using Core Animation: see [Core Animation Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40004514) and Core Animation Cookbook
- View Geometry and Coordinate Systems
	- Inroduction
		- The default coordinate system in `UIKit` has its origin in the **top-left** corner and has axes that extend down and to the right from the origin point.(Some iOS technologies define default coordinate systems whose origin point and orientation differ from those used by `UIKit`.Such as `Core Graphics` and `OpenGL ES`.)
	- The Relationship of the Frame, Bounds, and Center Properties
		- A view object tracks its size and location using its frame, bounds, and center properties:
			- The `frame` property contains the frame rectangle, which specifies the size and location of the view in its **superview’s** coordinate system.
			- The `bounds` property contains the bounds rectangle, which specifies the size of the view (and its **content origin**) in the **view’s own** local coordinate system.
			- The `center` property contains the known center point of the view in the **superview’s** coordinate system.
		- The `frame` property is considered invalid if the view’s transform is not equal to the identity transform.
		- You use the `bounds` property primarily during drawing. 
		- By default, a view’s frame is not clipped to its superview’s frame.You can change this behavior by setting the superview’s `clipsToBounds` property to `YES`.
		- Regardless of whether or not subviews are clipped visually, **touch events** always respect the bounds rectangle of the target view’s superview. 
	- Coordinate System Transformations
	    - How you apply the affine transform therefore depends on context:
	    	- To modify your entire view, modify the affine transform in the `transform` property of your view.
	    	- To modify specific pieces of content in your view’s `drawRect:` method, modify the affine transform associated with the active graphics context.
		- You typically modify the `transform` property of a view when you want to implement **animations**. You would not use this property to make **permanent** changes to your view.
		- When modifying the `transform` property of your view, all transformations are performed relative to the center point of the view.
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
- *[View Controller Programming Guide for iOS](https://developer.apple.com/library/content/featuredarticles/ViewControllerPGforiPhoneOS/index.html#//apple_ref/doc/uid/TP40007457)*
- *[Event Handling Guide for UIKit Apps](https://developer.apple.com/library/content/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/index.html#//apple_ref/doc/uid/TP40009541)*
- *[Drawing and Printing Guide for iOS](https://developer.apple.com/library/content/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010156)*
- *[Core Animation Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40004514)*