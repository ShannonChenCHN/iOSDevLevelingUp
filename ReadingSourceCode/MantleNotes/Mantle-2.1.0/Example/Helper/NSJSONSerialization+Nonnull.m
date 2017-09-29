//  NSJSONSerialization+RemovingNulls.m
//  Created by Richard Turton on 23/12/2013.

#import "NSJSONSerialization+Nonnull.h"

@implementation NSJSONSerialization (RemovingNulls)

+(id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError *__autoreleasing *)error removingNulls:(BOOL)removingNulls ignoreArrays:(BOOL)ignoreArrays
{
    // Mutable containers are required to remove nulls.
    if (removingNulls)
    {
        // Force add NSJSONReadingMutableContainers since the null removal depends on it.
        opt = opt | NSJSONReadingMutableContainers;
    }
    
    id JSONObject = [self JSONObjectWithData:data options:opt error:error];
    
    if ((error && *error) || !removingNulls)
    {
        return JSONObject;
    }
    
    if (![JSONObject isKindOfClass:[NSArray class]] && ![JSONObject isKindOfClass:[NSDictionary class]]) {
        
        return JSONObject;
    }
    
    [JSONObject recursivelyRemoveNullsIgnoringArrays:ignoreArrays];
    return JSONObject;
}

@end

@implementation NSMutableDictionary (RemovingNulls)

-(void)recursivelyRemoveNulls
{
    [self recursivelyRemoveNullsIgnoringArrays:NO];
}

- (void)recursivelyRemoveNullsIgnoringArrays:(BOOL)ignoringArrays
{
    // First, filter out directly stored nulls
    NSMutableArray *nullKeys = [NSMutableArray array];
    NSMutableArray *arrayKeys = [NSMutableArray array];
    NSMutableArray *dictionaryKeys = [NSMutableArray array];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if (obj ==[NSNull null])
         {
             [nullKeys addObject:key];
         }
         else if ([obj isKindOfClass:[NSDictionary  class]])
         {
             [dictionaryKeys addObject:key];
         }
         else if ([obj isKindOfClass:[NSArray class]])
         {
             [arrayKeys addObject:key];
         }
     }];
    
    // Remove all the nulls
    [self removeObjectsForKeys:nullKeys];
    
    // Recursively remove nulls from arrays
    for (id arrayKey in arrayKeys)
    {
        NSMutableArray *array = self[arrayKey];
        [array recursivelyRemoveNullsIgnoringArrays:ignoringArrays];
    }
    
    // Cascade down the dictionaries
    for (id dictionaryKey in dictionaryKeys)
    {
        NSMutableDictionary *dictionary = self[dictionaryKey];
        [dictionary recursivelyRemoveNullsIgnoringArrays:ignoringArrays];
    }
}

@end

@implementation NSMutableArray (RemovingNulls)

-(void)recursivelyRemoveNulls
{
    [self recursivelyRemoveNullsIgnoringArrays:NO];
}

- (void)recursivelyRemoveNullsIgnoringArrays:(BOOL)ignoringArrays
{
    // First, filter out directly stored nulls if required
    if (!ignoringArrays)
    {
        [self filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings)
                                    {
                                        return evaluatedObject != [NSNull null];
                                    }]];
        
    }
    
    NSMutableIndexSet *arrayIndexes = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *dictionaryIndexes = [NSMutableIndexSet indexSet];
    
    [self enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[NSDictionary  class]])
         {
             [dictionaryIndexes addIndex:idx];
         }
         else if ([obj isKindOfClass:[NSArray class]])
         {
             [arrayIndexes addIndex:idx];
         }
     }];
    
    
    
    // Recursively remove nulls from arrays
    for (NSMutableArray *containedArray  in [self objectsAtIndexes:arrayIndexes])
    {
        [containedArray recursivelyRemoveNullsIgnoringArrays:ignoringArrays];
    }
    
    // Cascade down the dictionaries
    for (NSMutableDictionary * containedDictionary in [self objectsAtIndexes:dictionaryIndexes])
    {
        [containedDictionary recursivelyRemoveNullsIgnoringArrays:ignoringArrays];
    }
}

@end
