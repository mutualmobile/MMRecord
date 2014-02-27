// MMRecordProtoRecord.m
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

#import "MMRecordProtoRecord.h"

#import "MMRecord.h"
#import "MMRecordRepresentation.h"

@interface MMRecordProtoRecord ()
 // Dictionary where key = relationship name and value = an NSMutableOrderedSet of proto records
@property (nonatomic, strong, readwrite) NSMutableDictionary *relationshipProtosDictionary;

 // Dictionary where key = relationship name and value = relationship description
@property (nonatomic, strong, readwrite) NSMutableDictionary *relationshipDescriptionsDictionary;
@property (nonatomic, strong) MMRecordRepresentation *representation;
@property (nonatomic, strong) NSEntityDescription *entity;
@end

@implementation MMRecordProtoRecord

+ (MMRecordProtoRecord *)protoRecordWithDictionary:(NSDictionary *)dictionary
                                            entity:(NSEntityDescription *)entity
                                    representation:(MMRecordRepresentation *)representation {
    NSParameterAssert([NSClassFromString([entity managedObjectClassName]) isSubclassOfClass:[MMRecord class]]);
    MMRecordProtoRecord *protoRecord = [[MMRecordProtoRecord alloc] init];
    protoRecord.dictionary = dictionary;
    protoRecord.entity = entity;
    protoRecord.primaryKeyValue = [representation primaryKeyValueFromDictionary:dictionary];
    protoRecord.relationshipProtosDictionary = [NSMutableDictionary dictionary];
    protoRecord.relationshipDescriptionsDictionary = [NSMutableDictionary dictionary];
    protoRecord.hasRelationshipPrimarykey = [representation hasRelationshipPrimaryKey];
    protoRecord.representation = representation;
    protoRecord.primaryAttributeDescription = [representation primaryAttributeDescription];
    
    return protoRecord;
}

- (NSArray *)relationshipProtos {
    NSMutableArray *allRelationshipProtos = [NSMutableArray array];
    
    for (NSOrderedSet *protoSet in [self.relationshipProtosDictionary allValues]) {
        [allRelationshipProtos addObjectsFromArray:[protoSet array]];
    }
    
    return allRelationshipProtos;
}

- (NSArray *)relationshipDescriptions {
    return [self.relationshipDescriptionsDictionary allValues];
}

- (NSArray *)relationshipProtoRecordsForRelationshipDescription:(NSRelationshipDescription *)relationshipDescription {
    NSString *relationshipName = [relationshipDescription name];

    NSArray *relationshipProtoRecords = nil;
    
    if (relationshipName != nil) {
        NSOrderedSet *protoSet = [self.relationshipProtosDictionary objectForKey:relationshipName];
        relationshipProtoRecords = [protoSet array];
    }
    
    return relationshipProtoRecords;
}

- (BOOL)canAccomodateAdditionalProtoRecordForRelationshipDescription:(NSRelationshipDescription *)relationshipDescription {
    NSString *relationshipName = [relationshipDescription name];
    NSMutableOrderedSet *protoSet = [self.relationshipProtosDictionary objectForKey:relationshipName];
    
    if ([relationshipDescription isToMany] == NO && [protoSet count] >= 1) {
        return NO;
    }
    
    return YES;
}


#pragma mark - Relationships

- (void)addRelationshipProto:(MMRecordProtoRecord *)relationshipProto
  forRelationshipDescription:(NSRelationshipDescription *)relationshipDescription {
    NSString *relationshipName = [relationshipDescription name];
    
    if (relationshipName != nil) {
        [self.relationshipDescriptionsDictionary setValue:relationshipDescription forKey:relationshipName];

        
        NSMutableOrderedSet *protoSet = [self.relationshipProtosDictionary objectForKey:relationshipName];
        
        if (protoSet == nil) {
            protoSet = [NSMutableOrderedSet orderedSet];
        }
        
        if ([self canAccomodateAdditionalProtoRecordForRelationshipDescription:relationshipDescription]) {
            [protoSet addObject:relationshipProto];
        }
        
        [self.relationshipProtosDictionary setValue:protoSet forKey:relationshipName];
    }
}



#pragma mark - Description

- (NSString *)description {
    NSString *description = [self protoDescriptionWithTabLevel:0];
    return description;
}



- (NSString *)stringForTabLevel:(NSInteger)tabLevel {
    NSString *tabs = @"";
    
    if (tabLevel > 0) {
        tabs = @"     ";
        for (int i = 0; i < tabLevel; i++) {
            tabs = [tabs stringByAppendingFormat:@"     "];
        }
    }
    
    return tabs;
}

- (NSString *)protoDescriptionWithTabLevel:(NSInteger)tabLevel {
    NSString *baseDescription = [self protoLineDescriptionWithTabLevel:tabLevel];
    NSString *relationshipProtos = [self relationshipProtoDescriptionForRelationshipProtos:self.relationshipProtos withTabLevel:tabLevel+1];
    NSString *description = [NSString stringWithFormat:@"%@%@", baseDescription, relationshipProtos];
    return description;
}

- (NSString *)protoLineDescriptionWithTabLevel:(NSInteger)tabLevel {
    NSString *objectDescription = [super description];
    NSString *entityName = self.entity.name;
    NSString *primaryKeyValue = self.primaryKeyValue;
    NSString *newDescription = [NSString stringWithFormat:@"%@ Entity: %@, Value: %@", objectDescription, entityName, primaryKeyValue];
    return newDescription;
}

- (NSString *)relationshipProtoDescriptionForRelationshipProtos:(NSArray *)relationshipProtos withTabLevel:(NSInteger)tabLevel {
    NSString *relationshipString = @"";
    
    for (MMRecordProtoRecord *proto in relationshipProtos) {
        NSString *protoLine = [proto protoDescriptionWithTabLevel:tabLevel];
        NSString *tabs = [self stringForTabLevel:tabLevel];
        
        relationshipString = [relationshipString stringByAppendingFormat:@"%@%@%@", @"\r", tabs, protoLine];
    }
    
    NSString *description = [NSString stringWithFormat:@"%@", relationshipString];
    
    return description;
}

@end
