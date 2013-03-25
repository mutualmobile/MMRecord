//
//  MMRecordProtoRecord.m
//  MMRecord
//
//  TODO: Replace with License Header
//

#import "MMRecordProtoRecord.h"

#import "MMRecordRepresentation.h"

@interface MMRecordProtoRecord ()
@property (nonatomic, strong, readwrite) NSMutableArray *relationshipProtos;
@property (nonatomic, strong, readwrite) NSMutableArray *relationshipDescriptions;
@property (nonatomic, strong) MMRecordRepresentation *representation;
@property (nonatomic, strong) NSEntityDescription *entity;
@end

@implementation MMRecordProtoRecord

+ (MMRecordProtoRecord *)protoRecordWithDictionary:(NSDictionary *)dictionary
                                            entity:(NSEntityDescription *)entity
                                    representation:(MMRecordRepresentation *)representation {
    MMRecordProtoRecord *protoRecord = [[MMRecordProtoRecord alloc] init];
    protoRecord.dictionary = dictionary;
    protoRecord.entity = entity;
    protoRecord.primaryKeyValue = [representation primaryKeyValueFromDictionary:dictionary];
    protoRecord.relationshipProtos = [NSMutableArray array];
    protoRecord.relationshipDescriptions = [NSMutableArray array];
    protoRecord.hasRelationshipPrimarykey = [representation hasRelationshipPrimaryKey];
    protoRecord.representation = representation;
    
    return protoRecord;
}


#pragma mark - Population



#pragma mark - Relationships

- (void)addRelationshipProto:(MMRecordProtoRecord *)relationshipProto
  forRelationshipDescription:(NSRelationshipDescription *)relationshipDescription {
    [(NSMutableArray *)self.relationshipProtos addObject:relationshipProto];
    [(NSMutableArray *)self.relationshipDescriptions addObject:relationshipDescription];
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
