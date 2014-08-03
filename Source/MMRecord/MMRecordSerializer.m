//
// MMRecordSerializer.m
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

#import "MMRecordSerializer.h"

#import "MMRecord.h"
#import "MMRecordRepresentation.h"

@implementation MMRecordSerializer

+ (id)serializedObjectForRecord:(MMRecord *)record
             withRepresentation:(MMRecordRepresentation *)representation {
    NSEntityDescription *entity = representation.entity;
    NSMutableDictionary *serializedObject = [NSMutableDictionary dictionary];

    NSArray *attributes = [[entity attributesByName] allValues];
    
    for (NSAttributeDescription *attribute in attributes) {
        NSArray *keyPaths = [representation keyPathsForMappingAttributeDescription:attribute];
        NSString *firstKeyPath = [keyPaths firstObject];
        
        if (firstKeyPath != nil) {
            id value = [record valueForKey:attribute.name];
            
            if (value != nil) {
                [serializedObject setValue:value forKeyPath:firstKeyPath];
            }
        }
    }
    
    // Need to detect circular references and recursion so that we don't get into an infinite loop here going through relationships
    
    
//    NSArray *relationships = [[entity relationshipsByName] allValues];
//    
//    for (NSRelationshipDescription *relationship in relationships) {
//        NSArray *keyPaths = [representation keyPathsForMappingRelationshipDescription:relationship];
//        NSString *firstKeyPath = [keyPaths firstObject];
//        
//        if (firstKeyPath != nil) {
//            if ([relationship isToMany]) {
//                NSMutableArray *array = [NSMutableArray array];
//                
//                NSSet *set = [record valueForKey:relationship.name];
//                NSArray *allObjects = [set allObjects];
//                
//                for (MMRecord *value in allObjects) {
//                    if ([value respondsToSelector:@selector(serializedObject)]) {
//                        id serializedRecord = [value serializedObject];
//                        
//                        if (serializedRecord != nil) {
//                            [array addObject:serializedRecord];
//                        }
//                    }
//                }
//                
//                if ([array count] > 0) {
//                    [serializedObject setValue:array forKeyPath:firstKeyPath];
//                }
//            } else {
//                MMRecord *value = [record valueForKey:relationship.name];
//                
//                if ([value respondsToSelector:@selector(serializedObject)]) {
//                    id serializedRecord = [value serializedObject];
//                    
//                    if (serializedRecord != nil) {
//                        [serializedObject setValue:serializedRecord forKeyPath:firstKeyPath];
//                    }
//                }
//            }
//        }
//    }
    
    if ([serializedObject count] == 0) {
        return nil;
    }
    
    return serializedObject;
}

@end
