//
//  MMRecordResponseDescription.h
//  MMRecord
//
//  TODO: Replace with License Header
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/* This class describes the response from a request started by MMRecord.  It contains the array of objects
   obtained from the response object which should be converted into MMRecords.  It also contains the initial
   entity, which all of the objects in the response object array should be a type of.  This class has only
   one instance method, -records, which returns an array of MMRecord objects created from the response object.
   As such, this class is responsible for building records from the response object based on information from
   the inital entity and storing them in the given context. 
 */

@interface MMRecordResponse : NSObject

// Designated Initializer
+ (MMRecordResponse *)responseFromResponseObjectArray:(NSArray *)responseObjectArray
                                        initialEntity:(NSEntityDescription *)initialEntity
                                              context:(NSManagedObjectContext *)context;

// Records from Response Description
- (NSArray *)records;

@end
