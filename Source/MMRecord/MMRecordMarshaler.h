// MMRecordMarshaler.h
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

#import <CoreData/CoreData.h>

@class MMRecord;
@class MMRecordProtoRecord;

/** 
 This class is the main sheriff in town for populating an instance of MMRecord. This class holds
 no state but takes as parameters the proto records which hold all of the information necesary to
 populate the record that they hold. This class is meant to be subclassed, although this is the base
 implementation of the marshaler. The class that will be used to marshal a record of a given type of
 entity is defined in the `MMRecordRepresentation`. In that sense, the marshaler is somewhat tied to
 the representation. This allows the user even more flexibility in their representations such that
 they can actually change the population mechanism used for individual entities in MMRecord.
 
 ## Default Implementation
 
 The default implementation of the marshaler populates all attributes on the given proto record's 
 instance of MMRecord as defined by that proto record's representation. The marshal will ask the 
 representation for the list of attributes, and attempt to populate all of them using the 
 +populateProtoRecord:attributeDescription:fromDictionary method. By default, that method will call
 the +setValue method for the attribute using the first valid key which obtains a value from the 
 dictionary.
 
 The default implementation of the marshaler will also establish each relationship as similarly 
 defined by the proto record's representation.
 
 ## Subclassing Notes
 
 A good reason to subclass the marshaler would be to change the way population events occur in 
 MMRecord. For example, if you wanted to change the behavior for how numbers and strings are 
 populated, you could create a custom marshaler. If you wanted the ability to create more
 specialized date population, you could create a custom marshaler. If you want to change how
 transformable attributes are populated, or perhaps add support for storing the entire dictionary or
 a different value entirely in an attribute, then creating a custom marshaler through subclassing is
 definitely a route you should explore.
 
 Another option for subclassing is to subclass to provide an extension of functionality rather than 
 different functionality. For example, you may choose to conditionally establish a relationship 
 based on certain logic, like the existence or value of some fields. Or you may want to delete 
 certain relationships or remove existing objects from a to-many relationship as part of the 
 population process. Subclassing the marshaler gives you the flexibility to do that. In effect, 
 it allows you to build in pre-post process hooks into the population process. This is very powerful.
 
 ## Subclassing Instructions
 
 While a user wishing to subclass the marshal may override any method they choose, the three methods
 at the bottom may make the most sense to override in a subclass. These methods are called 
 internally by the marshaler itself to actually perform the actions described above. The top three 
 methods are intended to be the public interface of the `MMRecordMarshaler` class, and though they 
 can be overriden, are not necesarily recommended to be changed.
 */

@interface MMRecordMarshaler : NSObject

///-------------------------------
/// @name Public Interface Methods
///-------------------------------

/**
 This method initiates the attribute population process for the given proto record. It will iterate 
 through the attributes provided by the proto record's representation and attempt to populate each 
 one.
 
 @param protoRecord The proto record that we wish to populate.
 */
+ (void)populateProtoRecord:(MMRecordProtoRecord *)protoRecord;

/**
 This method initiates the process of establishing relationships to all of the relationship protos 
 for the given proto record. It will iterate through the relationship protos associated to the proto 
 record and attempt to establish a relationship with each of them.
 
 @param protoRecord The proto record whose relationships we wish to establish.
 */
+ (void)establishRelationshipsOnProtoRecord:(MMRecordProtoRecord *)protoRecord;


/** 
 This method is used when the given proto record uses a relationship as it's primary means of 
 identification. It will establish the primary relationship to the given primary key proto record. 
 The relationship primary key proto record should be associated with a parent object of the proto 
 record's instance of `MMRecord`.
 
 @param protoRecord The proto record which we want to establish a primary key relationship for.
 @param parentRelationshipPrimaryKeyProto The proto record that represents both the primary key 
 proto for the given proto record, as well as a parent object to the given proto record.
 @discussion For more about primary key relationships, please see the header file for `MMRecord`.
 */
+ (void)establishPrimaryKeyRelationshipFromProtoRecord:(MMRecordProtoRecord *)protoRecord
             toParentRelationshipPrimaryKeyProtoRecord:(MMRecordProtoRecord *)parentRelationshipPrimaryKeyProto;

/**
 This method is used when a response contains multiple instances of the same record. MMRecord will
 always do its best to create and populate these records and associate them with the appropriate
 relationships on various other records. Generally speaking, its expected that a response will
 contain either duplicate references to record primary keys, which allow MMRecord to fetch the
 appropriate record to associate as a relationship. Or, the response may contain duplicate fully
 saturated objects. In this case, the first fully saturated object will "win", and all other 
 references to that object will be populated using the first one that is found.
 
 This method is intended as a means to merge those various different response objects together to
 create a master instance of a particular record. In some responses an object may contain a subset
 of data in one place, and a larger subset of data in another place. In those instances, a user
 may want for the larger subset to win, even if it wasn't found by MMRecord first.
 
 You may override this method in a subclass of MMRecordMarshaler to provide this functionality.
 @param dictionary The dictionary for the n+1th record response object of a given type and 
 primary key.
 @param protoRecord The proto record created to represent this specific object by MMRecord.
 @discussion The default implementation of this method will look for cases where a given record is
 only identified by a primary key and includes no additional data to populate it with. In this case
 the primary key of that original proto record will be compared with the incoming object dictionary
 and if they match then the new dictionary will be associated with the proto record.
 @warning If you decide to subclass this method you may want to use the super implementation
 as a starting point for your own implementation. Calling super is not required, but is recommended.
 */
+ (void)mergeDuplicateRecordResponseObjectDictionary:(NSDictionary *)dictionary
                             withExistingProtoRecord:(MMRecordProtoRecord *)protoRecord;


///---------------------------------
/// @name Public Subclassing Methods
///---------------------------------

/** 
 This method is designed to be subclassed. It should be called to handle the population of a 
 specific attribute from a given dictionary for a particular record on the given proto record. 
 The basic implementation of this will call +setValue: with a value obtained from the given 
 dictionary based on possible key paths from the proto's representation. However, a subclass may 
 want to provide custom behavior, which is what this method is intended to be used for.
 
 @param protoRecord The proto record that we wish to populate an attribute for.
 @param attributeDescription The attribute that we wish to populate.
 @param dictionary The set of values we have to choose from when populating this proto record.
 */
+ (void)populateProtoRecord:(MMRecordProtoRecord *)protoRecord
       attributeDescription:(NSAttributeDescription *)attributeDescription
             fromDictionary:(NSDictionary *)dictionary;

/**
 This method is designed to be subclassed. It should be used to set the value of an attribute on an 
 instance of MMRecord. The value should be predetermined by another method. By default this is done 
 in the +populateProtoRecord: method defined above. The attribute is used to provide the type that 
 the attribute represents. Population of different types is handled in different ways. Overriding 
 this method allows you to change how different types of attributes are populated.
 
 @param rawValue The RAW value to set on the record for the given attribute. This method may choose to 
 modify the raw value, depending on the type of attribute.
 @param record The record to set a value on.
 @param attribute The attribute to set a value for.
 @param dateFormatter The date formatter to use for populating a Date attribute.
 @discussion The base implementation of this method supports all types of attributes, including date 
 and transformable. Populating a transformable attribute will invoke a NSValueTransformer subclass 
 as defined in the Core Data model.
 */
+ (void)setValue:(id)rawValue
        onRecord:(MMRecord *)record
       attribute:(NSAttributeDescription *)attribute
   dateFormatter:(NSDateFormatter *)dateFormatter;

/**
 This method is designed to be subclassed. It is used to supply the properly formatted value for the
 setValue: method above. The term "formatted" can mean different things for different types of
 attributes. For date attributes that may mean applying a date formatter, or for transformed
 attributes applying a value transformer. Or it may mean something entirely different based on the
 needs of your application. Thats why its a public method - to allow you to subclass and provide
 custom behavior as necessary.
 
 A best practice when using this method is to treat the passed in raw value as the default. If you
 have nothing to do to that value, then just return it directly. Generally speaking you will not
 want to return nil from this method. The rawValue passed will never be nil.
 
 Another best practice is to call super if you are only customizing the logic for one type of
 attribute. Create a condition on that attribute type, and if its not met, simply return the result
 of super's implementation.
 
 @param attribute The attribute to return a formatted value for.
 @param rawValue The raw value as determined by the populateProtoRecord: method for this record.
 @param dateFormatter The date formatter to use for formatting a Date attribute.
 */
+ (id)valueForAttribute:(NSAttributeDescription *)attribute
               rawValue:(id)rawValue
          dateFormatter:(NSDateFormatter *)dateFormatter;

/**
 This method is designed to be subclassed. It should be used to establish a given relationship from 
 one record to another. Subclassing this method allows you to change the means by which a 
 relationship is established, and possibly inject other logic to come before or after the 
 establishment of that relationship.
 
 @param relationship The relationship to be established.
 @param fromRecord The first record, to establish the relationship from.
 @param toRecord The second record, to establish the relationship to.
 @discussion Basically this does exactly what you think based on how it reads. 
 Establish a relationship from one record to another.
 @discussion This method has a lot of potential for subclassing. It allows you to do things like 
 conditionally set relationships based on property values elsewhere in the record, or to clear out
 fields based on other parameters. Overall, this is extremely powerful. Use this wisely.
 */
+ (void)establishRelationship:(NSRelationshipDescription *)relationship
                   fromRecord:(MMRecord *)fromRecord
                     toRecord:(MMRecord *)toRecord;

@end
