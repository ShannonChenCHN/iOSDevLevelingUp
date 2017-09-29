//
//  NSJSONSerialization+Nonnull.h
//  NetworkingDemo
//
//  Created by ShannonChen on 17/4/7.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSJSONSerialization (RemovingNulls)

/// As the base class method, but pass YES to remove nulls from containers, optionally ignoring those in arrays.
+(id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError *__autoreleasing *)error removingNulls:(BOOL)removingNulls ignoreArrays:(BOOL)ignoreArrays;

@end

@interface NSMutableDictionary (RemovingNulls)

-(void)recursivelyRemoveNulls;
-(void)recursivelyRemoveNullsIgnoringArrays:(BOOL)ignoringArrays;

@end

@interface NSMutableArray (RemovingNulls)

-(void)recursivelyRemoveNulls;
-(void)recursivelyRemoveNullsIgnoringArrays:(BOOL)ignoringArrays;

@end
