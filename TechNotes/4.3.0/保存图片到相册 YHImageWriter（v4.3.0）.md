保存图片到相册 YHImageWriter
----

1.保存图片到系统相册的方式
How to save picture to iPhone photo library?
http://stackoverflow.com/questions/178915/how-to-save-picture-to-iphone-photo-library

两种方式：
方式1：
UIKit 框架的 UIImagePickerController

void UIImageWriteToSavedPhotosAlbum(UIImage *image, id completionTarget, SEL completionSelector, void *contextInfo);

方式2：
ALAssetsLibrary 框架, 9.0 以后不能再使用了

- (void)writeImageToSavedPhotosAlbum:(CGImageRef)imageRef orientation:(ALAssetOrientation)orientation completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock; (iOS_4_0, iOS_9_0)

2.系统相册 bug：图片（640 x 1309）在 iPhone 6（750 x 1334）中展示时会被截取掉

3.block 与 void * 类型的互转
How to cast blocks to and from void * ？

http://stackoverflow.com/q/11106224/7088321

ARC and bridged cast

http://stackoverflow.com/questions/7036350/arc-and-bridged-cast

3.YHImageWriter