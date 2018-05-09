//
//  JSEngine.h
//  SCPatch
//
//  Created by ShannonChen on 2018/5/2.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSEngine : NSObject

+ (void)evaluateJavaScriptString:(NSString *)string;

@end
