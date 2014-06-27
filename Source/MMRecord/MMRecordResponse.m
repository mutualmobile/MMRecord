// MMRecordResponse.m
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

#import "MMRecordResponse.h"

#import "MMRecordMarshaler.h"
#import "MMRecordRepresentation.h"
#import "MMRecordProtoRecord.h"

/* This class contains the proto records from the response which are of a given entity type.  This
 class is used to contain all of the proto records that represent all the actual records in a response
 for that type.  If a MMRecordResponse only contains records of a given type, it should only create
 one instance of MMRecordResponseGroup, and place all of those proto records into that group.  The
 group class also has methods for adding new protos to the group, retreiving protos.  It is also the
 starting point for populating proto records contained by the group.
 */
@interface MMRecordResponseGroup : NSObject

@property (nonatomic, strong) NSEntityDescription *entity;
@property (nonatomic, strong) NSMutableSet *protoRecords;
@property (nonatomic, strong) NSMutableDictionary *prototypeDictionary;
@property (nonatomic, strong) MMRecordRepresentation *representation;
@property (nonatomic) BOOL hasRelationshipPrimaryKey;
@property (nonatomic, copy) MMRecordOptionsRecordPrePopulationBlock recordPrePopulationBlock;
@property (nonatomic, strong) MMRecordDebugger *debugger;

- (instancetype)initWithEntity:(NSEntityDescription *)entity;

- (void)addProtoRecord:(MMRecordProtoRecord *)protoRecord;

- (void)addProtoRecordToDictionary:(MMRecordProtoRecord *)protoRecord;

- (MMRecordProtoRecord *)protoRecordForPrimaryKeyValue:(id)primaryKeyValue;

// Will attempt to obtain a record for each proto record using every method possible.
- (void)obtainRecordsForProtoRecordsInContext:(NSManagedObjectContext *)context;

// Populate the record for each proto record
- (void)populateAllRecords;

// Link everything together
- (void)establishRelationshipsForAllRecords;

@end


@interface MMRecordResponse ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSEntityDescription *initialEntity;
@property (nonatomic, copy) NSArray *responseObjectArray;
@property (nonatomic, strong) MMRecordOptions *options;
@property (nonatomic, strong) NSMutableArray *objectGraph;  // Array of Protos
@property (nonatomic, strong) NSMutableDictionary *responseGroups;  // Key = NSEntityDescription, Value = MMRecordResponseGroup
@end


#pragma mark - MMRecordResponse

@implementation MMRecordResponse

+ (MMRecordResponse *)responseFromResponseObjectArray:(NSArray *)responseObjectArray
                                        initialEntity:(NSEntityDescription *)initialEntity
                                              context:(NSManagedObjectContext *)context
                                              options:(MMRecordOptions *)options {
    MMRecordResponse *response = [[MMRecordResponse alloc] init];
    response.context = context;
    response.initialEntity = initialEntity;
    response.responseObjectArray = responseObjectArray;
    response.options = options;
    
    return response;
}


#pragma mark - Record Parsing

- (NSArray *)records {
    // Step 0: Build Proto Records and Response Groups
    [self buildProtoRecordsAndResponseGroups];
    
    // Step 1: Obtain Records (Fetch, Associate, Create)
    for (MMRecordResponseGroup *responseGroup in [self.responseGroups allValues]) {
        [responseGroup obtainRecordsForProtoRecordsInContext:self.context];
    }
    
    // Step 2: Populate Records
    for (MMRecordResponseGroup *responseGroup in [self.responseGroups allValues]) {
        [responseGroup populateAllRecords];
    }
    
    // Step 3: Establish Relationships
    for (MMRecordResponseGroup *responseGroup in [self.responseGroups allValues]) {
        [responseGroup establishRelationshipsForAllRecords];
    }
    
    // Step 4: Profit!
    NSArray *records = [self recordsFromObjectGraph];
    return records;
}

- (NSArray *)recordsFromObjectGraph {
    NSMutableArray *records = [NSMutableArray array];
    
    for (MMRecordProtoRecord *protoRecord in self.objectGraph) {
        [records addObject:protoRecord.record];
    }
    
    return records;
}


#pragma mark - Logging

- (void)logObjectGraph {
    [self.options.debugger logMessageWithDescription:[NSString stringWithFormat:@"%@", self.objectGraph]
                                 minimumLoggingLevel:MMRecordLoggingLevelNone];
}


#pragma mark - Building Response Groups

- (MMRecordResponseGroup *)responseGroupForEntity:(NSEntityDescription *)entity
                       fromExistingResponseGroups:(NSMutableDictionary *)responseGroups {
    NSString *entityDescriptionsKey = [entity managedObjectClassName];
    MMRecordResponseGroup *responseGroup = responseGroups[entityDescriptionsKey];
    
    if (responseGroup == nil) {
        if ([NSClassFromString([entity managedObjectClassName]) isSubclassOfClass:[MMRecord class]]) {
            responseGroup = [[MMRecordResponseGroup alloc] initWithEntity:entity];
            responseGroup.recordPrePopulationBlock = self.options.recordPrePopulationBlock;
            responseGroup.debugger = self.options.debugger;
            responseGroups[entityDescriptionsKey] = responseGroup;
        } else {
            return nil;
        }
    }
    
    return responseGroup;
}

- (void)uniquelyAddNewProtoRecord:(MMRecordProtoRecord *)protoRecord
         toExistingResponseGroups:(NSMutableDictionary *)responseGroups {
    MMRecordResponseGroup *responseGroup = [self responseGroupForEntity:protoRecord.entity
                                             fromExistingResponseGroups:responseGroups];
    
    [responseGroup addProtoRecord:protoRecord];
}

#pragma mark - Determine Entity subclass to use

- (NSEntityDescription *)subEntityForRecordResponseObject:(id)object
                                        withInitialEntity:(NSEntityDescription *)initialEntity {
    NSArray *subEntities = initialEntity.subentities;

    for (NSEntityDescription *subEntity in subEntities) {
        Class subEntityClass = NSClassFromString([subEntity managedObjectClassName]);

        if ([subEntityClass respondsToSelector:@selector(shouldUseSubEntityRecordClassToRepresentData:)]) {
            if ([subEntityClass shouldUseSubEntityRecordClassToRepresentData:object]) {
                return [self subEntityForRecordResponseObject:object
                                            withInitialEntity:subEntity];
            }
        }
    }
    
    return initialEntity;
}

#pragma mark - Building Proto Records

- (void)buildProtoRecordsAndResponseGroups {
    NSMutableDictionary *responseGroups = [NSMutableDictionary dictionary];
    NSMutableArray *objectGraph = [NSMutableArray array];
    

    for (id recordResponseObject in self.responseObjectArray) {
        NSEntityDescription *entity = [self subEntityForRecordResponseObject:recordResponseObject
                                                           withInitialEntity:self.initialEntity];
        
        MMRecordProtoRecord *proto = [self protoRecordWithRecordResponseObject:recordResponseObject
                                                                        entity:entity
                                                        existingResponseGroups:responseGroups
                                                             parentProtoRecord:nil];
        
        [objectGraph addObject:proto];
    }
    
    self.objectGraph = objectGraph;
    self.responseGroups = responseGroups;
    
    [self logObjectGraph];
}

- (MMRecordProtoRecord *)protoRecordWithRecordResponseObject:(id)recordResponseObject
                                                      entity:(NSEntityDescription *)entity
                                      existingResponseGroups:(NSMutableDictionary *)responseGroups
                                           parentProtoRecord:(MMRecordProtoRecord *)parentProtoRecord {
    MMRecordResponseGroup *recordResponseGroup = [self responseGroupForEntity:entity
                                                   fromExistingResponseGroups:responseGroups];
    MMRecordRepresentation *representation = recordResponseGroup.representation;
    
    if ([recordResponseObject isKindOfClass:[NSDictionary class]] == NO && representation.primaryKeyPropertyName != nil) {
        recordResponseObject = @{representation.primaryKeyPropertyName : recordResponseObject};
    }
    
    id primaryValue = [representation primaryKeyValueFromDictionary:recordResponseObject];
    MMRecordProtoRecord *proto = [recordResponseGroup protoRecordForPrimaryKeyValue:primaryValue];
    
    if (proto == nil) {
        proto = [MMRecordProtoRecord protoRecordWithDictionary:recordResponseObject
                                                        entity:entity
                                                representation:representation];
        
        
        if (proto.hasRelationshipPrimarykey == NO) {
            if (proto.primaryKeyValue == nil) {
                if (self.options.entityPrimaryKeyInjectionBlock != nil) {
                    proto.primaryKeyValue = self.options.entityPrimaryKeyInjectionBlock(proto.entity,
                                                                                        proto.dictionary,
                                                                                        parentProtoRecord);
                }
            }
            
            if (proto.primaryKeyValue == nil) {
                MMRecordDebugger *debugger = self.options.debugger;
                NSString *errorDescription = [NSString stringWithFormat:@"Creating proto record with no primary key value. \"%@\"", proto];
                NSDictionary *parameters = [debugger parametersWithKeys:@[MMRecordDebuggerParameterRecordClassName,
                                                                          MMRecordDebuggerParameterErrorDescription,
                                                                          MMRecordDebuggerParameterEntityDescription]
                                                                 values:@[proto.entity.managedObjectClassName,
                                                                          errorDescription,
                                                                          proto.entity]];
                [debugger handleErrorCode:MMRecordErrorCodeMissingRecordPrimaryKey withParameters:parameters];
            }
        }
    } else {
        [representation.marshalerClass mergeDuplicateRecordResponseObjectDictionary:recordResponseObject
                                                            withExistingProtoRecord:proto];
    }
    
    [self uniquelyAddNewProtoRecord:proto toExistingResponseGroups:responseGroups];
    
    if (proto) {
        [self completeRelationshipProtoRecordMappingToProtoRecord:proto
                                           existingResponseGroups:responseGroups
                                                   representation:representation];
        
        [recordResponseGroup addProtoRecordToDictionary:proto];
    }
    
    return proto;
}

- (void)completeRelationshipProtoRecordMappingToProtoRecord:(MMRecordProtoRecord *)protoRecord
                                     existingResponseGroups:(NSMutableDictionary *)responseGroups
                                             representation:(MMRecordRepresentation *)representation {
    NSArray *relationshipDescriptions = representation.relationshipDescriptions;
    
    for (NSRelationshipDescription *relationshipDescription in relationshipDescriptions) {
        [self addRelationshipProtoRecordsToProtoRecord:protoRecord
                                existingResponseGroups:responseGroups
                                        representation:representation
                               relationshipDescription:relationshipDescription];
    }
}

- (void)addRelationshipProtoRecordsToProtoRecord:(MMRecordProtoRecord *)protoRecord
                          existingResponseGroups:(NSMutableDictionary *)responseGroups
                                  representation:(MMRecordRepresentation *)representation
                         relationshipDescription:(NSRelationshipDescription *)relationshipDescription {
    NSDictionary *dictionary = protoRecord.dictionary;
    NSEntityDescription *entity = [relationshipDescription destinationEntity];
    MMRecordResponseGroup *responseGroup = [self responseGroupForEntity:entity
                                             fromExistingResponseGroups:responseGroups];
    
    if (responseGroup != nil) {
        NSArray *keyPaths = [representation keyPathsForMappingRelationshipDescription:relationshipDescription];
        id relationshipObject = [self relationshipObjectFromDictionary:dictionary
                                                          fromKeyPaths:keyPaths
                                                         responseGroup:responseGroup];
        
        if (relationshipObject) {
            if ([relationshipObject isKindOfClass:[NSArray class]] == NO) {
                relationshipObject = @[relationshipObject];
            }
            
            for (id object in relationshipObject) {
                NSEntityDescription *recordSubEntity = [self subEntityForRecordResponseObject:object
                                                                            withInitialEntity:entity];
                
                MMRecordProtoRecord *relationshipProto = [self protoRecordWithRecordResponseObject:object
                                                                                            entity:recordSubEntity
                                                                            existingResponseGroups:responseGroups
                                                                                 parentProtoRecord:protoRecord];
                
                // By keeping the above section of code outside the conditional we can gaurantee that
                // the protoRecord generation/parsing method above gets called for every relationship
                // proto, which also causes the optional merge code to be run for all possible updated
                // relationship protos.
                if ([protoRecord canAccomodateAdditionalProtoRecordForRelationshipDescription:relationshipDescription]) {
                    [protoRecord addRelationshipProto:relationshipProto
                           forRelationshipDescription:relationshipDescription];
                }
            }
        }
    }
}

- (id)relationshipObjectFromDictionary:(NSDictionary *)dictionary
                          fromKeyPaths:(NSArray *)keyPaths
                         responseGroup:(MMRecordResponseGroup *)responseGroup {
    id relationshipObject = nil;
    
    for (NSString *keyPath in keyPaths) {
        relationshipObject = [dictionary valueForKeyPath:keyPath];
        if (relationshipObject == [NSNull null]) {
            relationshipObject = nil;
        }
        
        if (relationshipObject) {
            if (([relationshipObject isKindOfClass:[NSDictionary class]] == NO) &&
                ([relationshipObject isKindOfClass:[NSArray class]] == NO)) {
                id primaryKey = [[responseGroup representation] primaryKeyPropertyName];
                
                if (primaryKey) {
                    relationshipObject = @{primaryKey : relationshipObject};
                } else {
                    relationshipObject = nil;
                }
            }
            
            break;
        }
    }
    
    return relationshipObject;
}

@end


#pragma mark - MMRecordResponseGroup

@implementation MMRecordResponseGroup

- (id)initWithEntity:(NSEntityDescription *)entity {
    if (self = [super init]) {
        NSParameterAssert([NSClassFromString([entity managedObjectClassName]) isSubclassOfClass:[MMRecord class]]);
        _entity = entity;
        _protoRecords = [NSMutableSet set];
        
        Class MMRecordClass = NSClassFromString([entity managedObjectClassName]);
        Class MMRecordRepresentationClass = [MMRecordClass representationClass];
        
        _representation = [[MMRecordRepresentationClass alloc] initWithEntity:entity];
        _hasRelationshipPrimaryKey = [_representation hasRelationshipPrimaryKey];
        _prototypeDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addProtoRecord:(MMRecordProtoRecord *)protoRecord {
    if ([self.prototypeDictionary objectForKey:protoRecord.primaryKeyValue] == nil) {
        [self.protoRecords addObject:protoRecord];
    }
}

- (void)addProtoRecordToDictionary:(MMRecordProtoRecord *)protoRecord {
    if (protoRecord.primaryKeyValue) {
        self.prototypeDictionary[protoRecord.primaryKeyValue] = protoRecord;
    }
}


#pragma mark - Accessors

- (MMRecordProtoRecord *)protoRecordForPrimaryKeyValue:(id)primaryKeyValue {
    return [self.prototypeDictionary objectForKey:primaryKeyValue];
}


#pragma mark - Record Building

- (void)obtainRecordsForProtoRecordsInContext:(NSManagedObjectContext *)context {
    // Phase 1: Fetch
    [self performFetchForAllRecordsAndAssociateWithProtosInContext:context];
    
    // Phase 2: Wonky Stuff with Relationship Primary Keys
    [self associateRelationshipPrimaryKeyRecordProtosIfNecesary];
    
    // Phase 3: Create
    [self createRecordsForProtoRecordsWithMissingRecordsInContext:context];
}

- (void)establishRelationshipsForAllRecords {
    for (MMRecordProtoRecord *protoRecord in self.protoRecords) {
        [self.representation.marshalerClass establishRelationshipsOnProtoRecord:protoRecord];
    }
}

- (void)populateAllRecords {
    for (MMRecordProtoRecord *protoRecord in self.protoRecords) {
        if (self.recordPrePopulationBlock != nil) {
            self.recordPrePopulationBlock(protoRecord);
        }
        
        [self.representation.marshalerClass populateProtoRecord:protoRecord];
    }
}


#pragma mark - Association

- (void)associateRelationshipPrimaryKeyRecordProtosIfNecesary {
    // look at relationship proto records and if their representation involves a relationship primary
    // key, set their relationship primary key proto as this entity description's proto
    for (MMRecordProtoRecord *parentProtoRecord in self.protoRecords) {
        for (MMRecordProtoRecord *relationshipProto in parentProtoRecord.relationshipProtos) {
            if (relationshipProto.hasRelationshipPrimarykey) {
                [self.representation.marshalerClass establishPrimaryKeyRelationshipFromProtoRecord:relationshipProto
                                                         toParentRelationshipPrimaryKeyProtoRecord:parentProtoRecord];
            }
        }
    }
}


#pragma mark - Fetching

- (void)performFetchForAllRecordsAndAssociateWithProtosInContext:(NSManagedObjectContext *)context {
    NSMutableArray *allPrimaryKeys = [NSMutableArray array];
    
    for (MMRecordProtoRecord *protoRecord in self.protoRecords) {
        if (protoRecord.primaryKeyValue != nil && protoRecord.primaryKeyValue != [NSNull null]) {
            [allPrimaryKeys addObject:protoRecord.primaryKeyValue];
        }
    }
    
    NSArray *existingRecords = [self fetchRecordsWithPrimaryKeys:allPrimaryKeys forEntity:self.entity context:context];
    NSArray *sortedProtoRecords = [self sortedProtoRecordsByPrimaryKeyValueInAscendingOrder:[self.protoRecords allObjects]];
    
    NSMutableDictionary *existingRecordDictionary = [[NSMutableDictionary alloc] init];
    
    for (MMRecord *record in existingRecords) {
        if (record.primaryKeyValue != nil) {
            [existingRecordDictionary setObject:record forKey:record.primaryKeyValue];
        } else {
            MMRecordDebugger *debugger = self.debugger;
            NSString *errorDescription = [NSString stringWithFormat:@"Fetched record with no primary key value \"%@\"", record];
            NSDictionary *parameters = [debugger parametersWithKeys:@[MMRecordDebuggerParameterRecordClassName,
                                                                      MMRecordDebuggerParameterErrorDescription]
                                                             values:@[record.class,
                                                                      errorDescription]];
            [debugger handleErrorCode:MMRecordErrorCodeMissingRecordPrimaryKey withParameters:parameters];
        }
    }
    
    for (MMRecordProtoRecord *protoRecord in sortedProtoRecords) {
        id protoRecordPrimaryKeyValue = protoRecord.primaryKeyValue;
        
        protoRecord.record = [existingRecordDictionary objectForKey:protoRecordPrimaryKeyValue];
    }
}

- (NSComparisonResult)comparePrimaryKeyValues:(id)recordPrimaryKeyValue protoRecordPrimaryKeyValue:(id)protoRecordPrimaryKeyValue {
    // Default comparison result to descending since performFetch will treat this as a no-op
    NSComparisonResult comparisonResult = NSOrderedDescending;
    
    if ([recordPrimaryKeyValue isKindOfClass:[NSString class]]) {
        if ([protoRecordPrimaryKeyValue isKindOfClass:[NSString class]]) {
            comparisonResult = [recordPrimaryKeyValue compare:protoRecordPrimaryKeyValue];
        }
    } else if ([recordPrimaryKeyValue isKindOfClass:[NSNumber class]]) {
        if ([protoRecordPrimaryKeyValue isKindOfClass:[NSNumber class]]) {
            comparisonResult = [recordPrimaryKeyValue compare:protoRecordPrimaryKeyValue];
        }
    }
    
    return comparisonResult;
}

- (NSArray *)sortedProtoRecordsByPrimaryKeyValueInAscendingOrder:(NSArray *)protoRecords {
    return [protoRecords sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"primaryKeyValue" ascending:YES]]];
}

- (NSArray*)fetchRecordsWithPrimaryKeys:(NSArray *)primaryKeys forEntity:(NSEntityDescription*)entity context:(NSManagedObjectContext *)context {
    if (entity == nil) {
        return nil;
    }
    
    Class entityClass = NSClassFromString([entity managedObjectClassName]);
    
    NSArray *results = nil;
    
    if ([entityClass isSubclassOfClass:[MMRecord class]]) {
        NSDictionary *userInfo = [entity userInfo];
        NSString *primaryAttributeKey = [userInfo valueForKey:MMRecordEntityPrimaryAttributeKey];
        
        if (primaryAttributeKey == nil)
            return nil;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[entity name]];
        [fetchRequest setFetchBatchSize:20];
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:primaryAttributeKey ascending:YES]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat: @"SELF.%@ IN %@", primaryAttributeKey, primaryKeys];
        
        NSError *fetchError = nil;
        
        results = [context executeFetchRequest:fetchRequest error:&fetchError];
    }
    
    return results;
}


#pragma mark - Creation (Last Resort)

- (void)createRecordsForProtoRecordsWithMissingRecordsInContext:(NSManagedObjectContext *)context {
    for (MMRecordProtoRecord *protoRecord in self.protoRecords) {
        if (protoRecord.record == nil) {
            Class recordClass = NSClassFromString(self.entity.managedObjectClassName);
            MMRecord *record = [[recordClass alloc] initWithEntity:self.entity insertIntoManagedObjectContext:context];
            protoRecord.record = record;
            
            NSString *message = [NSString stringWithFormat:@"Created proto record \"%@\", value: \"%@\"", protoRecord.entity.name, protoRecord.primaryKeyValue];
            [self.debugger logMessageWithDescription:message minimumLoggingLevel:MMRecordLoggingLevelDebug];
        }
    }
}

@end

