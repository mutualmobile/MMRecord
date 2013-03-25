//
//  MMRecordDynamicRepresentation.h
//  MMRecord
//
//  TODO: Replace with License Header
//

#import "MMRecordRepresentation.h"

/** 
 This flavor of ModelRepresentation looks for an attribute of type NSTransformableAttributeType
 and sets it aside in the |dynamicStorageAttribute| property. This transformable attribute will
 hold the original raw dictionary representation minus any relationships. This representation
 will only take the last attribute that is transformable. NOTE: All other transformable attributes
 will be ignored my MMRecord. This model assumes each entity contains at most one transformable
 attribute. 
*/
@interface MMRecordDynamicRepresentation : MMRecordRepresentation

/**  
 The attribute description for the attribute responsible for holding the original raw dictionary
 of data.
*/
@property(nonatomic, strong) NSAttributeDescription *dynamicStorageAttribute;

@end
