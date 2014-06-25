// AFMMRecordResponseSerializer.m
//
// Copyright (c) 2013 Mutual Mobile (http://www.mutualmobile.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFMMRecordResponseSerializer.h"

#import "MMRecord.h"
#import "MMRecordResponse.h"

static MMRecordOptions* MM_responseSerializerRecordOptions;

NSString * const AFMMRecordResponseSerializerWithDataKey = @"AFMMRecordResponseSerializerWithDataKey";

@interface AFMMRecordResponseSerializer ()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) AFHTTPResponseSerializer *HTTPResponseSerializer;
@property (nonatomic, strong) id<AFMMRecordResponseSerializationEntityMapping> entityMapper;

@end

@implementation AFMMRecordResponseSerializer

+ (instancetype)serializerWithManagedObjectContext:(NSManagedObjectContext *)context
                          responseObjectSerializer:(AFHTTPResponseSerializer *)HTTPResponseSerializer
                                      entityMapper:(id<AFMMRecordResponseSerializationEntityMapping>)entityMapper {
    NSParameterAssert(context != nil);
    NSParameterAssert(HTTPResponseSerializer != nil);
    NSParameterAssert(entityMapper != nil);
    
    AFMMRecordResponseSerializer *serializer = [[self alloc] init];
    serializer.context = context;
    serializer.HTTPResponseSerializer = HTTPResponseSerializer;
    serializer.entityMapper = entityMapper;
    return serializer;
}

+ (void)registerOptions:(MMRecordOptions *)options {
    MM_responseSerializerRecordOptions = options;
}

+ (MMRecordOptions *)currentOptions {
    if (MM_responseSerializerRecordOptions != nil) {
        return MM_responseSerializerRecordOptions;
    }
    
    return nil;
}


#pragma mark - Private

+ (MMRecordOptions *)currentOptionsWithMMRecordSubclass:(Class)recordClass {
    if (MM_responseSerializerRecordOptions != nil) {
        return MM_responseSerializerRecordOptions;
    }
    
    MMRecordOptions *options = [recordClass defaultOptions];
    
    return options;
}

- (NSArray *)responseArrayFromResponseObject:(id)responseObject
                    keyPathForResponseObject:(NSString *)keyPathForResponseObject {
    id recordResponseObject = responseObject;
    
    if (keyPathForResponseObject != nil) {
        recordResponseObject = [responseObject valueForKeyPath:keyPathForResponseObject];
    } else {
        recordResponseObject = responseObject;
    }
    
    if (recordResponseObject == nil || [recordResponseObject isKindOfClass:[NSNull class]]) {
        recordResponseObject = [NSArray array];
    }
    
    if ([recordResponseObject isKindOfClass:[NSArray class]] == NO) {
        recordResponseObject = [NSArray arrayWithObject:recordResponseObject];
    }
    
    return recordResponseObject;
}

- (NSManagedObjectContext *)backgroundContext {
    NSManagedObjectContext *backgroundContext =
        [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundContext setPersistentStoreCoordinator:self.context.persistentStoreCoordinator];
    return backgroundContext;
}

- (NSArray *)recordsFromMMRecordResponse:(MMRecordResponse *)recordResponse
                       backgroundContext:(NSManagedObjectContext *)backgroundContext {
    __block NSMutableArray *objectIDs = [NSMutableArray array];
    
    [backgroundContext performBlockAndWait:^{
        NSArray *records = [recordResponse records];
        
        for (MMRecord *record in records) {
            [objectIDs addObject:[record objectID]];
        }
    }];
    
    NSMutableArray *records = [NSMutableArray array];
    
    for (NSManagedObjectID *objectID in objectIDs) {
        [records addObject:[self.context objectWithID:objectID]];
    }
    
    return records;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
    
    id responseObject = [self.HTTPResponseSerializer responseObjectForResponse:response
                                                                          data:data
                                                                         error:error];
    
    if (*error != nil) {
        NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
        NSString *responseData = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        
        [userInfo setValue:responseData
                    forKey:AFMMRecordResponseSerializerWithDataKey];
        
        NSError *newError = [NSError errorWithDomain:(*error).domain
                                                code:(*error).code
                                            userInfo:userInfo];
        (*error) = newError;
    }
    
    NSEntityDescription *initialEntity = [self.entityMapper recordResponseSerializer:self
                                                                   entityForResponse:response
                                                                      responseObject:responseObject
                                                                             context:self.context];
    
    Class managedObjectClass = NSClassFromString([initialEntity managedObjectClassName]);
    
    MMRecordOptions *options = [[self class] currentOptionsWithMMRecordSubclass:managedObjectClass];
    
    MMRecordDebugger *debugger = [[MMRecordDebugger alloc] init];
    options.debugger = debugger;
    
    // Verify that the server responded in an expected manner.
    if (!([responseObject isKindOfClass:[NSDictionary class]]) &&
        !([responseObject isKindOfClass:[NSArray class]])) {
        NSString *errorDescription = [NSString stringWithFormat:@"The response object should be an array or dictionary. The returned response object type was: %@", NSStringFromClass([responseObject class])];
        NSDictionary *parameters = [debugger parametersWithKeys:@[MMRecordDebuggerParameterErrorDescription] values:@[errorDescription]];
        
        [debugger handleErrorCode:MMRecordErrorCodeInvalidResponseFormat
                   withParameters:parameters];
        
        *error = [debugger primaryError];
        
        return nil;
    }
    
    NSString *keyPathForResponseObject = [options keyPathForResponseObject];

    NSArray *responseArray = [self responseArrayFromResponseObject:responseObject
                                          keyPathForResponseObject:keyPathForResponseObject];
    
    NSManagedObjectContext *backgroundContext = [self backgroundContext];
    
    MMRecordResponse *recordResponse = [MMRecordResponse responseFromResponseObjectArray:responseArray
                                                                           initialEntity:initialEntity
                                                                                 context:self.context
                                                                                 options:options];
    
    NSArray *records = [self recordsFromMMRecordResponse:recordResponse
                                       backgroundContext:backgroundContext];
    
    *error = [debugger primaryError];
    
    return records;
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    AFMMRecordResponseSerializer *serializer = [[AFMMRecordResponseSerializer alloc] init];
    serializer.context = self.context;
    serializer.HTTPResponseSerializer = self.HTTPResponseSerializer;
    return serializer;
}

@end
