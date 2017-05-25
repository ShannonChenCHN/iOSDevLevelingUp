# [Image Resizing Techniques](http://nshipster.com/image-resizing/)


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

#### 3.1 Core Graphics
#### 3.1.1 UIGraphicsBeginImageContextWithOptions & UIImage -drawInRect:

#### 3.1.2 CGBitmapContextCreate & CGContextDrawImage

#### 3.2 Image I/O: CGImageSourceCreateThumbnailAtIndex

#### 3.3 Lanczos Resampling with Core Image

#### 3.4 vImage in Accelerate

### 4. Performance Benchmarks

### 5. Conclusions
