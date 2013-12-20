// AFMMRecordResponseSerializationMapper.h
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

#import "AFMMRecordResponseSerializer.h"

/**
 AFMMRecordResponseSerializationMapper is a concrete implementation of the
 AFMMRecordResponseSerializationEntityMapping protocol. This mapper provides the very basic
 functionality of mapping an endpoint path component to an NSEntityDescription entity name. The 
 endpoint path component is intended to be something uniquely identifiable, such as /users/search?.
 An entity name string is requested as a parameter as opposed to an actual instance of 
 NSEntityDescription so that the mapper can create the entity description object with whichever
 NSManagedObjectContext object is passed in through the entity mapping protocol.
 
 Note: Using this implementation of the entity mapping protocol is optional. This class is provided
 as an ease of use option for AFMMRecordResponseSerializer users who only need basic mapping
 functionality. If you have a more complex mapping need then you should provide your own
 implementation of the entity mapping protocol.
 */
@interface AFMMRecordResponseSerializationMapper : NSObject <AFMMRecordResponseSerializationEntityMapping>

/**
 Register an entity name for a given endpoint path component. The endpoint path component will be
 searched for in the NSURLResponse object's URL parameter to determine if that endpoint was part of
 a given request. If the endpoint path component is found within that URL then the registered
 entity name will be used to instantiate an NSEntityDescription object that will be returned
 through the entity mapping protocol to the AFMMRecordResponseSerializer.
 
 @param entityName The name of a Core Data Entity
 @param endpoint The endpoint path component which uniquely identifies a URL used for returning
 objects of a certain entity type.
 */
- (void)registerEntityName:(NSString *)entityName forEndpointPathComponent:(NSString *)endpoint;

@end
