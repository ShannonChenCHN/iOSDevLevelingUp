#import <Foundation/Foundation.h>

@interface NyanCat : NSObject {
    int age;
    NSString *name;
}
- (void)nyan;
+ (void)nyan;
@end

@implementation NyanCat
- (void)nyan1 {
    printf("instance nyan~");
}
+ (void)nyan2 {
    printf("class nyan~");
}
@end


int main() {
    
    NyanCat *cat = [[NyanCat alloc] init];
    [cat nyan1];
    
    [NyanCat nyan2];
    
    return 0;
}
