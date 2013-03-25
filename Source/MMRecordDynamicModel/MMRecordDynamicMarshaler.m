//
//  MMRecordDynamicMarshaler.m
//  MMRecord
//
//  TODO: Replace with License Header
//

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
  
  MMRecordDynamicRepresentation *dynamicModelRepresentation =
      (MMRecordDynamicRepresentation *)protoRecord.representation;
  [self populateProtoRecord:protoRecord
       attributeDescription:dynamicModelRepresentation.dynamicStorageAttribute
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