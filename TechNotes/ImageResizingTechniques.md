# [Image Resizing Techniques](http://nshipster.com/image-resizing/)

[ExampleProject](https://github.com/ShannonChenCHN/Playground/tree/master/ImageResizingExample)


### 1. Introduction
#### 1.1 Question
  - How do you resize an image?

#### 1.2 Purpose
  - provide a clear explanation of the various approaches to image resizing on iOS and OS X
  - using empirical evidence to offer insights into the performance characteristics of each approach, rather than simply prescribing any one way for all situations.

#### 1.3 Before reading any further, please note the following:
  - When setting a `UIImage` on a `UIImageView`, manual resizing is unnecessary for the vast majority of use cases.
  - Instead, one can simply set the `contentMode` property to either `.ScaleAspectFit` or `.ScaleAspectFill`.

### 2. Determining Scaled Size

#### 2.1 Scaling by Factor
- The simplest way to scale an image is by a **constant factor**

- A new CGSize can be computed by:
  - scaling the width and height components individually

     `let size = CGSize(width: image.size.width / 2, height: image.size.height / 2)`

  - by applying a CGAffineTransform 

     `let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5))`

#### 2.2 Scaling by Aspect Ratio
- It’s often useful to scale the original size in such a way that **fits within a rectangle without changing the original aspect ratio**

- `AVMakeRectWithAspectRatioInsideRect` is a useful function found in the `AVFoundation` framework that takes care of that calculation for you
   ```
   import AVFoundation
   let rect = AVMakeRectWithAspectRatioInsideRect(image.size, imageView.bounds)
   ```

### 3. Resizing Images

#### 3.1 UIKit: UIGraphicsBeginImageContextWithOptions & UIImage -drawInRect:

```
let targetSize = __CGSizeApplyAffineTransform(image.size, CGAffineTransform.identity.scaledBy(x: scale, y: scale)) // the target size of the scaled image.
let hasAlpha = false  // for images without transparency (i.e. an alpha channel)
let scaleFactor: CGFloat = 0.0 // the display scale factor, automatically use scale factor of main screen

// 1. Creates a temporary rendering context into which the original is drawn.
UIGraphicsBeginImageContextWithOptions(targetSize, hasAlpha, scaleFactor)

// 2. draw image in target size on bitmap-based graphics context
originalImage.draw(in: CGRect.init(origin: CGPoint(x: 0.0, y: 0.0), size: targetSize))

// 3. retrieve image from raphics context
let scaledImage = UIGraphicsGetImageFromCurrentImageContext()

// 4. cleanup
UIGraphicsEndImageContext()
```

#### 3.2 Core Graphics: CGBitmapContextCreate & CGContextDrawImage

```
let targetWidth = CGFloat(cgImage.width) * scale
let targetHeight = CGFloat(cgImage.height) * scale
let targetSize = CGSize.init(width: targetWidth, height: targetHeight)

// construct a context with desired dimensions and amount of memory for each channel within a given colorspace
let context = CGContext.init(data: nil,
                            width: Int(targetWidth),
                           height: Int(targetHeight),
                 bitsPerComponent: cgImage.bitsPerComponent,
                      bytesPerRow:0,
                            space: cgImage.colorSpace!,
                       bitmapInfo: cgImage.bitmapInfo.rawValue)

context?.interpolationQuality = .none  // CGContextSetInterpolationQuality allows for the context to interpolate pixels at various levels of fidelity
context?.draw(cgImage, in: CGRect.init(origin: CGPoint(), size:targetSize)) //  draw(_,in:) allows for the image to be drawn at a given size and position, allowing for the image to be cropped on a particular edge or to fit a set of image features, such as faces

let scaledImage = context?.makeImage().flatMap{UIImage.init(cgImage: $0)}  // creates a CGImage from the context


```

#### 3.2 Image I/O: CGImageSourceCreateThumbnailAtIndex（for thumbnails）

```
let options: [NSString: Any] = [
                                kCGImageSourceThumbnailMaxPixelSize: max(image.size.width * screenScale, image.size.height * screenScale) * scale,
                                kCGImageSourceCreateThumbnailFromImageAlways: true
                                ]


let imageSource = CGImageSourceCreateWithData(UIImagePNGRepresentation(image) as! CFData, nil)
let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource!, 0, options as CFDictionary?).map{UIImage.init(cgImage: $0)}

```

#### 3.3 Lanczos Resampling with Core Image

```
let filter = CIFilter(name: "CILanczosScaleTransform")!
filter.setValue(CIImage.init(image: image), forKey: kCIInputImageKey)
filter.setValue(scale, forKey: kCIInputScaleKey)
filter.setValue(1.0, forKey: kCIInputAspectRatioKey)
let outputImage = filter.outputImage!


// A CIContext is used to create a UIImage by way of a CGImageRef intermediary representation, since UIImage(CIImage:) doesn’t often work as expected.
// Creating a CIContext is an expensive operation, so a cached context should always be used for repeated resizing. A CIContext can be created using either the GPU or the CPU (much slower) for rendering—use the kCIContextUseSoftwareRenderer key in the options dictionary to specify which.
let context = CIContext(options: [kCIContextUseSoftwareRenderer: false])

let scaledImage = UIImage(cgImage: context.createCGImage(outputImage, from: outputImage.extent)!)


```

#### 3.4 vImage in Accelerate



### 4. Performance Benchmarks

见 [Benchmark](http://nshipster.com/benchmarking/) 相关 [Demo](https://github.com/natecook1000/Image-Resizing)。

### 5. Conclusions
> 综合性能上的对比，各方式的应用场景

- UIKit, Core Graphics 和 Image I/O 在图片缩放时的性能表现都差不多，耗时都比较短
- Core Image is outperformed for image scaling operations. In fact, it is specifically recommended in the Performance Best Practices section of the Core Image Programming Guide to use Core Graphics or Image I/O functions to crop or downsample images beforehand.
- 大部分场景下没有特殊要求的的图片缩放，用 UIGraphicsBeginImageContextWithOptions 就可以满足需求
- 如果在图片缩放时，对图片质量有一定的要求，推荐结合使用 CGBitmapContextCreate 和 CGContextSetInterpolationQuality
- 针对缩略图，推荐使用 CGImageSourceCreateThumbnailAtIndex，它在渲染和缓存方面提供了很好的解决方案
- vImage 是基于底层 Accelerate framework 的，用起来需要做很多工作，除非你对其非常了解，否则事倍功半 



