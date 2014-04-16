//
// FBMMRecordTweakModel.m
//
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
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

#import "FBMMRecordTweakModel.h"

#import "FBTweak.h"
#import "FBTweakCategory.h"
#import "FBTweakCollection.h"
#import "FBTweakStore.h"

#import "MMRecord.h"
#import "MMRecordRepresentation.h"

@implementation FBMMRecordTweakModel

+ (void)loadTweaksForManagedObjectModel:(NSManagedObjectModel *)model {
#define FBMMRecordTweakModelDefine
    FBTweakCategory *category = [self tweakCategory];
    
    for (NSEntityDescription *entity in model.entities) {
        MMRecordRepresentation *representation = [[MMRecordRepresentation alloc] initWithEntity:entity];
        FBTweakCollection *collection = [self tweakCollectionForEntity:entity];
        
        if (collection == nil) {
            collection = [[FBTweakCollection alloc] initWithName:entity.name];
            [category addTweakCollection:collection];
        }
        
        // Primary Key
        FBTweak *primaryKeyTweak = [self tweakForPrimaryKeyForEntity:entity];
        
        if (primaryKeyTweak == nil) {
            NSString *primaryKeyTweakIdentifier = [self tweakIdentifierForPrimaryKeyForEntity:entity];
            primaryKeyTweak = [[FBTweak alloc] initWithIdentifier:primaryKeyTweakIdentifier];
            primaryKeyTweak.name = primaryKeyTweakIdentifier;
            primaryKeyTweak.defaultValue = [representation primaryKeyPropertyName];
            [collection addTweak:primaryKeyTweak];
        }
        
        // Key Path For Response Object
        FBTweak *keyPathTweak = [self tweakForKeyPathForEntity:entity];
        
        if (keyPathTweak == nil) {
            NSString *keyPathTweakIdentifier = [self tweakIdentifierForKeyPathForEntity:entity];
            keyPathTweak = [[FBTweak alloc] initWithIdentifier:keyPathTweakIdentifier];
            Class recordClass = NSClassFromString([entity managedObjectClassName]);
            keyPathTweak.name = keyPathTweakIdentifier;
            keyPathTweak.defaultValue = [recordClass keyPathForResponseObject];
            [collection addTweak:keyPathTweak];
        }
        
        // Properties
        for (id property in entity.properties) {
            NSArray *keyPaths = nil;
            
            if ([property isKindOfClass:[NSAttributeDescription class]]) {
                keyPaths = [representation keyPathsForMappingAttributeDescription:property];
            } else if ([property isKindOfClass:[NSRelationshipDescription class]]) {
                keyPaths = [representation keyPathsForMappingRelationshipDescription:property];
            }
            
            if ([keyPaths count] > 0) {
                FBTweak *tweak = [self tweakForProperty:property entity:entity];
                
                if (tweak == nil) {
                    NSString *tweakIdentifier = [self tweakIdentifierForProperty:property
                                                                          entity:entity];

                    tweak = [[FBTweak alloc] initWithIdentifier:tweakIdentifier];
                    tweak.name = tweakIdentifier;
                    tweak.defaultValue = [keyPaths firstObject];
                    [collection addTweak:tweak];
                }
            }
        }
    }
}

+ (NSString *)tweakIdentifierForProperty:(NSPropertyDescription *)property
                                  entity:(NSEntityDescription *)entity {
    return [NSString stringWithFormat:@"%@.%@", entity.name, property.name];
}

+ (NSString *)tweakIdentifierForPrimaryKeyForEntity:(NSEntityDescription *)entity {
    return [NSString stringWithFormat:@"%@.primaryKey", entity.name];
}

+ (NSString *)tweakIdentifierForKeyPathForEntity:(NSEntityDescription *)entity {
    return [NSString stringWithFormat:@"%@.keyPathForResponseObject", entity.name];
}

+ (FBTweakCategory *)tweakCategory {
    FBTweakStore *store = [FBTweakStore sharedInstance];
    FBTweakCategory *category = [store tweakCategoryWithName:@"MMRecord"];
    
    // Add the default MMRecord tweak category if it doesn't already exist
    if (category == nil) {
        category = [[FBTweakCategory alloc] initWithName:@"MMRecord"];
        [store addTweakCategory:category];
    }
    
    return category;
}

+ (FBTweakCollection *)tweakCollectionForEntity:(NSEntityDescription *)entity {
    FBTweakCategory *category = [self tweakCategory];

    FBTweakCollection *collection = [category tweakCollectionWithName:entity.name];
    
    return collection;
}

+ (FBTweak *)tweakForProperty:(NSPropertyDescription *)property entity:(NSEntityDescription *)entity {
    NSString *tweakIdentifier = [self tweakIdentifierForProperty:property
                                                     entity:entity];
    FBTweakCollection *collection = [self tweakCollectionForEntity:entity];
    FBTweak *tweak = [collection tweakWithIdentifier:tweakIdentifier];
    
    return tweak;
}

+ (FBTweak *)tweakForPrimaryKeyForEntity:(NSEntityDescription *)entity {
    NSString *tweakIdentifier = [self tweakIdentifierForPrimaryKeyForEntity:entity];
    FBTweakCollection *collection = [self tweakCollectionForEntity:entity];
    FBTweak *tweak = [collection tweakWithIdentifier:tweakIdentifier];
    
    return tweak;
}

+ (FBTweak *)tweakForKeyPathForEntity:(NSEntityDescription *)entity {
    NSString *tweakIdentifier = [self tweakIdentifierForKeyPathForEntity:entity];
    FBTweakCollection *collection = [self tweakCollectionForEntity:entity];
    FBTweak *tweak = [collection tweakWithIdentifier:tweakIdentifier];
    
    return tweak;
}

+ (NSString *)tweakedKeyPathForEntity:(NSEntityDescription *)entity {
    FBTweak *tweak = [self tweakForKeyPathForEntity:entity];
    FBTweakValue keyPath = tweak.currentValue;
    
    if ([keyPath isKindOfClass:[NSString class]] == NO) {
        return nil;
    }
    
    return keyPath;
}

+ (NSString *)tweakedPrimaryKeyForEntity:(NSEntityDescription *)entity {
    FBTweak *tweak = [self tweakForPrimaryKeyForEntity:entity];
    FBTweakValue primaryKey = tweak.currentValue;
    
    if ([primaryKey isKindOfClass:[NSString class]] == NO) {
        return nil;
    }
    
    return primaryKey;
}

+ (NSString *)tweakedKeyPathForMappingAttributeDescription:(NSAttributeDescription *)attribute
                                                    entity:(NSEntityDescription *)entity {
    return [self tweakedKeyPathForMappingPropertyDescription:attribute entity:entity];
}

+ (NSString *)tweakedKeyPathForMappingRelationshipDescription:(NSRelationshipDescription *)relationship
                                                       entity:(NSEntityDescription *)entity {
    return [self tweakedKeyPathForMappingPropertyDescription:relationship entity:entity];
}

+ (NSString *)tweakedKeyPathForMappingPropertyDescription:(NSPropertyDescription *)property
                                                   entity:(NSEntityDescription *)entity {
    FBTweak *tweak = [self tweakForProperty:property entity:entity];
    FBTweakValue tweakValue = [tweak currentValue];
    
    if ([tweakValue isKindOfClass:[NSString class]] == NO) {
        return nil;
    }
    
    return tweakValue;
}

@end
