// MMRecordResponseSerializer.m
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

#import "MMRecordResponseSerializer.h"

#import "MMRecord.h"
#import "MMRecordResponse.h"

@interface MMRecordResponseSerializer ()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *context;
@property (nonatomic, strong, readwrite) AFHTTPResponseSerializer *HTTPResponseSerializer;

@end

@implementation MMRecordResponseSerializer

+ (instancetype)serializerWithManagedObjectContext:(NSManagedObjectContext *)context
                            HTTPResponseSerializer:(AFHTTPResponseSerializer *)HTTPResponseSerializer{
    MMRecordResponseSerializer *serializer = [[self alloc] init];
    serializer.context = context;
    serializer.HTTPResponseSerializer = HTTPResponseSerializer;

    return serializer;
}


#pragma mark - Private

- (NSArray *)responseArrayFromResponseObject:(id)responseObject
                               initialEntity:(NSEntityDescription *)initialEntity {
    Class managedObjectClass = NSClassFromString([initialEntity managedObjectClassName]);
    
    NSString *keyPath = [managedObjectClass keyPathForResponseObject];
    
    NSArray *responseArray = [responseObject valueForKeyPath:keyPath];
    
    if ([responseArray isKindOfClass:[NSArray class]] == NO) {
        responseArray = @[responseArray];
    }
    
    return responseArray;
}

- (NSManagedObjectContext *)backgroundContext {
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
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
    NSError *serializationError = nil;
    
    id responseObject = [self.HTTPResponseSerializer responseObjectForResponse:response
                                                                          data:data
                                                                         error:&serializationError];
    
    NSEntityDescription *initialEntity = [self entityForResponse:response
                                                  responseObject:responseObject];
    
    NSArray *responseArray = [self responseArrayFromResponseObject:responseObject
                                                     initialEntity:initialEntity];
    
    NSManagedObjectContext *backgroundContext = [self backgroundContext];
    
    MMRecordResponse *recordResponse = [MMRecordResponse responseFromResponseObjectArray:responseArray
                                                                     initialEntity:initialEntity
                                                                           context:self.context];
    
    NSArray *records = [self recordsFromMMRecordResponse:recordResponse
                                       backgroundContext:backgroundContext];
    
    return records;
}


#pragma mark - MMRecordResponseSeralizer

- (NSEntityDescription *)entityForResponse:(NSURLResponse *)response
                            responseObject:(id)responseObject {
    return nil;
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
    MMRecordResponseSerializer *serializer = [[MMRecordResponseSerializer alloc] init];
    serializer.context = self.context;
    serializer.HTTPResponseSerializer = self.HTTPResponseSerializer;
    return serializer;
}

@end
