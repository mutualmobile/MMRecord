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

/**
   This class represents a record in its prototype state before it hatches into a full living breathing
   MMRecord.  Proto records are typically created to match the contents of a request's response object.
   If your response object contains an array of 20 records of type "user", then you would create 20
   proto records for the user entity.  A proto record contains the entity whose type it represents and the
   dictionary it is based on from the response object.  It is also responsible for maintaining the
   association between itself and other proto records that represent the relationships to it's fully
   formed record.  One subtle thing to keep in mind is that only one proto record should be created for
   each unique record in the response object.  The proto record is not responsible for that, but it is
   an important consideration for a user of this class to consider.  This class is responsible for 
   populating records with their given dictionary, as well as establishing relationships to it's record.
 
   Note: when the value representing a relationship is a single string or number that MMRecord will
   convert that string or number into a dictionary with that value, and they primary key identified
   for that targetted relationship's entity. That means that the representation of a proto record
   will always be in the form of a dictionary, even if the response object form is a string or a
   number.
 */

@interface MMRecordProtoRecord : NSObject

///----------------------------
/// @name Population Properties
///----------------------------

/**
 The record instance represented by this proto record.
 */
@property (nonatomic, strong) MMRecord *record;

/**
 The dictionary being used to populate this proto record.
 */
@property (nonatomic, copy) NSDictionary *dictionary;

/**
 The entity type for this proto record.
 */
@property (nonatomic, strong, readonly) NSEntityDescription *entity;

/**
 The representation used to describe this type of proto record.
 */
@property (nonatomic, strong, readonly) MMRecordRepresentation *representation;


///------------------------------
/// @name Relationship Properties
///------------------------------

/**
 An array of relationship proto records that define the objects that will be associated as
 relationships on this proto record.
 */
@property (nonatomic, strong, readonly) NSArray *relationshipProtos;

/**
 The relationship descriptions for this proto record's type of entity.
 */
@property (nonatomic, strong, readonly) NSArray *relationshipDescriptions;


///--------------------------
/// @name Uniquing Properties
///--------------------------

/**
 The primary key value for this proto record. Typically a string or number.
 @warning This will be nil if the proto record uses a relationship as its primary key.
 */
@property (nonatomic, strong) id primaryKeyValue;

/**
 The primary key attribute description for this proto record.
 @warning This will be nil if the proto record uses a relationship as its primary key.
 */
@property (nonatomic, strong) NSAttributeDescription *primaryAttributeDescription;

/**
 The relationship primary key proto is used to reference the proto that can uniquely identify this
 record using one of its relationships.
 @warning This will be nil if the proto record does not use a relationship as its primary key.
 */
@property (nonatomic, weak) MMRecordProtoRecord *relationshipPrimaryKeyProto;

/**
 Property for defining whether or not this record has a relationship as its primary key.
 @return YES if the proto record has a relationship as its primary key.
 */
@property (nonatomic) BOOL hasRelationshipPrimarykey;

/**
 Designated Initializer

 This method is used to instantiate a base proto record. The proto record is configured with a
 dictionary that is used to populate the record, an entity to describe the type of record, and a
 representation that describes how the record can be populated from that dictionary. This method
 should always be used to instantiate a proto record.
 
 @param dictionary The dictionary used to populate the proto record.
 @param entity The type of record this describes.
 @param representation The representation used to describe this proto record.
 */
+ (MMRecordProtoRecord *)protoRecordWithDictionary:(NSDictionary *)dictionary
                                            entity:(NSEntityDescription *)entity
                                    representation:(MMRecordRepresentation *)representation;


///---------------------------
/// @name Relationship Methods
///---------------------------

/**
 This method is used to associate another proto as having a relationship to this one.
 @param relationshipProto The proto record representing the relationship.
 @param relationshipDescription The relationship on this proto to associate the proto with.
 */
- (void)addRelationshipProto:(MMRecordProtoRecord *)relationshipProto
  forRelationshipDescription:(NSRelationshipDescription *)relationshipDescription;

/**
 This method can be used to tell whether or not there is already a valid relationshipProtoRecord for
 a given relationship description. This returns NO if there is already a relationshipProtoRecord for
 that relationship. In the case of to-many relationships this will always return YES.
 @param relationshipDescription The relationship to determine accomodations for.
 @return NO if there is already a valid relationshipProtoRecord for a given relationshipDescription
 @discussion In the case of to-many relationships this will always return YES.
 */
- (BOOL)canAccomodateAdditionalProtoRecordForRelationshipDescription:(NSRelationshipDescription *)relationshipDescription;

/**
 Returns the proto records for a given relationship description.
 @param relationshipDescription The relationship to request proto records for.
 @return An array of proto records for the given relationship.
 */
- (NSArray *)relationshipProtoRecordsForRelationshipDescription:(NSRelationshipDescription *)relationshipDescription;

@end
