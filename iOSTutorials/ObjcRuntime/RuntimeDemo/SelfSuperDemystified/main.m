//
//  main.m
//  SelfSuperDemystified
//
//  Created by ShannonChen on 2018/5/4.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Grandparent : NSObject

- (void) One;

@end

@implementation Grandparent

- (void) One { NSLog(@"Grandparent One\n"); }

@end

@interface Parent : Grandparent

- (void) One;
- (void) Two;

@end

@implementation Parent

- (void) One { NSLog(@"Parent One\n"); }

- (void) Two
{
    [self One];                 // will call One based on the calling object
    [super One];                // will call One based on the defining object - Parent in this case so will Grandparent's One
}

@end

@interface Child : Parent

- (void) One;

@end

@implementation Child

- (void) One { NSLog(@"Child One\n"); }

@end

void testSelfSuper() {
    Child *c = [Child new];
    [c Two];                            // will call the Two inherited from Parent
    
    Parent *p = [Parent new];
    [p Two];                            // will call Parent's Two
    
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        testSelfSuper();
        
    }
    return 0;
}
