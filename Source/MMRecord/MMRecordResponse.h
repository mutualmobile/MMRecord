// MMRecordResponseDescription.h
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
