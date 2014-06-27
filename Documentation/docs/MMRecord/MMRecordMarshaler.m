// MMRecordMarshaler.m
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

#import "MMRecordMarshaler.h"

#import "MMRecord.h"
#import "MMRecordDebugger.h"
#import "MMRecordProtoRecord.h"
#import "MMRecordRepresentation.h"

@implementation MMRecordMarshaler

+ (void)populateProtoRecord:(MMRecordProtoRecord *)protoRecord {
    if (protoRecord.primaryAttributeDescription != nil) {
        [self setValue:protoRecord.primaryKeyValue
              onRecord:protoRecord.record
             attribute:protoRecord.primaryAttributeDescription
         dateFormatter:protoRecord.representation.dateFormatter];
    }
    
    for (NSAttributeDescription *attributeDescription in [protoRecord.representation attributeDescriptions]) {
        [self populateProtoRecord:protoRecord
             attributeDescription:attributeDescription
                   fromDictionary:protoRecord.dictionary];
    }
}

+ (void)populateProtoRecord:(MMRecordProtoRecord *)protoRecord
       attributeDescription:(NSAttributeDescription *)attributeDescription
             fromDictionary:(NSDictionary *)dictionary {
    NSArray *possibleKeyPaths = [protoRecord.representation keyPathsForMappingAttributeDescription:attributeDescription];
    
    for (NSString *possibleKeyPath in possibleKeyPaths) {
        id value = [protoRecord.dictionary valueForKeyPath:possibleKeyPath];
        
        if (value == [NSNull null]) {
            break;
        }
        
        if (value == nil) {
            continue;
        }
        
        [self setValue:value
              onRecord:protoRecord.record
             attribute:attributeDescription
         dateFormatter:protoRecord.representation.dateFormatter];
    }
}

+ (void)setValue:(id)value
        onRecord:(MMRecord *)record
       attribute:(NSAttributeDescription *)attribute
   dateFormatter:(NSDateFormatter *)dateFormatter {
    if (value == nil) {
        return;
    }
    
    id newValue = [self valueForAttribute:attribute rawValue:value dateFormatter:dateFormatter];
    
    if (newValue != nil) {
        [record setValue:newValue forKey:attribute.name];
    }
}

+ (id)valueForAttribute:(NSAttributeDescription *)attribute
               rawValue:(id)rawValue
          dateFormatter:(NSDateFormatter *)dateFormatter {
    NSAttributeType attributeType = [attribute attributeType];
    
    id value = rawValue;
    
    if (attributeType == NSDateAttributeType) {
        value = [self dateValueForAttribute:attribute
                                      value:rawValue
                              dateFormatter:dateFormatter];
    } else if (attributeType == NSTransformableAttributeType) {
        value = [self transformedValueForAttribute:attribute
                                             value:rawValue];
    } else if (attributeType == NSInteger32AttributeType ||
               attributeType == NSInteger16AttributeType ||
               attributeType == NSInteger64AttributeType) {
        value = [self numberValueForAttribute:attribute value:rawValue];
    } else if (attributeType == NSBooleanAttributeType) {
        value = [self boolValueForAttribute:attribute value:rawValue];
    } else if (attributeType == NSStringAttributeType) {
        value = [self stringValueForAttribute:attribute value:rawValue];
    }
    
    return value;
}

+ (NSDate *)dateValueForAttribute:(NSAttributeDescription *)attribute
                            value:(id)value
                    dateFormatter:(NSDateFormatter *)dateFormatter {
    if ([value isKindOfClass:[NSNumber class]]) {
        return [NSDate dateWithTimeIntervalSince1970:[value integerValue]];
    }
    
    if (dateFormatter != nil) {
        return [dateFormatter dateFromString:value];
    }
    
    return nil;
}

+ (id)transformedValueForAttribute:(NSAttributeDescription *)attribute value:(id)value {
    NSValueTransformer *transformer = [[NSClassFromString(attribute.valueTransformerName) alloc] init];
    
    if (transformer != nil) {
        return [transformer transformedValue:value];
    }
    
    return value;
}

+ (NSNumber *)numberValueForAttribute:(NSAttributeDescription *)attribute value:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return @([value intValue]);
    }
    
    return value;
}

+ (NSNumber *)boolValueForAttribute:(NSAttributeDescription *)attribute value:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return @([value boolValue]);
    }
    
    return value;
}

+ (NSString *)stringValueForAttribute:(NSAttributeDescription *)attribute value:(id)value {
    if (value != nil && ![value isKindOfClass:[NSString class]]) {
        return [value stringValue];
    }
    
    return value;
}

+ (void)establishRelationshipsOnProtoRecord:(MMRecordProtoRecord *)protoRecord {
    for (NSRelationshipDescription *relationshipDescription in protoRecord.relationshipDescriptions) {
        NSArray *relationshipProtoRecords = [protoRecord relationshipProtoRecordsForRelationshipDescription:relationshipDescription];
        
        for (MMRecordProtoRecord *relationshipProtoRecord in relationshipProtoRecords) {
            MMRecord *fromRecord = protoRecord.record;
            MMRecord *toRecord = relationshipProtoRecord.record;
            
            [self establishRelationship:relationshipDescription fromRecord:fromRecord toRecord:toRecord];
        }
    }
}

+ (void)establishRelationship:(NSRelationshipDescription *)relationship
                   fromRecord:(MMRecord *)fromRecord
                     toRecord:(MMRecord *)toRecord {
    if (fromRecord != nil && toRecord != nil) {
        if ([relationship isToMany]) {
            [self establishToManyRelationship:relationship fromRecord:fromRecord toRecord:toRecord];
        } else {
            if (relationship.inverseRelationship != nil && [fromRecord valueForKey:[relationship name]] != nil) {
                [MMRecordDebugger logMessageWithDescription:
                 [NSString stringWithFormat:@"Replacing existing value may invalidate an inverse relationship."]];
            }
            
            [fromRecord setValue:toRecord forKey:[relationship name]];
        }
    }
}

+ (void)establishToManyRelationship:(NSRelationshipDescription *)relationship
                         fromRecord:(MMRecord *)fromRecord
                           toRecord:(MMRecord *)toRecord {
    id relationshipSet;
    
    BOOL useOrderedSet = NO;
    
    if ([relationship respondsToSelector:@selector(isOrdered)]) {
        useOrderedSet = relationship.isOrdered ? YES : NO;
    }
    if (useOrderedSet) {
        relationshipSet = [fromRecord mutableOrderedSetValueForKey:[relationship name]];
    } else {
        relationshipSet = [fromRecord mutableSetValueForKey:[relationship name]];
    }
    
    [relationshipSet addObject:toRecord];
    [fromRecord setValue:relationshipSet forKey:[relationship name]];
}

+ (void)establishPrimaryKeyRelationshipFromProtoRecord:(MMRecordProtoRecord *)protoRecord
             toParentRelationshipPrimaryKeyProtoRecord:(MMRecordProtoRecord *)parentRelationshipPrimaryKeyProto {
    protoRecord.relationshipPrimaryKeyProto = parentRelationshipPrimaryKeyProto;
    
    NSRelationshipDescription *primaryRelationshipDescription = [protoRecord.representation primaryRelationshipDescription];
    MMRecord *parentRecord = parentRelationshipPrimaryKeyProto.record;
    NSRelationshipDescription *parentRecordRelationshipDescription = [primaryRelationshipDescription inverseRelationship];
    NSString *key = [parentRecordRelationshipDescription name];
    id existingRecordOrCollectionFromRelationship = [parentRecord valueForKey:key];
    MMRecord *existingRecordFromParent = nil;
    
    //sometimes will get a _NSFaultingMutableSet here
    //need to iterate through set to find out which managed object
    //is the correct one to assign
    if ([existingRecordOrCollectionFromRelationship respondsToSelector:@selector(count)]) {
        
        //is a faulted set; iterate through to find
        for (MMRecord *faultedObject in (NSSet *)existingRecordOrCollectionFromRelationship) {
            if ([self verifyObject:faultedObject containsValuesForKeysInDict:protoRecord.dictionary representation:protoRecord.representation] == YES) {
                existingRecordFromParent = faultedObject;
                
                break;
            }
        }
    }
    
    if (!existingRecordFromParent) {
        if ([existingRecordOrCollectionFromRelationship isKindOfClass:[MMRecord class]]) {
            existingRecordFromParent = existingRecordOrCollectionFromRelationship;
        }
    }
    
    // Perhaps we don't want to nil out self.record if existingRecordFromParent is nil...
    // If we do this then we may overwrite a created object from earlier.  We should only be
    // setting self.record if we do find an existing record from the parent.
    if (existingRecordFromParent != nil) {
        protoRecord.record = existingRecordFromParent;
    }
}

+ (void)mergeDuplicateRecordResponseObjectDictionary:(NSDictionary *)dictionary
                             withExistingProtoRecord:(MMRecordProtoRecord *)protoRecord {
    if ([protoRecord.dictionary.allKeys count] == 1) {
        NSAttributeDescription *primaryAttributeDescription = protoRecord.representation.primaryAttributeDescription;
        NSArray *primaryKeyPaths = [protoRecord.representation keyPathsForMappingAttributeDescription:primaryAttributeDescription];
        
        BOOL dictionariesContainIdenticalPrimaryKeys = NO;
        
        for (NSString *keyPath in primaryKeyPaths) {
            id dictionaryValue = [dictionary valueForKeyPath:keyPath];
            id protoRecordValue = [dictionary valueForKeyPath:keyPath];
            
            if ([dictionaryValue isKindOfClass:[NSNumber class]] && [protoRecordValue isKindOfClass:[NSNumber class]]) {
                dictionariesContainIdenticalPrimaryKeys = [dictionaryValue isEqualToNumber:protoRecordValue];
            } else if ([dictionaryValue isKindOfClass:[NSString class]] && [protoRecordValue isKindOfClass:[NSString class]]) {
                dictionariesContainIdenticalPrimaryKeys = [dictionaryValue isEqualToString:protoRecordValue];
            }
            
            if (dictionariesContainIdenticalPrimaryKeys) {
                break;
            }
        }
        
        if (dictionariesContainIdenticalPrimaryKeys) {
            protoRecord.dictionary = dictionary;
        }
    }
    
    if ([dictionary.allKeys count] != [protoRecord.dictionary.allKeys count]) {
        [MMRecordDebugger logMessageWithDescription:@"Possible inconsistent duplicate records detected. MMRecord provided the opportunity to merge two dictionaries representing the same record, where those two dictionaries were not equal. You may override the MMRecordMarshaler mergeDuplicateRecordResponseObjectDictionary:withExistingProtoRecord: method to deal with this issue if it becomes a problem. This is not expected behavior and may be due to an response issue."];
    }
}


#pragma mark - To Many Relationship Test

// TODO: Simplify this method by refactor/extract
+ (BOOL)verifyObject:(id)object containsValuesForKeysInDict:(id)dict representation:(MMRecordRepresentation *)representation {
    if ([[dict class] isSubclassOfClass:[NSDictionary class]] &&
        [[object class] isSubclassOfClass:[NSManagedObject class]]) {
        NSArray *allKeys = [dict allKeys];
        NSArray *allAttributeKeys = [[[object entity] attributesByName] allKeys];
        
        BOOL containsAllKeys = YES;
        
        for (NSString *objectKey in allKeys) {
            BOOL containsKey = NO;
            
            for (NSString *key in allAttributeKeys) {
                containsKey |= [objectKey isEqualToString:key];
            }
            
            containsAllKeys &= containsKey;
        }
        
        if (containsAllKeys == NO) {
            return NO;
        }
        
        __block BOOL validated = YES;
        
        for (NSString *validatorKeyPath in allKeys) {
            
            id subObject = [object valueForKeyPath:validatorKeyPath];
            
            if (subObject) {
                if([[subObject class] isSubclassOfClass:[NSArray class]]){
                    
                    [subObject enumerateObjectsUsingBlock:^(id arrayObject, NSUInteger idx, BOOL *stop) {
                        
                        id testValue = [[dict objectForKey:validatorKeyPath] objectAtIndex:idx];
                        
                        validated &= [self verifyObject:arrayObject
                            containsValuesForKeysInDict:testValue
                                         representation:representation];
                        
                        *stop = !validated;
                    }];
                }
                else if([[subObject class] isSubclassOfClass:[NSSet class]]){
                    
                    for (id objectDict in [dict objectForKey:validatorKeyPath]) {
                        BOOL containsObject = NO;
                        
                        for (id setObject in subObject) {
                            containsObject |= [self verifyObject:setObject
                                     containsValuesForKeysInDict:objectDict
                                                  representation:representation];
                            
                            if(containsObject == YES){
                                break;
                            }
                        }
                        
                        validated &= containsObject;
                        
                        if (validated == NO) {
                            break;
                        }
                    }
                }
                else{
                    NSDictionary *subDict = [dict objectForKey:validatorKeyPath];
                    
                    validated &= [self verifyObject:subObject
                        containsValuesForKeysInDict:subDict
                                     representation:representation];
                    
                    if (validated == NO) {
                        return NO;
                    }
                }
            }
            else {
                validated = NO;
            }
        }
        
        return validated;
    }
    else {
        BOOL equals = NO;
        if ([object isKindOfClass:[NSDate class]]) {
            NSDate *date = [[representation dateFormatter] dateFromString:dict];
            equals = [object isEqual:date];
        }
        else{
            equals = [object isEqual:dict];
        }
        
        return equals;
    }
}

@end
