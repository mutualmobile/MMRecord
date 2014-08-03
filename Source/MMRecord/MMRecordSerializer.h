//
// MMRecordSerializer.h
//
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
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

@class MMRecord;
@class MMRecordRepresentation;

/**
 This class can be used to serialize MMRecord instances into alternative forms, such as a dictionary
 form used for converting into JSON for a web request.
 
 By default this class will instantiate an instance of the MMRecordRepresentation associated with
 the class of record, if none is provided. You may choose to provide your own if you wish to
 implement special behavior.
 
 The representation will be used to get associated key paths for each attribute and relationship
 on the record. For each value, the first keyPath will be used to create a dictionary that
 represents the given record.
 
 You may wish to subclass this to provide your own behavior.
 
 @warning This class does NOT guarantee that the serialized form of a given record will be exactly
 what was used to populate the given record in the first place. THis method does its best to
 approximate that form, using the first found keyPath for each attribute and relationship. Some
 customization may be required if you need to serialize the object into a different form.
 */
@interface MMRecordSerializer : NSObject

/**
 This method returns a serialized object to represent a given record. In effect, this does the
 reverse of the MMRecord parsing procedure, to return an object to a state that may have been
 used for its transport format.
 
 @warning This method does NOT guarantee that the serialized form of the given record will be
 exactly what was used to populate the given record. This method does its best to approximate that
 form, using the first found keyPath for each attribute and relationship. Some customization may
 be required to match the serialized object exactly with your expected JSON (or other object slash
 transport format) structure.
 
 @param record The record to serialize.
 @param representation Optional parameter. The representation to use to serialize the record.
 @return A serialized object representing the given record.
 */
+ (id)serializedObjectForRecord:(MMRecord *)record
             withRepresentation:(MMRecordRepresentation *)representation;

@end
