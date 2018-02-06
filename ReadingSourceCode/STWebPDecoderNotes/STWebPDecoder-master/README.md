# STWebPDecoder

A simple wrapper for libwebp, providing a simple interface to decode WebP image data for use in iOS / Mac applications.

```
NSString * const webpPath = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"webp"];
NSData * const webpData = [[NSData alloc] initWithContentsOfFile:webpPath options:NSDataReadingMappedIfSafe error:NULL];
self.imageView.image = [STWebPDecoder imageWithData:webpData scale:2 error:NULL];
```

# STWebPURLProtocol

More interestingly, this class allows transparent use of WebP images inside UIWebViews.

```
[STWebPURLProtocol registerWithOptions:@{ STWebPURLProtocolOptionClaimWebPExtension: @YES }];
```
…
```
[self.webView loadHTMLString:@"<img src=\"https://www.gstatic.com/webp/gallery3/2_webp_ll.webp\">" baseURL:nil];
```
