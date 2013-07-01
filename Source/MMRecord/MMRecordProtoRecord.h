// MMRecordProtoRecord.h
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

@class MMRecord;
@class MMRecordRepresentation;

/* This class represents a record in its prototype state before it hatches into a full living breathing
   MMRecord.  Proto records are typically created to match the contents of a request's response object.
   If your response object contains an array of 20 records of type "user", then you would create 20
   proto records for the user entity.  A proto record contains the entity whose type it represents and the
   dictionary it is based on from the response object.  It is also responsible for maintaining the
   association between itself and other proto records that represent the relationships to it's fully
   formed record.  One subtle thing to keep in mind is that only one proto record should be created for
   each unique record in the response object.  The proto record is not responsible for that, but it is
   an important consideration for a user of this class to consider.  This class is responsible for 
   populating records with their given dictionary, as well as establishing relationships to it's record.
 */

@interface MMRecordProtoRecord : NSObject

// Population
@property (nonatomic, strong) MMRecord *record;
@property (nonatomic, copy) NSDictionary *dictionary;
@property (nonatomic, strong, readonly) NSEntityDescription *entity;
@property (nonatomic, strong, readonly) MMRecordRepresentation *representation;

// Relationships
// Relationship protos and descriptions are returned in no particular order.
@property (nonatomic, strong, readonly) NSArray *relationshipProtos;
@property (nonatomic, strong, readonly) NSArray *relationshipDescriptions;

// Uniquing
@property (nonatomic, strong) id primaryKeyValue;
@property (nonatomic, weak) MMRecordProtoRecord *relationshipPrimaryKeyProto;
@property (nonatomic) BOOL hasRelationshipPrimarykey;

// Designated Initializer
+ (MMRecordProtoRecord *)protoRecordWithDictionary:(NSDictionary *)dictionary
                                            entity:(NSEntityDescription *)entity
                                    representation:(MMRecordRepresentation *)representation;

// Associate another proto as having a relationship to this one
- (void)addRelationshipProto:(MMRecordProtoRecord *)relationshipProto
  forRelationshipDescription:(NSRelationshipDescription *)relationshipDescription;

// Returns the proto records for a given relationship description
- (NSArray *)relationshipProtoRecordsForRelationshipDescription:(NSRelationshipDescription *)relationshipDescription;

@end
