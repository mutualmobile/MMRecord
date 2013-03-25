//
//  MMRecordDynamicMarshaler.h
//  MMRecord
//
//  TODO: Replace with License Header
//

#import "MMRecordMarshaler.h"

/**
 When populating MMRecord instances, this marshaler will look for attributes of type 
 NSTransformableAttributeType. When it finds any transformable attributes, this marshaler
 will populate the attribute with a dictionary containing all the raw data minus all items mapped
 as a relationship. This allows you to uptake changes (such as attribute additions/deletions) 
 in the incoming data model without having to reflect the changes in your Core Data model. The
 dictionary stored in the transformable attribute will fluctuate with the incoming data's model.
*/
@interface MMRecordDynamicMarshaler : MMRecordMarshaler

@end
