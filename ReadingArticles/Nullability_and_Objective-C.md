Reading *[Nullability and Objective-C](https://developer.apple.com/swift/blog/?id=25)*
-----

## About

#### Background
In Swift there’s a strong distinction between optional and non-optional references, e.g. `NSView` vs. `NSView?`, while Objective-C represents boths of these two types as `NSView *`.

#### Problem
Because the Swift compiler can’t be sure whether a particular `NSView *` is optional or not, the type is brought into Swift as an implicitly unwrapped optional, `NSView!`.

#### API Berfore Xcode 6.3
In previous Xcode releases, some Apple frameworks had been specially audited so that their API would show up with proper Swift optionals.

#### API Since Xcode 6.3
Xcode 6.3 supports this for your own code with a new Objective-C language feature: *nullability* annotations.

## The Core: `_Nullable` and `_Nonnull`
#### What do `_Nullable` and `_Nonnull` mean
a `_Nullable` pointer may have a `NULL` or `nil` value, while a `_Nonnull` one should not. The compiler will tell you if you try to break the rules.

#### Usage
- You can use `_Nullable` and `_Nonnull` almost anywhere you can use the normal C `const` keyword
- They have to apply to a **pointer** type
- There’s a much nicer way to write these annotations: `nullable` and `nonnull`

## Audited Regions(`NS_ASSUME_NONNULL_BEGIN` and `NS_ASSUME_NONNULL_END`)
#### Benifits
The non-underscored forms are nicer than the underscored ones, but you’d still need to apply them to every type in your header. **To make that job easier and to make your headers clearer**, you’ll want to use *audited regions*.

#### Usage and Rule
To ease adoption of the new annotations, you can mark **certain regions** of your Objective-C **header files** as *audited* for *nullability*. Within these regions, any simple pointer type will be assumed to be `nonnull`.

#### Exceptions
- `typedef` types don’t usually have an inherent nullability
- More complex pointer types like `id *` must be explicitly annotated
- it is always assumed to be a nullable pointer to a nullable `NSError` reference

## Compatibility
In general, you should look at nullable and nonnull roughly the way you currently use assertions or exceptions: violating the contract is a programmer error. 
(**Couldn't understand about this well.**)


## Back to Swift
See [Demo Project]()

## Other Resources
- What is ABI? [ABI-wiki](https://en.wikipedia.org/wiki/Application_binary_interface)
- [Using nullable to annotate Objective-C code](https://useyourloaf.com/blog/using-nullable-to-annotate-objective-c/)

