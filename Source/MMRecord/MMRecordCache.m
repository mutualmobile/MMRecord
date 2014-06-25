// MMRecordCache.m
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


#import "MMRecordCache.h"
#import "MMRecordDebugger.h"

// This class contains a managed object context intended for use with caching records for a given request/response.
@interface MMRecordCacheDataManager : NSObject

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *globalObjectContext;

- (NSURL *)persistenceStoreURL;
+ (MMRecordCacheDataManager *)sharedInstance;
- (NSManagedObjectContext *)managedObjectContext;

@end


// This class represents an entry in the cache.
@interface MMRecordCacheEntry : NSManagedObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) id metadata;
@property (nonatomic, strong) NSOrderedSet *cacheObjects;

@end


// This class represents an object for a particular cache entry.
@interface MMRecordCacheObject : NSManagedObject

@property (nonatomic, strong) NSString *objectURL;
@property (nonatomic, strong) MMRecordCacheEntry *cacheEntry;

@end


@implementation MMRecordCache

+ (BOOL)hasResultsForKey:(NSString *)cacheKey {
    MMRecordCacheEntry *cacheEntry = [self fetchCacheEntryForKey:cacheKey];
    
    if (cacheEntry) {
        return YES;
    }
    
    return NO;
}

+ (void)getCachedResultsForRequest:(NSURLRequest *)request
                          cacheKey:(NSString *)cacheKey
                       metaKeyPath:(NSString *)metaKeyPath
                           context:(NSManagedObjectContext *)context
                  cacheResultBlock:(void(^)(NSArray *cachedResults, id responseObject))cacheResultBlock {    
    MMRecordCacheEntry *cacheEntry = [self fetchCacheEntryForKey:cacheKey];
    
    if (cacheEntry != nil) {        
        NSURLRequest *baseRequest = request;
        
        NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:baseRequest];;
        
        // Cache hit!
        if (cachedResponse != nil) {
            [self completeRequestForCachedResultsForCacheEntry:cacheEntry
                                                cachedResponse:cachedResponse
                                                   metaKeyPath:metaKeyPath
                                                       context:context
                                              cacheResultBlock:cacheResultBlock];
        } else {
            [self deleteCacheEntryForKey:cacheKey];
        }
    }
}

+ (void)completeRequestForCachedResultsForCacheEntry:(MMRecordCacheEntry *)cacheEntry
                                      cachedResponse:(NSCachedURLResponse *)cachedResponse
                                         metaKeyPath:(NSString *)metaKeyPath
                                             context:(NSManagedObjectContext *)context
                                    cacheResultBlock:(void(^)(NSArray *cachedResults, id responseObject))cacheResultBlock {
    NSArray *cachedResults = [self fetchRecordsWithCacheEntry:cacheEntry
                                                     sortedBy:nil
                                                    ascending:NO
                                                    inContext:context];
    
    id customResponseObject = [self customResponseObjectForCacheEntry:cacheEntry
                                                       cachedResponse:cachedResponse
                                                          metaKeyPath:metaKeyPath];
    
    if (cacheResultBlock != nil) {
        cacheResultBlock(cachedResults, customResponseObject);
    }
}

+ (id)customResponseObjectForCacheEntry:(MMRecordCacheEntry *)cacheEntry
                         cachedResponse:(NSCachedURLResponse *)cachedResponse
                            metaKeyPath:(NSString *)metaKeyPath {
    NSDictionary *customResponseObject = nil;
    
    if (cacheEntry.metadata != nil) {           // If we are shortcuting the response object...
        customResponseObject = @{metaKeyPath : cacheEntry.metadata, };
    } else if (cachedResponse.data != nil) {    // If the cached url response has a response body.
        NSError *error = nil;
        
        customResponseObject = [NSJSONSerialization JSONObjectWithData:cachedResponse.data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    }
    
    return customResponseObject;
}

+ (void)cacheRecords:(NSArray *)records
        withMetadata:(NSDictionary *)metadata
              forKey:(NSString *)key
         fromContext:(NSManagedObjectContext *)context {
    NSManagedObject *anyRecord = records.lastObject;
    
    if (anyRecord.objectID.isTemporaryID) {
        NSError *error = nil;
        
        [context obtainPermanentIDsForObjects:records
                                        error:&error];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self deleteCacheEntryForKey:key];
        
        NSManagedObjectContext *cacheContext = [[MMRecordCacheDataManager sharedInstance] managedObjectContext];
        
        MMRecordCacheEntry *cacheEntry = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([MMRecordCacheEntry class])
                                                                       inManagedObjectContext:cacheContext];
        cacheEntry.key = key;
        cacheEntry.metadata = metadata;

        for (NSManagedObject *record in records) {
            [self insertCacheObjectWithRecord:record intoContext:cacheContext cacheEntry:cacheEntry];
        }
        
        [cacheContext performBlock:^{
            [cacheContext save:NULL];
        }];
    });
}

+ (void)insertCacheObjectWithRecord:(NSManagedObject *)record
                        intoContext:(NSManagedObjectContext *)context
                         cacheEntry:(MMRecordCacheEntry *)cacheEntry {
    MMRecordCacheObject *cacheObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([MMRecordCacheObject class])
                                                                     inManagedObjectContext:context];
    cacheObject.objectURL = [[[record objectID] URIRepresentation] absoluteString];
    cacheObject.cacheEntry = cacheEntry;
}

+ (void)deleteCacheEntryForKey:(NSString *)key {
    NSManagedObjectContext *mmContext = [[MMRecordCacheDataManager sharedInstance] managedObjectContext];
    
    MMRecordCacheEntry *cacheEntry = [self fetchCacheEntryForKey:key];
    
    if (cacheEntry != nil) {
        [mmContext performBlock:^{
            [mmContext deleteObject:cacheEntry];
        }];
    }
}

+ (NSPredicate *)buildRecordPredicateWithCacheObjects:(NSArray *)cacheObjects
                                            inContext:(NSManagedObjectContext *)context {
    NSMutableArray *objectIDs = [NSMutableArray array];
    
    for (MMRecordCacheObject *cacheObject in cacheObjects) {
        NSURL *url = [NSURL URLWithString:cacheObject.objectURL];
        
        NSManagedObjectID *objectID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:url];
        
        if (objectID != nil) {
            [objectIDs addObject:objectID];
        }
    }
    
    return [NSPredicate predicateWithFormat:@"self IN %@", objectIDs];
}

+ (MMRecordCacheEntry *)fetchCacheEntryForKey:(NSString *)key {
    NSManagedObjectContext *mmContext = [[MMRecordCacheDataManager sharedInstance] managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([MMRecordCacheEntry class])
                                              inManagedObjectContext:mmContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    request.predicate = [NSPredicate predicateWithFormat:@"self.key = %@", key];
    
    __block NSArray *results = nil;
    [mmContext performBlockAndWait:^{
        NSError *error = nil;
        results = [mmContext executeFetchRequest:request error:&error];
    }];
    
    return [results lastObject];
}

+ (NSArray *)fetchRecordsWithKey:(NSString *)key
                       inContext:(NSManagedObjectContext *)context {
    return [self fetchRecordsWithKey:key
                            sortedBy:nil
                           ascending:NO
                           inContext:context];
}

+ (NSArray *)fetchRecordsWithKey:(NSString *)key
                        sortedBy:(NSString *)sortTerm
                       ascending:(BOOL)ascending
                       inContext:(NSManagedObjectContext *)context {
    MMRecordCacheEntry *cacheEntry = [self fetchCacheEntryForKey:key];
    
    return [self fetchRecordsWithCacheEntry:cacheEntry
                                   sortedBy:sortTerm
                                  ascending:ascending
                                  inContext:context];
}

+ (NSArray *)fetchRecordsWithCacheEntry:(MMRecordCacheEntry *)cacheEntry
                               sortedBy:(NSString *)sortTerm
                              ascending:(BOOL)ascending
                              inContext:(NSManagedObjectContext *)context {
    NSArray *results = nil;
    
    if (cacheEntry != nil) {
        results = [self resultsFromCacheEntry:cacheEntry
                                     sortedBy:sortTerm
                                    ascending:ascending
                                    inContext:context];
    }
    
    if (results != nil) {
        results = [self resultsSortedInOriginalCachedOrderFromResults:results
                                                           cacheEntry:cacheEntry];
    }
    
    return results;
}

+ (NSArray *)resultsFromCacheEntry:(MMRecordCacheEntry *)cacheEntry
                          sortedBy:(NSString *)sortTerm
                         ascending:(BOOL)ascending
                         inContext:(NSManagedObjectContext *)context {
    NSArray *results = nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    request.predicate = [self buildRecordPredicateWithCacheObjects:[cacheEntry.cacheObjects array]
                                                         inContext:context];
    
    if (sortTerm.length > 0) {
        NSSortDescriptor *sortBy = [[NSSortDescriptor alloc] initWithKey:sortTerm ascending:ascending];
        request.sortDescriptors = @[sortBy];
    }
    
    NSError *error = nil;
    
    results = [context executeFetchRequest:request error:&error];
    
    return results;
}

+ (NSArray *)resultsSortedInOriginalCachedOrderFromResults:(NSArray *)results
                                                cacheEntry:(MMRecordCacheEntry *)cacheEntry {
    NSMutableDictionary *recordCache = [NSMutableDictionary dictionaryWithCapacity:results.count];
    
    for (NSManagedObject *record in results) {
        [recordCache setObject:record forKey:[[[record objectID] URIRepresentation] absoluteString]];
    }
    
    NSMutableArray *orderedResults = [NSMutableArray arrayWithCapacity:results.count];
    
    for (MMRecordCacheObject *cacheObject in cacheEntry.cacheObjects) {
        NSManagedObject *record = [recordCache objectForKey:cacheObject.objectURL];
        if (record != nil) {
            [orderedResults addObject:record];
        }
    }
    
    return orderedResults;
}

@end


#pragma mark - MMRecordCacheDataManager

// This class contains a managed object context intended for use with caching records for a given request/response.
@implementation MMRecordCacheDataManager

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    _managedObjectModel = [[NSManagedObjectModel alloc] init];
    
    // MMRecordCacheEntry
    NSEntityDescription *cacheEntryEntity = [[NSEntityDescription alloc] init];
    cacheEntryEntity.name = @"MMRecordCacheEntry";
    cacheEntryEntity.managedObjectClassName = @"MMRecordCacheEntry";
    
    NSAttributeDescription *keyAttribute = [[NSAttributeDescription alloc] init];
    keyAttribute.name = @"key";
    keyAttribute.attributeType = NSStringAttributeType;
    [keyAttribute setOptional:NO];
    [keyAttribute setIndexed:YES];
    
    NSAttributeDescription *metadataAttribute = [[NSAttributeDescription alloc] init];
    metadataAttribute.name = @"metadata";
    metadataAttribute.attributeType = NSTransformableAttributeType;
    [metadataAttribute setIndexed:NO];
    
    // MMRecordCacheObject
    NSEntityDescription *cacheObjectEntity = [[NSEntityDescription alloc] init];
    cacheObjectEntity.name = @"MMRecordCacheObject";
    cacheObjectEntity.managedObjectClassName = @"MMRecordCacheObject";
    
    NSAttributeDescription *objectURLEntity = [[NSAttributeDescription alloc] init];
    objectURLEntity.name = @"objectURL";
    objectURLEntity.attributeType = NSStringAttributeType;
    [objectURLEntity setOptional:NO];
    [objectURLEntity setIndexed:NO];
    
    // MMRecordCacheEntry Relationships
    NSRelationshipDescription *cacheObjectsRelationship = [[NSRelationshipDescription alloc] init];
    cacheObjectsRelationship.name = @"cacheObjects";
    cacheObjectsRelationship.destinationEntity = cacheObjectEntity;
    [cacheObjectsRelationship setOptional:YES];
    [cacheObjectsRelationship setOrdered:YES];
    cacheObjectsRelationship.maxCount = 10000;
    
    // MMRecordCacheObject Relationships
    NSRelationshipDescription *cacheEntryRelationship = [[NSRelationshipDescription alloc] init];
    cacheEntryRelationship.name = @"cacheEntry";
    cacheEntryRelationship.destinationEntity = cacheEntryEntity;
    cacheEntryRelationship.maxCount = 1;
    cacheEntryRelationship.minCount = 1;
    [cacheEntryRelationship setOptional:YES];
    
    cacheEntryRelationship.inverseRelationship = cacheObjectsRelationship;
    cacheObjectsRelationship.inverseRelationship = cacheEntryRelationship;
    
    [cacheEntryEntity setProperties:[NSArray arrayWithObjects:keyAttribute, metadataAttribute, cacheObjectsRelationship, nil]];
    [cacheObjectEntity setProperties:[NSArray arrayWithObjects:objectURLEntity, cacheEntryRelationship, nil]];
    
    [_managedObjectModel setEntities:[NSArray arrayWithObjects:cacheEntryEntity, cacheObjectEntity, nil]];
    
    return _managedObjectModel;
}

- (NSURL *)urlForFileRelativeToApplicationSupport:(NSString *)relativePath {
    NSError *error = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appSupportDirectory = [paths objectAtIndex:0];
    
    NSString *executableName =
    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    
    NSString *path = [appSupportDirectory stringByAppendingPathComponent:executableName];
    path = [path stringByAppendingPathComponent:relativePath];
    NSString *parentPath = [path stringByDeletingLastPathComponent];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:parentPath] == NO) {
        if ([fileManager createDirectoryAtPath:parentPath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:&error]) {
            
        } else {
            //MMRLogError(@"Unable to find or create application support directory:\n%@", error);
            url = nil;
        }
    }
    
    return url;
}

- (NSURL *)persistenceStoreURL {
    NSURL *storePath = [self urlForFileRelativeToApplicationSupport:@"mmcache/MMRecordCache.store"];
    return storePath;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *model = [self managedObjectModel];
    if (model == nil) {
        //MMRLogError(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSURL *url = [self persistenceStoreURL];
    NSError *error = nil;
    
    NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                         configuration:nil
                                                                                   URL:url
                                                                               options:nil
                                                                                 error:&error];
    if (store == nil) {
        //MMRLogError(@"Failed to create MMRecord internal persistence store: %@", error);
    }
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (!coordinator) {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
//        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
//        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
//        MMRLogError(@"%@", error);
        return nil;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc]
                             initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    [_managedObjectContext setUndoManager:nil];
    
    return _managedObjectContext;
}

#pragma mark - Singleton Methods

static dispatch_once_t predicate_;
static MMRecordCacheDataManager *sharedInstance_ = nil;

+ (id)sharedInstance {
    
    dispatch_once(&predicate_, ^{
        sharedInstance_ = [MMRecordCacheDataManager alloc];
        sharedInstance_ = [sharedInstance_ init];
    });
    
    return sharedInstance_;
}

@end


// This class represents an entry in the cache.
@implementation MMRecordCacheEntry

@dynamic key;
@dynamic metadata;
@dynamic cacheObjects;

@end


// This class represents an object for a particular cache entry.
@implementation MMRecordCacheObject

@dynamic objectURL;
@dynamic cacheEntry;

@end

#undef MMRLogInfo
#undef MMRLogWarn
#undef MMRLogError
#undef MMRLogVerbose