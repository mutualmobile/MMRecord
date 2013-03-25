//
//  MMRecordDynamicRepresentation.m
//  MMRecord
//
//  TODO: Replace with License Header
//

#import "MMRecordDynamicRepresentation.h"

#import "MMRecordDynamicMarshaler.h"

@implementation MMRecordDynamicRepresentation

- (Class)marshalerClass {
  return [MMRecordDynamicMarshaler class];
}

- (void)setupMappingForProperty:(NSPropertyDescription *)property {
    if ([property isKindOfClass:[NSAttributeDescription class]]) {
        NSAttributeDescription *attributeDescription = (NSAttributeDescription *)property;
        
        if (attributeDescription.attributeType == NSTransformableAttributeType) {
            self.dynamicStorageAttribute = attributeDescription;
        } else {
            [super setupMappingForProperty:property];
        }
    } else {
        [super setupMappingForProperty:property];
    }
}

@end
