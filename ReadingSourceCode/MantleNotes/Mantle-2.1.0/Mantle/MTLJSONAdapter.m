//
//  MTLJSONAdapter.m
//  Mantle
//
//  Created by Justin Spahr-Summers on 2013-02-12.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <objc/runtime.h>

#import "NSDictionary+MTLJSONKeyPath.h"

#import "EXTRuntimeExtensions.h"
#import "EXTScope.h"
#import "MTLJSONAdapter.h"
#import "MTLModel.h"
#import "MTLTransformerErrorHandling.h"
#import "MTLReflection.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"
#import "MTLValueTransformer.h"

NSString * const MTLJSONAdapterErrorDomain = @"MTLJSONAdapterErrorDomain";
const NSInteger MTLJSONAdapterErrorNoClassFound = 2;
const NSInteger MTLJSONAdapterErrorInvalidJSONDictionary = 3;
const NSInteger MTLJSONAdapterErrorInvalidJSONMapping = 4;

// An exception was thrown and caught.
const NSInteger MTLJSONAdapterErrorExceptionThrown = 1;

// Associated with the NSException that was caught.
NSString * const MTLJSONAdapterThrownExceptionErrorKey = @"MTLJSONAdapterThrownException";

@interface MTLJSONAdapter ()

// The MTLModel subclass being parsed, or the class of `model` if parsing has
// completed.
@property (nonatomic, strong, readonly) Class modelClass;

// A cached copy of the return value of +JSONKeyPathsByPropertyKey.
@property (nonatomic, copy, readonly) NSDictionary *JSONKeyPathsByPropertyKey;

// A cached copy of the return value of -valueTransformersForModelClass:
@property (nonatomic, copy, readonly) NSDictionary *valueTransformersByPropertyKey;

// Used to cache the JSON adapters returned by -JSONAdapterForModelClass:error:.
@property (nonatomic, strong, readonly) NSMapTable *JSONAdaptersByModelClass;

// If +classForParsingJSONDictionary: returns a model class different from the
// one this adapter was initialized with, use this method to obtain a cached
// instance of a suitable adapter instead.
//
// modelClass - The class from which to parse the JSON. This class must conform
//              to <MTLJSONSerializing>. This argument must not be nil.
// error -      If not NULL, this may be set to an error that occurs during
//              initializing the adapter.
//
// Returns a JSON adapter for modelClass, creating one of necessary. If no
// adapter could be created, nil is returned.
- (MTLJSONAdapter *)JSONAdapterForModelClass:(Class)modelClass error:(NSError **)error;

// Collect all value transformers needed for a given class.
//
// modelClass - The class from which to parse the JSON. This class must conform
//              to <MTLJSONSerializing>. This argument must not be nil.
//
// Returns a dictionary with the properties of modelClass that need
// transformation as keys and the value transformers as values.
+ (NSDictionary *)valueTransformersForModelClass:(Class)modelClass;

@end

@implementation MTLJSONAdapter

#pragma mark Convenience methods

+ (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)JSONDictionary error:(NSError **)error {
	
    // 创建 adapter 类
    MTLJSONAdapter *adapter = [[self alloc] initWithModelClass:modelClass];

    // 创建 model
	return [adapter modelFromJSONDictionary:JSONDictionary error:error];
}

+ (NSArray *)modelsOfClass:(Class)modelClass fromJSONArray:(NSArray *)JSONArray error:(NSError **)error {
	if (JSONArray == nil || ![JSONArray isKindOfClass:NSArray.class]) {
		if (error != NULL) {
			NSDictionary *userInfo = @{
				NSLocalizedDescriptionKey: NSLocalizedString(@"Missing JSON array", @""),
				NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"%@ could not be created because an invalid JSON array was provided: %@", @""), NSStringFromClass(modelClass), JSONArray.class],
			};
			*error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorInvalidJSONDictionary userInfo:userInfo];
		}
		return nil;
	}

	NSMutableArray *models = [NSMutableArray arrayWithCapacity:JSONArray.count];
	for (NSDictionary *JSONDictionary in JSONArray){
		MTLModel *model = [self modelOfClass:modelClass fromJSONDictionary:JSONDictionary error:error];

		if (model == nil) return nil;

		[models addObject:model];
	}

	return models;
}

+ (NSDictionary *)JSONDictionaryFromModel:(id<MTLJSONSerializing>)model error:(NSError **)error {
	MTLJSONAdapter *adapter = [[self alloc] initWithModelClass:model.class];

	return [adapter JSONDictionaryFromModel:model error:error];
}

+ (NSArray *)JSONArrayFromModels:(NSArray *)models error:(NSError **)error {
	NSParameterAssert(models != nil);
	NSParameterAssert([models isKindOfClass:NSArray.class]);

	NSMutableArray *JSONArray = [NSMutableArray arrayWithCapacity:models.count];
	for (MTLModel<MTLJSONSerializing> *model in models) {
		NSDictionary *JSONDictionary = [self JSONDictionaryFromModel:model error:error];
		if (JSONDictionary == nil) return nil;

		[JSONArray addObject:JSONDictionary];
	}

	return JSONArray;
}

#pragma mark Lifecycle

- (id)init {
	NSAssert(NO, @"%@ must be initialized with a model class", self.class);
	return nil;
}

- (id)initWithModelClass:(Class)modelClass {
	NSParameterAssert(modelClass != nil);
	NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLJSONSerializing)]);

	self = [super init];
	if (self == nil) return nil;

	_modelClass = modelClass;

    // 属性名和 keypath 的映射
	_JSONKeyPathsByPropertyKey = [modelClass JSONKeyPathsByPropertyKey];

    // 获取所有参与 JSON 解析的属性名
	NSSet *propertyKeys = [self.modelClass propertyKeys];

    
    // 检查 _JSONKeyPathsByPropertyKey 中的 key 和 value 是否都合法
	for (NSString *mappedPropertyKey in _JSONKeyPathsByPropertyKey) {
        // 检查 _JSONKeyPathsByPropertyKey 中的 key 是否都是 model 的属性名
		if (![propertyKeys containsObject:mappedPropertyKey]) {
			NSAssert(NO, @"%@ is not a property of %@.", mappedPropertyKey, modelClass);
			return nil;
		}

        // 取出属性对应的字段名，判断 keypath 类型是否都符合要求，要么是包含 NSString 的 NSArray，要么就是 NSString
		id value = _JSONKeyPathsByPropertyKey[mappedPropertyKey];

		if ([value isKindOfClass:NSArray.class]) {
            // keypath 是数组？
            
			for (NSString *keyPath in value) {
				if ([keyPath isKindOfClass:NSString.class]) continue;

				NSAssert(NO, @"%@ must either map to a JSON key path or a JSON array of key paths, got: %@.", mappedPropertyKey, value);
				return nil;
			}
		} else if (![value isKindOfClass:NSString.class]) {
			NSAssert(NO, @"%@ must either map to a JSON key path or a JSON array of key paths, got: %@.",mappedPropertyKey, value);
			return nil;
		}
	}

    // 解析各属性时的 transformer
	_valueTransformersByPropertyKey = [self.class valueTransformersForModelClass:modelClass];

    // 缓存 -JSONAdapterForModelClass:error: 中创建的 MTLJSONAdapter，只在解析的 model 类不是 self.class 时用到
	_JSONAdaptersByModelClass = [NSMapTable strongToStrongObjectsMapTable];

	return self;
}

#pragma mark Serialization

- (NSDictionary *)JSONDictionaryFromModel:(id<MTLJSONSerializing>)model error:(NSError **)error {
	NSParameterAssert(model != nil);
	NSParameterAssert([model isKindOfClass:self.modelClass]);

	if (self.modelClass != model.class) {
		MTLJSONAdapter *otherAdapter = [self JSONAdapterForModelClass:model.class error:error];

		return [otherAdapter JSONDictionaryFromModel:model error:error];
	}

	NSSet *propertyKeysToSerialize = [self serializablePropertyKeys:[NSSet setWithArray:self.JSONKeyPathsByPropertyKey.allKeys] forModel:model];

	NSDictionary *dictionaryValue = [model.dictionaryValue dictionaryWithValuesForKeys:propertyKeysToSerialize.allObjects];
	NSMutableDictionary *JSONDictionary = [[NSMutableDictionary alloc] initWithCapacity:dictionaryValue.count];

	__block BOOL success = YES;
	__block NSError *tmpError = nil;

	[dictionaryValue enumerateKeysAndObjectsUsingBlock:^(NSString *propertyKey, id value, BOOL *stop) {
		id JSONKeyPaths = self.JSONKeyPathsByPropertyKey[propertyKey];

		if (JSONKeyPaths == nil) return;

		NSValueTransformer *transformer = self.valueTransformersByPropertyKey[propertyKey];
		if ([transformer.class allowsReverseTransformation]) {
			// Map NSNull -> nil for the transformer, and then back for the
			// dictionaryValue we're going to insert into.
			if ([value isEqual:NSNull.null]) value = nil;

			if ([transformer respondsToSelector:@selector(reverseTransformedValue:success:error:)]) {
				id<MTLTransformerErrorHandling> errorHandlingTransformer = (id)transformer;

				value = [errorHandlingTransformer reverseTransformedValue:value success:&success error:&tmpError];

				if (!success) {
					*stop = YES;
					return;
				}
			} else {
				value = [transformer reverseTransformedValue:value] ?: NSNull.null;
			}
		}

		void (^createComponents)(id, NSString *) = ^(id obj, NSString *keyPath) {
			NSArray *keyPathComponents = [keyPath componentsSeparatedByString:@"."];

			// Set up dictionaries at each step of the key path.
			for (NSString *component in keyPathComponents) {
				if ([obj valueForKey:component] == nil) {
					// Insert an empty mutable dictionary at this spot so that we
					// can set the whole key path afterward.
					[obj setValue:[NSMutableDictionary dictionary] forKey:component];
				}

				obj = [obj valueForKey:component];
			}
		};

		if ([JSONKeyPaths isKindOfClass:NSString.class]) {
			createComponents(JSONDictionary, JSONKeyPaths);

			[JSONDictionary setValue:value forKeyPath:JSONKeyPaths];
		}

		if ([JSONKeyPaths isKindOfClass:NSArray.class]) {
			for (NSString *JSONKeyPath in JSONKeyPaths) {
				createComponents(JSONDictionary, JSONKeyPath);

				[JSONDictionary setValue:value[JSONKeyPath] forKeyPath:JSONKeyPath];
			}
		}
	}];

	if (success) {
		return JSONDictionary;
	} else {
		if (error != NULL) *error = tmpError;

		return nil;
	}
}

- (id)modelFromJSONDictionary:(NSDictionary *)JSONDictionary error:(NSError **)error {
    
    // 如果指定了要解析的目标 model class，为什么是直接取 self.class 呢？因为有可能是 class cluster
	if ([self.modelClass respondsToSelector:@selector(classForParsingJSONDictionary:)]) {
		Class class = [self.modelClass classForParsingJSONDictionary:JSONDictionary];
        
        // class 为空的情况
		if (class == nil) {
			if (error != NULL) {
				NSDictionary *userInfo = @{
					NSLocalizedDescriptionKey: NSLocalizedString(@"Could not parse JSON", @""),
					NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No model class could be found to parse the JSON dictionary.", @"")
				};

				*error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorNoClassFound userInfo:userInfo];
			}

			return nil;
		}

        // 如果不是 self.class
		if (class != self.modelClass) {
			NSAssert([class conformsToProtocol:@protocol(MTLJSONSerializing)], @"Class %@ returned from +classForParsingJSONDictionary: does not conform to <MTLJSONSerializing>", class);

            // 创建 Adapter
			MTLJSONAdapter *otherAdapter = [self JSONAdapterForModelClass:class error:error];

            // 创建 model
			return [otherAdapter modelFromJSONDictionary:JSONDictionary error:error];
		}
	}

	NSMutableDictionary *dictionaryValue = [[NSMutableDictionary alloc] initWithCapacity:JSONDictionary.count];

    // 遍历属性名
	for (NSString *propertyKey in [self.modelClass propertyKeys]) {
        // 取出 keypath
		id JSONKeyPaths = self.JSONKeyPathsByPropertyKey[propertyKey];

		if (JSONKeyPaths == nil) continue;

        // 从 JSONDictionary 中取出 propertyKey 对应的值
		id value;

		if ([JSONKeyPaths isKindOfClass:NSArray.class]) {
            // 如果 keypath 是数组，就遍历数组
            
			NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

            // 从 JSONDictionary 中找到 keypath 对应的值，并保存到临时字典中去，再赋值给 value
			for (NSString *keyPath in JSONKeyPaths) {
				BOOL success = NO;
				id value = [JSONDictionary mtl_valueForJSONKeyPath:keyPath success:&success error:error];

				if (!success) return nil;

				if (value != nil) dictionary[keyPath] = value;
			}

			value = dictionary;
		} else {
            // 如果不是数组，那就是字符串，直接从 JSONDictionary 中找到 keypath 对应的值，并赋值给 value
            
			BOOL success = NO;
			value = [JSONDictionary mtl_valueForJSONKeyPath:JSONKeyPaths success:&success error:error];

			if (!success) return nil;
		}

		if (value == nil) continue;

        // 这里为什么要用 Try-catch？
		@try {
            // 取出 transformer，如果不为空，就进行对 value 进行转换
			NSValueTransformer *transformer = self.valueTransformersByPropertyKey[propertyKey];
			if (transformer != nil) {
				// Map NSNull -> nil for the transformer, and then back for the
				// dictionary we're going to insert into.
                // 先将 NSNull 转为 nil，以备 transform，然后再转回来
				if ([value isEqual:NSNull.null]) value = nil;

                // 转换 value
				if ([transformer respondsToSelector:@selector(transformedValue:success:error:)]) {
					id<MTLTransformerErrorHandling> errorHandlingTransformer = (id)transformer;

					BOOL success = YES;
					value = [errorHandlingTransformer transformedValue:value success:&success error:error];

					if (!success) return nil;
				} else {
					value = [transformer transformedValue:value];
				}

                // 将 nil 转回 NSNull
				if (value == nil) value = NSNull.null;
			}

            // 将值保存到一对一映射属性的 dictionary 中
			dictionaryValue[propertyKey] = value;
		} @catch (NSException *ex) {
			NSLog(@"*** Caught exception %@ parsing JSON key path \"%@\" from: %@", ex, JSONKeyPaths, JSONDictionary);

			// Fail fast in Debug builds.
			#if DEBUG
			@throw ex;
			#else
			if (error != NULL) {
				NSDictionary *userInfo = @{
					NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Caught exception parsing JSON key path \"%@\" for model class: %@", JSONKeyPaths, self.modelClass],
					NSLocalizedRecoverySuggestionErrorKey: ex.description,
					NSLocalizedFailureReasonErrorKey: ex.reason,
					MTLJSONAdapterThrownExceptionErrorKey: ex
				};

				*error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorExceptionThrown userInfo:userInfo];
			}

			return nil;
			#endif
		}
	}

    // 使用最终的可以一对一映射属性的 dictionary 来初始化 model
	id model = [self.modelClass modelWithDictionary:dictionaryValue error:error];

	return [model validate:error] ? model : nil;
}

+ (NSDictionary *)valueTransformersForModelClass:(Class)modelClass {
	NSParameterAssert(modelClass != nil);
	NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLJSONSerializing)]);

	NSMutableDictionary *result = [NSMutableDictionary dictionary];

	for (NSString *key in [modelClass propertyKeys]) {
        
        // A. 如果 model 类实现了 “属性名+JSONTransformer” 的方法
        // 将属性名和 JSONTransformer 拼接后生成一个 selector
		SEL selector = MTLSelectorWithKeyPattern(key, "JSONTransformer");
		if ([modelClass respondsToSelector:selector]) {
            // MARK: 这里为什么不用 performSelector: 方法？
			IMP imp = [modelClass methodForSelector:selector];
			NSValueTransformer * (*function)(id, SEL) = (__typeof__(function))imp;
			NSValueTransformer *transformer = function(modelClass, selector);

			if (transformer != nil) result[key] = transformer;

			continue;
		}
 
        // B. 如果 model 类实现了 +JSONTransformerForKey: 的方法
		if ([modelClass respondsToSelector:@selector(JSONTransformerForKey:)]) {
			NSValueTransformer *transformer = [modelClass JSONTransformerForKey:key];

			if (transformer != nil) {
				result[key] = transformer;
				continue;
			}
		}
        
        // C. 如果上面两个都没实现

		objc_property_t property = class_getProperty(modelClass, key.UTF8String);

		if (property == NULL) continue;

		mtl_propertyAttributes *attributes = mtl_copyPropertyAttributes(property);
		@onExit {
			free(attributes);
		};

		NSValueTransformer *transformer = nil;

		if (*(attributes->type) == *(@encode(id))) {
            // 如果是 Objective-C 对象类型
            
			Class propertyClass = attributes->objectClass;

			if (propertyClass != nil) {
                // 自己实现的转换器，为系统类转换提供的方法，比如 +NSURLJSONTransformer，+NSUUIDJSONTransformer
				transformer = [self transformerForModelPropertiesOfClass:propertyClass];
			}


			// For user-defined MTLModel, try parse it with dictionaryTransformer.
            // 如果是用户自定义的 model，可以尝试用默认的 dictionaryTransformer 来转换
			if (nil == transformer && [propertyClass conformsToProtocol:@protocol(MTLJSONSerializing)]) {
				transformer = [self dictionaryTransformerWithModelClass:propertyClass];
			}
			
            // 验证一下对象类型对不对
			if (transformer == nil) transformer = [NSValueTransformer mtl_validatingTransformerForClass:propertyClass ?: NSObject.class];
		} else {
            // 如果不是 对象 类型
            
            // 如果是 BOOL 类型，就默认转成 BOOL 类型，如果不是，则用 NSValue 的标准去验证一下
			transformer = [self transformerForModelPropertiesOfObjCType:attributes->type] ?: [NSValueTransformer mtl_validatingTransformerForClass:NSValue.class];
		}

		if (transformer != nil) result[key] = transformer;
	}

	return result;
}

- (MTLJSONAdapter *)JSONAdapterForModelClass:(Class)modelClass error:(NSError **)error {
	NSParameterAssert(modelClass != nil);
	NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLJSONSerializing)]);

    // MARK: 为什么要加锁？
	@synchronized(self) {
        // 读取缓存
		MTLJSONAdapter *result = [self.JSONAdaptersByModelClass objectForKey:modelClass];

		if (result != nil) return result;

        // 创建 Adapter
		result = [[self.class alloc] initWithModelClass:modelClass];

        // 写入缓存
		if (result != nil) {
			[self.JSONAdaptersByModelClass setObject:result forKey:modelClass];
		}

		return result;
	}
}

- (NSSet *)serializablePropertyKeys:(NSSet *)propertyKeys forModel:(id<MTLJSONSerializing>)model {
	return propertyKeys;
}

// 通过“类名+JSONTransformer 的方法”获取 transformer
+ (NSValueTransformer *)transformerForModelPropertiesOfClass:(Class)modelClass {
	NSParameterAssert(modelClass != nil);

	SEL selector = MTLSelectorWithKeyPattern(NSStringFromClass(modelClass), "JSONTransformer");
	if (![self respondsToSelector:selector]) return nil;
	
	IMP imp = [self methodForSelector:selector];
	NSValueTransformer * (*function)(id, SEL) = (__typeof__(function))imp;
	NSValueTransformer *result = function(self, selector);
	
	return result;
}

+ (NSValueTransformer *)transformerForModelPropertiesOfObjCType:(const char *)objCType {
	NSParameterAssert(objCType != NULL);

	if (strcmp(objCType, @encode(BOOL)) == 0) {
		return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
	}

	return nil;
}

@end

@implementation MTLJSONAdapter (ValueTransformers)

+ (NSValueTransformer<MTLTransformerErrorHandling> *)dictionaryTransformerWithModelClass:(Class)modelClass {
	NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLModel)]);
	NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLJSONSerializing)]);
	__block MTLJSONAdapter *adapter;
	
	return [MTLValueTransformer
		transformerUsingForwardBlock:^ id (id JSONDictionary, BOOL *success, NSError **error) {
			if (JSONDictionary == nil) return nil;
			
			if (![JSONDictionary isKindOfClass:NSDictionary.class]) {
				if (error != NULL) {
					NSDictionary *userInfo = @{
						NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert JSON dictionary to model object", @""),
						NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSDictionary, got: %@", @""), JSONDictionary],
						MTLTransformerErrorHandlingInputValueErrorKey : JSONDictionary
					};
					
					*error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
				}
				*success = NO;
				return nil;
			}

			if (!adapter) {
				adapter = [[self alloc] initWithModelClass:modelClass];
			}
			id model = [adapter modelFromJSONDictionary:JSONDictionary error:error];
			if (model == nil) {
				*success = NO;
			}

			return model;
		}
		reverseBlock:^ NSDictionary * (id model, BOOL *success, NSError **error) {
			if (model == nil) return nil;
			
			if (![model conformsToProtocol:@protocol(MTLModel)] || ![model conformsToProtocol:@protocol(MTLJSONSerializing)]) {
				if (error != NULL) {
					NSDictionary *userInfo = @{
						NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert model object to JSON dictionary", @""),
						NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected a MTLModel object conforming to <MTLJSONSerializing>, got: %@.", @""), model],
						MTLTransformerErrorHandlingInputValueErrorKey : model
					};
					
					*error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
				}
				*success = NO;
				return nil;
			}

			if (!adapter) {
				adapter = [[self alloc] initWithModelClass:modelClass];
			}
			NSDictionary *result = [adapter JSONDictionaryFromModel:model error:error];
			if (result == nil) {
				*success = NO;
			}

			return result;
		}];
}

+ (NSValueTransformer<MTLTransformerErrorHandling> *)arrayTransformerWithModelClass:(Class)modelClass {
	id<MTLTransformerErrorHandling> dictionaryTransformer = [self dictionaryTransformerWithModelClass:modelClass];
	
	return [MTLValueTransformer
		transformerUsingForwardBlock:^ id (NSArray *dictionaries, BOOL *success, NSError **error) {
			if (dictionaries == nil) return nil;
			
			if (![dictionaries isKindOfClass:NSArray.class]) {
				if (error != NULL) {
					NSDictionary *userInfo = @{
						NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert JSON array to model array", @""),
						NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSArray, got: %@.", @""), dictionaries],
						MTLTransformerErrorHandlingInputValueErrorKey : dictionaries
					};
					
					*error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
				}
				*success = NO;
				return nil;
			}
			
			NSMutableArray *models = [NSMutableArray arrayWithCapacity:dictionaries.count];
			for (id JSONDictionary in dictionaries) {
				if (JSONDictionary == NSNull.null) {
					[models addObject:NSNull.null];
					continue;
				}
				
				if (![JSONDictionary isKindOfClass:NSDictionary.class]) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
							NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert JSON array to model array", @""),
							NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSDictionary or an NSNull, got: %@.", @""), JSONDictionary],
							MTLTransformerErrorHandlingInputValueErrorKey : JSONDictionary
						};
						
						*error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
					}
					*success = NO;
					return nil;
				}
				
				id model = [dictionaryTransformer transformedValue:JSONDictionary success:success error:error];
				
				if (*success == NO) return nil;
				
				if (model == nil) continue;
				
				[models addObject:model];
			}
			
			return models;
		}
		reverseBlock:^ id (NSArray *models, BOOL *success, NSError **error) {
			if (models == nil) return nil;
			
			if (![models isKindOfClass:NSArray.class]) {
				if (error != NULL) {
					NSDictionary *userInfo = @{
						NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert model array to JSON array", @""),
						NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an NSArray, got: %@.", @""), models],
						MTLTransformerErrorHandlingInputValueErrorKey : models
					};
					
					*error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
				}
				*success = NO;
				return nil;
			}
			
			NSMutableArray *dictionaries = [NSMutableArray arrayWithCapacity:models.count];
			for (id model in models) {
				if (model == NSNull.null) {
					[dictionaries addObject:NSNull.null];
					continue;
				}
				
				if (![model isKindOfClass:MTLModel.class]) {
					if (error != NULL) {
						NSDictionary *userInfo = @{
							NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert JSON array to model array", @""),
							NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected a MTLModel or an NSNull, got: %@.", @""), model],
							MTLTransformerErrorHandlingInputValueErrorKey : model
						};
						
						*error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
					}
					*success = NO;
					return nil;
				}
				
				NSDictionary *dict = [dictionaryTransformer reverseTransformedValue:model success:success error:error];
				
				if (*success == NO) return nil;
				
				if (dict == nil) continue;
				
				[dictionaries addObject:dict];
			}
			
			return dictionaries;
		}];
}

+ (NSValueTransformer *)NSURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)NSUUIDJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLUUIDValueTransformerName];
}

@end

@implementation MTLJSONAdapter (Deprecated)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

+ (NSArray *)JSONArrayFromModels:(NSArray *)models {
	return [self JSONArrayFromModels:models error:NULL];
}

+ (NSDictionary *)JSONDictionaryFromModel:(MTLModel<MTLJSONSerializing> *)model {
	return [self JSONDictionaryFromModel:model error:NULL];
}

#pragma clang diagnostic pop

@end
