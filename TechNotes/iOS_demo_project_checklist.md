Reading *[iOS demo project checklist ✅](http://codeplease.io/2017/04/15/tech-demo-checklist/)*
------

### About
This article talks about a iOS demo project checklist for interviewing for an iOS role. Some points are really practicle, I believe this article is not only helpful to those interviewees, but also helpful to all of the iOS developers.

### Checklist

1. Pay attention to the **spec**.
    - [Babylonpartners/iOS-Interview-Demo](https://github.com/Babylonpartners/iOS-Interview-Demo)

2. Your Xcode project folder should match your Xcode groups.
    - [venmo/synx](https://github.com/venmo/synx)

3. your folder structure should have some sort of **reasoning/logic** behind it. 

4. Keep your `AppDelegate.swift` clean.

5. The `UIViewController` will typically be **small** (as an exercise, keep it under 200 lines).
    

6. Make the code in method: `tableView:cellForRowAtIndexPath:` more readable. Do NOT setting the value of a cells directly (`cell.myLabel.text = ...`), or have a big `switch` in it, you'd better create a new entity and pass it to the cell.

7. Use a **value semantics** to represent your **model layer**.(???)
    - [A Warm Welcome to Structs and Value Types](https://www.objc.io/issues/16-swift/swift-classes-vs-structs/)

8. For a demo test, it's probably better to just use an `URLSession` instead of a 3rd party library for **network layer**.

9. Persistence layer: it's a good choice to create a separation between the objects you are persisting and the objects you are passing around the App.
    - You could [do this instead](https://gist.github.com/RuiAAPeres/640c1bb3f005edfe9f1980cd8849eb57)(But I don't get it😂).

10. Don't use NSUserDefaults for persistence.(Why???)

11. Don't use boolean flags for the network responses.(???)

12. Be aware of the separation between: Network, Parser and Persistence.
    - [An example of the separation](https://github.com/raywenderlich/mvc-modern-approach/blob/master/MVCDemo/Components/Controllers/WWDCAttendeesController.swift#L57#L60), using just vanilla closures

13. Error handling: Having an Unknown error message, is not really acceptable. The failure path is as important as the golden path. 

14. Don't use approaches/libraries you are not familiar with.

15. If you are using git, keep the commits small with **clear** messages.

16. Unit tests

17. Leave `TODO`s if you have to.

18. **people love to see things that are familiar/dear to them**: if you see a given technology/approach, is used by the company you are applying to, use it in your project. You can also do the same if the person that is reviewing the test is into a certain approach/technology

19. Use localization. Show your attention to detail.

20. Naming: make sure that your entity names make sense.

21. It's important that your code looks "swifty": It's easy/tempting to write Swift as if it was Objective-c.
    - [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

22. Be consistent in your code.
    - [raywenderlich/swift-style-guide](https://github.com/raywenderlich/swift-style-guide)

23. Make sure your project compiles and actually does what it's supposed to do.

24. Run Instruments to make sure you don't have any memory leak.

25. Have a look at every file in your project one last time before submitting.
    - [Rubber duck debugging](https://en.wikipedia.org/wiki/Rubber_duck_debugging)


### Further Reading

- Dependency injection
- Realm
- [Promises](https://github.com/mxcl/PromiseKit)
- [FRP frameworks](https://github.com/ReactiveCocoa/ReactiveSwift)
- [AsyncDisplayKit](http://texturegroup.org)


