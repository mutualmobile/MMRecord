// AFMMRecordResponseSerializer.h
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

#import "AFURLResponseSerialization.h"

#import <CoreData/CoreData.h>

@protocol AFMMRecordResponseSerializationEntityMapping;

/**
 AFMMRecordResponseSerializer is a response serializer for AFNetworking that can serialize an HTTP
 response object into a list of MMRecord objects. MMRecord objects are subclasses of Core Data
 NSManagedObjects. The record response serializer uses the MMRecord parsing system to convert from a
 response object into a list of parsed and fully populated managed objects. This allows you to use
 AFNetworking to make a HTTP request and to obtain NSManagedObjects directly in the success block
 for that request.
 
 The responseObject in the AFNetworking success block will contain an array of MMRecord subclasses
 when using the AFMMRecordResponseSerializer.
 
 You must initialize the record response serializer with both a NSManagedObjectContext and a 
 response object serializer which should be a subclass of AFHTTPResponseSerializer. The context will 
 be used for creating and updating parsed managed objects. The AFHTTPResponseSerializer subclass
 instance will be used for converting the HTTP response into an object graph form usable by MMRecord
 - which consists of arrays and dictionaries. You are asked to specify the instance of the response
 serializer so that this class can support JSON, XML, or other forms of HTTP responses.
 
 You must also provide a mapping from a response to a type of record. Use the response and response
 object to decide which entity you want to populate and return in the AFNetworking success block. 
 Implementation of this mapping is required and is done by conforming to the
 AFMMRecordResponseSerializationEntityMapping protocol. The AFMMRecordResponseSerializer library
 extension does provide a concrete implementation of this protocol in the form of the 
 AFMMRecordResponseSerializationMapper that you may use, or you can implement your own mapper to
 provide different or more complex mapping functionality.
 */
@interface AFMMRecordResponseSerializer : AFHTTPResponseSerializer <AFURLResponseSerialization>

/**
 Designated initializer for the MMRecordResponseSerializer.
 
 @param context The managed object context you wish to have records returned associated with.
 @param responseObjectSerializer A subclass of AFHTTPResponseSerializer that will be used for 
 serialization a dictionary/array response object that will be used for record parsing.
 @param entityMapper An object implementing the entity mapping protocol that will be used to return
 the correct NSEntityDescription for a given response.
 */
+ (instancetype)serializerWithManagedObjectContext:(NSManagedObjectContext *)context
                          responseObjectSerializer:(AFHTTPResponseSerializer *)serializer
                                      entityMapper:(id<AFMMRecordResponseSerializationEntityMapping>)mapper;

@end


@protocol AFMMRecordResponseSerializationEntityMapping <NSObject>

/**
 Required subclass method for determining which type of entity to create objects of for a given
 response and response object.
 
 @param serializer The serializer for which an entity is requested.
 @param response The response from the HTTP request.
 @param responseObject The parsed response object returned from the designated HTTPResponseSerializer.
 @param context The managed object context which entities will be parsed into.
 @warning You are required to subclass this method.
 */
- (NSEntityDescription *)recordResponseSerializer:(AFMMRecordResponseSerializer *)serializer
                                entityForResponse:(NSURLResponse *)response
                                   responseObject:(id)responseObject
                                          context:(NSManagedObjectContext *)context;


@end