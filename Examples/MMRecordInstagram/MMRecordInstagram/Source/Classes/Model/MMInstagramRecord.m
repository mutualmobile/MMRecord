#import "MMInstagramRecord.h"

#import "MMRecordDynamicRepresentation.h"

@implementation MMInstagramRecord

+ (NSString *)keyPathForResponseObject {
  return @"data";
}

+ (Class)representationClass {
  return [MMRecordDynamicRepresentation class];
}

@end
