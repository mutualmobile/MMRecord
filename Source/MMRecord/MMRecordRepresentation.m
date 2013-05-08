// MMRecordRepresentation.m
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

#import "MMRecordRepresentation.h"

#import "MMRecord.h"
#import "MMRecordMarshaler.h"

/* 
 This class encapsulates the representation an NSRelationshipDescription for a given entity
 representation.  It contains a shortcut to the relationship key (typically the name of the relationship)
 that it 'represents', as well as the possible keys that could 'represent' the relationship in a response dictionary.
 */

@interface MMRecordRelationshipRepresentation : NSObject

@property (nonatomic, copy) NSString *relationshipKey;
@property (nonatomic, strong) MMRecordRepresentation *entityRepresentation;
@property (nonatomic, strong) NSRelationshipDescription *relationshipDescription;
@property (nonatomic, copy) NSArray *keyPaths;

@end

/* 
 This class encapsulates the representation an NSAttributeDescription for a given entity
 representation.  It contains a shortcut to the attribute key (typically the name of the attribute)
 that it 'represents', as well as the possible keys that could 'represent' the attribute in a response dictionary.
 */

@interface MMRecordAttributeRepresentation : NSObject

@property (nonatomic, copy) NSString *attributeKey;
@property (nonatomic, strong) NSAttributeDescription *attributeDescription;
@property (nonatomic, copy) NSArray *keyPaths;

@end

@interface MMRecordRepresentation ()

@property (nonatomic, strong) NSDateFormatter *recordClassDateFormatter;

@property (nonatomic, strong) NSMutableDictionary *representationDictionary;
@property (nonatomic, copy) NSString *primaryKey;

@property (nonatomic, strong) NSMutableArray *attributeRepresentations;
@property (nonatomic, strong) NSMutableArray *relationshipRepresentations;

@end

@implementation MMRecordRepresentation

- (instancetype)initWithEntity:(NSEntityDescription *)entity {
    if ((self = [self init])) {
        NSParameterAssert([NSClassFromString([entity managedObjectClassName]) isSubclassOfClass:[MMRecord class]]);
        _entity = entity;
        _representationDictionary = [NSMutableDictionary dictionary];
        _attributeRepresentations = [NSMutableArray array];
        _relationshipRepresentations = [NSMutableArray array];
        _recordClassDateFormatter = [NSClassFromString([entity managedObjectClassName]) dateFormatter];
        
        NSDictionary *userInfo = [entity userInfo];
        _primaryKey = [userInfo valueForKey:MMRecordEntityPrimaryAttributeKey];
        [self createRepresentationMapping];
    }
    return self;
}

- (NSArray *)additionalKeyPathsForMappingPropertyDescription:(NSPropertyDescription *)propertyDescription {
    NSDictionary *userInfo = [propertyDescription userInfo];
    NSString *alternatePropertyKeyPath = [userInfo valueForKey:MMRecordAttributeAlternateNameKey];
    
    if (alternatePropertyKeyPath) {
        return @[alternatePropertyKeyPath];
    }
    
    return nil;
}

- (Class)marshalerClass {
    return [MMRecordMarshaler class];
}

- (NSDateFormatter *)dateFormatter {
    return self.recordClassDateFormatter;
}

- (NSString *)primaryKeyPropertyName {
    return self.primaryKey;
}

- (id)primaryKeyValueFromDictionary:(NSDictionary *)dictionary {
    id primaryKeyRepresentation = self.representationDictionary[self.primaryKey];
    
    if ([primaryKeyRepresentation isKindOfClass:[MMRecordAttributeRepresentation class]]) {
        id value = nil;
        
        for (NSString *key in [primaryKeyRepresentation keyPaths]) {
            value = [dictionary valueForKeyPath:key];
            
            if (value != nil) {
                return value;
            }
        }
    }
    
    return nil;
}

#pragma mark - Attribute Population

- (NSArray *)attributeDescriptions {
    NSMutableArray *attributeDescriptions = [NSMutableArray array];
    
    for (MMRecordAttributeRepresentation *attributeRepresentation in self.attributeRepresentations) {
        [attributeDescriptions addObject:attributeRepresentation.attributeDescription];
    }
    
    return attributeDescriptions;
}

- (NSArray *)keyPathsForMappingAttributeDescription:(NSAttributeDescription *)attributeDescription {
    id attributeRepresentation = self.representationDictionary[attributeDescription.name];
    
    if ([attributeRepresentation isKindOfClass:[MMRecordAttributeRepresentation class]]) {
        return [attributeRepresentation keyPaths];
    }
    
    return nil;
}


#pragma mark - Relationship Population

- (NSArray *)relationshipDescriptions {
    NSMutableArray *relationshipDescriptions = [NSMutableArray array];
    
    for (MMRecordRelationshipRepresentation *relationshipRepresentation in self.relationshipRepresentations) {
        [relationshipDescriptions addObject:relationshipRepresentation.relationshipDescription];
    }
    
    return relationshipDescriptions;
}

- (NSArray *)keyPathsForMappingRelationshipDescription:(NSRelationshipDescription *)relationshipDescription {
    id relationshipRepresentation = self.representationDictionary[relationshipDescription.name];
    
    if ([relationshipRepresentation isKindOfClass:[MMRecordRelationshipRepresentation class]]) {
        return [relationshipRepresentation keyPaths];
    }
    
    return nil;
}


#pragma mark - Unique Identification


- (BOOL)hasRelationshipPrimaryKey {
    id primaryKeyRepresentation = self.representationDictionary[self.primaryKey];
    
    if ([primaryKeyRepresentation isKindOfClass:[MMRecordRelationshipRepresentation class]]) {
        return YES;
    }
    
    return NO;
}

- (NSRelationshipDescription *)primaryRelationshipDescription {
    MMRecordRelationshipRepresentation *primaryKeyRepresentation = self.representationDictionary[self.primaryKey];
    
    return primaryKeyRepresentation.relationshipDescription;
}


#pragma mark - Creating Representation

- (void)createRepresentationMapping {
    NSArray *properties = [self.entity properties];
    [self.representationDictionary removeAllObjects];
    [self.relationshipRepresentations removeAllObjects];
    
    for (NSPropertyDescription *property in properties) {
        [self setupMappingForProperty:property];
    }
}

- (void)setupMappingForProperty:(NSPropertyDescription *)property {
    NSString *propertyKey = [property name];
    NSArray *additionalKeyPaths = [self additionalKeyPathsForMappingPropertyDescription:property];
    
    // Attributes
    if ([property isKindOfClass:[NSAttributeDescription class]]) {
        [self setupAttributeKey:propertyKey
             additionalKeyPaths:additionalKeyPaths
           attributeDescription:(NSAttributeDescription *)property];
    }
    
    // Relationships
    else if ([property isKindOfClass:[NSRelationshipDescription class]]) {
        [self setupRelationshipKey:propertyKey
                additionalKeyPaths:additionalKeyPaths
           relationshipDescription:(NSRelationshipDescription *)property];
    }
}

- (void)setupAttributeKey:(NSString *)attributeKey
       additionalKeyPaths:(NSArray *)additionalKeyPaths
     attributeDescription:(NSAttributeDescription *)attributeDescription {
    NSMutableArray *keyPaths = [NSMutableArray array];
    
    if (additionalKeyPaths) {
        [keyPaths addObjectsFromArray:additionalKeyPaths];
    }
    
    [keyPaths addObject:attributeKey];
    
    MMRecordAttributeRepresentation *representation = [[MMRecordAttributeRepresentation alloc] init];
    representation.attributeDescription = attributeDescription;
    representation.keyPaths = keyPaths;
    representation.attributeKey = attributeKey;
    
    [self.representationDictionary setValue:representation forKey:attributeKey];
    [self.attributeRepresentations addObject:representation];
}

- (void)setupRelationshipKey:(NSString *)relationshipKey
          additionalKeyPaths:(NSArray *)additionalKeyPaths
     relationshipDescription:(NSRelationshipDescription *)relationshipDescription {
    NSMutableArray *keyPaths = [NSMutableArray array];
    
    if (additionalKeyPaths) {
        [keyPaths addObjectsFromArray:additionalKeyPaths];
    }
    
    [keyPaths addObject:relationshipKey];
    
    MMRecordRelationshipRepresentation *representation = [[MMRecordRelationshipRepresentation alloc] init];
    representation.relationshipDescription = relationshipDescription;
    representation.keyPaths = keyPaths;
    representation.relationshipKey = relationshipKey;
    representation.entityRepresentation = self;
    
    [self.representationDictionary setValue:representation forKey:relationshipKey];
    [self.relationshipRepresentations addObject:representation];
}

@end

@implementation MMRecordAttributeRepresentation
@end

@implementation MMRecordRelationshipRepresentation
@end

