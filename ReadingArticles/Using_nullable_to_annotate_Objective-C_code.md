Reading *[Using nullable to annotate Objective-C code](https://useyourloaf.com/blog/using-nullable-to-annotate-objective-c/)*
-----------

#### Problem
By default, Swift interface will treat all Objective-C references as *implicitly unwrapped optionals*. All those “!” symbols make for some ugly and unsafe Swift code.

#### Solution
Annotate your Objective-C header file with `nullable` and `nonnull`.


#### Viewing the Swift interface with Xcode
![](https://useyourloaf.com/assets/images/2016/2016-01-08-001.png)


#### Implicitly Unwrapped Optionals!
The problem comes from the different ways Objective-C and Swift handle NULL or nil values. 

It is common in Objective-C to return nil for an object reference where in Swift you would use an optional type.

Unfortunately there is nothing in the Objective-C code that tells the compiler which references can be nil so it assumes the worst and makes everything an implicitly unwrapped optional.


#### Nullability Annotations

- Marking types as `nonnull` imports them as **non-optional** in Swift.
- Marking types as `nullable` imports them as **optional** in Swift.


#### `NS_ASSUME_NONNULL_BEGIN` and `NS_ASSUME_NONNULL_END`

- Once you add a single annotation to a header file Xcode expects you to annotate the whole interface. 
- Using `NS_ASSUME_NONNULL_BEGIN` and `NS_ASSUME_NONNULL_END` to save some time, We then only need to add `nullable` annotations for references that can be nil.

#### Conclusion
The problem mentioned at the beginnning of this article only happens when you using Objective-C classes in Swift. Neverthness, it's still a good practice to use nullability annotation in only-for-Objective-C classes.

#### Source Code
See [Demo Project](https://github.com/ShannonChenCHN/Playground/tree/master/NullabilityDemo)