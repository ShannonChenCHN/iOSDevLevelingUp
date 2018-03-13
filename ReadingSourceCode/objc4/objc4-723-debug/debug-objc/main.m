
//  main.m
//  debug-objc
//
//  Created by closure on 2/24/16.
//
//

#import <Foundation/Foundation.h>
#import "XXObject.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        Class cls = [XXObject class];
        XXObject *obj = [[cls alloc] init];
        obj.name = @"Michael";
        [obj hello];

        
        NSLog(@"%p", cls);
    }
    return 0;
}
