// MMRecordDynamicMarshaler.m
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

#import "MMRecordDynamicMarshaler.h"

#import "MMRecordDynamicRepresentation.h"
#import "MMRecordProtoRecord.h"
#import "MMRecordRepresentation.h"

@interface MMRecordChildlessDataDictionaryTransformer : NSValueTransformer

@property(nonatomic, strong) MMRecordProtoRecord *sourceProtoRecord;

+ (id)transformerWithProtoRecord:(MMRecordProtoRecord *)protoRecord;

- (id)initWithProtoRecord:(MMRecordProtoRecord *)protoRecord;

@end


@implementation MMRecordDynamicMarshaler

+ (void)populateProtoRecord:(MMRecordProtoRecord *)protoRecord {
  [super populateProtoRecord:protoRecord];
  
  MMRecordDynamicRepresentation *dynamicRepresentation =
      (MMRecordDynamicRepresentation *)protoRecord.representation;
  [self populateProtoRecord:protoRecord
       attributeDescription:dynamicRepresentation.dynamicStorageAttribute
             fromDictionary:protoRecord.dictionary];
}

+ (void)populateProtoRecord:(MMRecordProtoRecord *)protoRecord
       attributeDescription:(NSAttributeDescription *)attributeDescription
             fromDictionary:(NSDictionary *)dictionary {
  
    if (attributeDescription.attributeType == NSTransformableAttributeType) {
        MMRecordChildlessDataDictionaryTransformer *valueTransformer =
            [MMRecordChildlessDataDictionaryTransformer transformerWithProtoRecord:protoRecord];
        NSMutableDictionary *data = [valueTransformer transformedValue:dictionary];
        
        [self setValue:data
              onRecord:protoRecord.record
             attribute:attributeDescription
         dateFormatter:protoRecord.representation.dateFormatter];
    } else {
        [super populateProtoRecord:protoRecord
              attributeDescription:attributeDescription
                    fromDictionary:dictionary];
    }
}

@end

@implementation MMRecordChildlessDataDictionaryTransformer

+ (id)transformerWithProtoRecord:(MMRecordProtoRecord *)protoRecord {
    return [[self alloc] initWithProtoRecord:protoRecord];
}

+ (Class)transformedValueClass {
    return [NSDictionary class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)initWithProtoRecord:(MMRecordProtoRecord *)protoRecord {
    self = [super init];
    if (self) {
        _sourceProtoRecord = protoRecord;
    }
    return self;
}

- (id)transformedValue:(id)value {
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if (!self.sourceProtoRecord) {
        return nil;
    }
    
    NSMutableDictionary *data = [value mutableCopy];
    // Strip out all children in dictionary.
    MMRecordRepresentation *recordRepresentation = self.sourceProtoRecord.representation;
    NSArray *relationshipDescriptions = self.sourceProtoRecord.relationshipDescriptions;
    for (NSRelationshipDescription *relationshipDescription in relationshipDescriptions) {
        NSArray *keyPaths =
        [recordRepresentation keyPathsForMappingRelationshipDescription:relationshipDescription];
        for (NSString *keyPath in keyPaths) {
            [data removeObjectForKey:keyPath];
        }
    }
    return data;
}

@end