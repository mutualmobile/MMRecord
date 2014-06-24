// MMRecordRepresentation.h
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

/**
 This class encapsulates the representation an MMRecord entity.  A representation contains 
 all of the information required to build a full record of this type of entity.  
 MMRecordRepresentation is closely tied to CoreData's NSEntityDescription. The representation is 
 composed of all of the attributes and relationships for the given entity.  It's job is to keep 
 track of all the possible keys that could 'represent' that attribute or relationship in a response 
 dictionary.  If you're trying to figure out what keyPath might map to a record attribute, this 
 class can help.
 
 ## Default Representation
 
 The default representation is, as described above, very closely tied to the core data model. An 
 entity is composed of a list of properties - typically attributes and relationships. The default 
 representation will attempt to relate each attribute on an entity to a given dictionary. It will
 use two means to relate them: name, and alternate name. The name of the attribute or relationship 
 will be used as a key to search the dictionary for a value to populate it with. In addition, you 
 can define a key on the attribute or relationship's user info dictionary that allows you to specify
 an alternate key path that will be used for searching the dictionary. More information about that 
 can be found on the MMRecord header documentation on model configuration.
 
 ## Marshalling
 
 This class is closely related to the MMRecordMarshaler class. Generally speaking, if you subclass
 this class, you will probably also want to subclass the marshaler, and vic versa. While this class 
 controls the representation of an entity, the marshaler controls how it is populated. Those two 
 things tend to go hand in hand, which is also why this class provides the subclass of Marshaler 
 to be used when populating an entity using this representation.
 
 ## Subclassing Notes
 
 This class is designed to be subclassed. While you don't have to override the designated 
 initializer, you must remember to call super if you do decide to override it. All of the other
 methods are optional. With many of them, you will want to call super. Most of the time, subclassers
 will probably only want to modify behavior slightly, such as to allow other ways to specify
 alternate attributes. You can, of course, choose to override every method, and provide a completely 
 different form of representation. That will still work, but in that case, you MUST override every 
 single method if you wish to drastically change the way the default representation works.
 
 Every method on the class except for one is part of the public interface and called by another
 piece of the default MMRecord implementation. The only method which is not is the 
 -setupMappingForProperty: method, which is documented below. In depth subclasses should choose to 
 override EVERY method except that one.
 */

@interface MMRecordRepresentation : NSObject

/**
 The entity that this object is representing.
 */
@property (nonatomic, strong, readonly) NSEntityDescription *entity;

///-----------------------------
/// @name Designated Initializer
///-----------------------------

/**
 This method is the `MMRecordRepresentation` designated initializer.
 
 @param entity The entity that this object is representing.
 */
- (instancetype)initWithEntity:(NSEntityDescription *)entity;


///------------------
/// @name Marshalling
///------------------

/**
 This is an optional method that a subclass can override to supply a different marshalling class. The
 marshalling class is responsible for populating a protorecord based on input from the representation.
 The default marshal class is MMRecordMarshaler.  A subclass may want to use a different marshaler
 to provide custom behavior for how attributes and relationships are established.
 
 @return A subclass of MMRecordMarshaler that implements all required methods of that class's interface.
 @discussion The default implementation of this class returns MMRecordMarshaler.
 */
- (Class)marshalerClass;


///----------------------
/// @name Date Formatting
///----------------------

/** 
 This method returns the date formatter used for populating date objects for this entity type.
 
 @discussion This date formatter will be used for populating attributes of type Date.
 */
- (NSDateFormatter *)dateFormatter;


///--------------------------------
/// @name Attribute Mapping Methods
///--------------------------------

/**
 This method returns all of the attribute descriptions for the entity.
 
 @return An NSArray containing every `NSAttributeDescription` for this entity.
 */
- (NSArray *)attributeDescriptions;

/**
 This method returns the possible key paths to search for in order to populate the given attribute 
 description.
 
 @param attributeDescription The attribute description we are mapping key paths for.
 @return An NSArray containing the key paths for mapping this attribute description.
 */
- (NSArray *)keyPathsForMappingAttributeDescription:(NSAttributeDescription *)attributeDescription;


///-----------------------------------
/// @name Relationship Mapping Methods
///-----------------------------------

/**
 This method returns all of the relationship descriptions for the entity.
 
 @return An NSArray containing every `NSRelationshipDescription` for this entity.
 */
- (NSArray *)relationshipDescriptions;

/** 
 This method returns all of the possible key paths to search for in order to populate the given 
 relationship description.
 
 @param relationshipDescription The relationship description we are mapping key paths for.
 @return An NSArray containing the key paths for mapping this relationship description.
 */
- (NSArray *)keyPathsForMappingRelationshipDescription:(NSRelationshipDescription *)relationshipDescription;


///---------------------------------------------
/// @name Optional Mapping Configuration Methods
///---------------------------------------------

/**
 This is an optional method meant for overriding subclasses to define their own key path mappings
 for a property. A basic representation would only look for the name of a property when attempting
 to populate it. More advanced representations may use this to return alternate keys that they may
 wish to also use.
 
 @param propertyDescription The property description to be used to return additional key paths for.
 @return Any additional key paths that should be used for mapping on the given property description.
 */
- (NSArray *)additionalKeyPathsForMappingPropertyDescription:(NSPropertyDescription *)propertyDescription;

/**
 This method is called to set up the internal mapping system for the given property. This can be a
 convenient method to override if you wish to take additional action when configuring this property.
 For example, you may wish to add your own configuration for other methods to use when populating
 this property. Overriding this method allows you to do that.
 
 @param property The property description.
 @warning You MUST call super when overriding this method.
 @discussion This method is not part of the "public interface" of this class. It is called
 internally by the default implementation, and is meant as an override point for inserting logic.
 If you completely override every other method on this class, then you do not need to override this 
 one.
 */
- (void)setupMappingForProperty:(NSPropertyDescription *)property;


///------------------------------------
/// @name Unique Identification Methods
///------------------------------------

/**
 This method returns the name of the primary key property for this entity.
 */
- (NSString *)primaryKeyPropertyName;

/**
 This method is responsible for determining the name of the primary key property given the entity
 description for this instance of an MMRecordRepresentation.
 @param entity The entity description for this representation.
 @return The name of the primary key property for this entity.
 @discussion This method is designed to be subclassed if the user wishes to provide a different way
 of determining which property to use as the primary key for a given type of entity.
 @warning This method is called once per entity or superentity until a primary key is found, or no
 further superentity exists for a given entity. It is in this way that this class supports entity
 inheritance, meaning that if no primary key property is designated on an entity then the class will
 go through the chain of superentities to see if a primary key exists there.
 */
- (NSString *)primaryKeyPropertyNameForEntityDescription:(NSEntityDescription *)entity;

/**
 This method returns the primary key attribute description for this entity. This method will return
 nil if the entity uses a relationship for its primary key.
 */
- (NSAttributeDescription *)primaryAttributeDescription;

/**
 This method should return either a number or string that represents the primary key value as
 obtained from the given dictionary.  It should return nil if this entity is using a relationship as
 its primary key.
 
 @param dictionary The dictionary that contains the primary key value.
 @return The primary key value from the given dictionary.
 */
- (id)primaryKeyValueFromDictionary:(NSDictionary *)dictionary;

/** 
 This method is used to check if this entity has a relationship as it's primary key.
 
 @return YES if the entity's primary key is a relationship
 */
- (BOOL)hasRelationshipPrimaryKey;

/**
 This method returns the primary relationship representation if the entity uses a relationship as a
 primary key
 
 @return The `NSRelationshipDescription for the entity's primary key relationship.
 */
- (NSRelationshipDescription *)primaryRelationshipDescription;

@end
