// MMRecordResponse.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "MMRecord.h"

/**
 This class describes the response from a request started by MMRecord.  It contains the array of objects
 obtained from the response object which should be converted into MMRecords.  It also contains the initial
 entity, which all of the objects in the response object array should be a type of.  This class has only
 one instance method, -records, which returns an array of MMRecord objects created from the response object.
 As such, this class is responsible for building records from the response object based on information from
 the inital entity and storing them in the given context.
 
 This class represents the entry point for initiating the parsing/population response for MMRecord.
 As such, it can be used in a standalone fashion to provide the MMRecord population/parsing support
 to other classes and frameworks. An example of how this could be done is the AFMMRecordResponseSerializer,
 which uses MMRecordResponse on its own to provide similar behavior in the form of an AFNetworking
 response serializer.
 */

@interface MMRecordResponse : NSObject

/**
 Designated Initializer
 
 This method creates an MMRecordResponse from a response object array, initial entity, and other
 information. If a user whiches to initiate the population process with only a single object, then
 that object should be inserted into an array to instantiate this class.
 
 Calling this method and creating an MMRecordResponse configures this class completely in order to
 call the records method below and return an array of saturated and populated records.
 
 @param responseObjectArray An array of objects intended to be used for creating MMRecord instances.
 @param initialEntity The initial Core Data entity that will be returned by the records method.
 @param context A managed object context to fetch existing records from and store new records to.
 @param options A MMRecordOptions object to customize the response handling behaviors.
 */
+ (MMRecordResponse *)responseFromResponseObjectArray:(NSArray *)responseObjectArray
                                        initialEntity:(NSEntityDescription *)initialEntity
                                              context:(NSManagedObjectContext *)context
                                              options:(MMRecordOptions *)options;

/**
 This method is used to launch the entire parsing process. Execution of this method is synchronous.
 If you wish to provide asynchronous support (and you probably do), you should call this method from
 within an asynchronous block or operation.
 
 A great way to call this method is from within the managed object context's performBlock or
 performBlockAndWait method.
 
 Its also important to remember to call save on your context after using this method. This method
 will not call save for you. It will only insert or update objects in that context. Its up to you
 to save those changes.
 
 @return An array of records of the same type as (or sub-entity of) the initial entity provided 
 above.
 */
- (NSArray *)records;

@end
