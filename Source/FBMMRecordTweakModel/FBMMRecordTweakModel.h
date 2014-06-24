//
// FBMMRecordTweakModel.h
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

#import <CoreData/CoreData.h>

@class FBTweak;
@class FBTweakCategory;
@class FBTweakCollection;

/**
 Important!
 
 You must include #define FBMMRecordTweakModelDefine in your project before changes made in Tweaks
 will take effect in MMRecord. This is disabled by default in order to give you the option to only
 enable tweaks in Release builds in production using Debug/Release build configurations.
*/

/**
 This class is responsible for creating a set of tweaks for a given Core Data model. The Core Data
 model will be traversed to create tweaks for every property of every entity on the model.
 
 The tweaks structure will be as follows:
 
 Tweak Category: MMRecord
    Tweak Collections: Entity Names
        Tweaks: Property Names
 
 Tweaks are identified using a dot notation.
 
 The identifier for a name property on a User entity will be:
 
 "User.name"
 
 Only the tweakForProperty and tweakIdentifierForProperty methods defined below should be used for
 accessing MMRecord tweak objects.
 
 This class does not need to be initialized. The +loadTweaksForManagedObjectModel method should be
 called before any requests will need to be run.
 */
@interface FBMMRecordTweakModel : NSObject

/**
 This method will load the set of tweaks for the given managed object model. It will traverse the
 list of entities and create the tweaks as outlined above. This method must be executed in order for
 MMRecord parsing behavior tweaks to appear in the tweaks menu.
 @param model The Core Data managed object model you are using for MMRecord.
 @warning This method MUST be executed in order for MMRecord tweaks to work.
 @warning Remember to include #define FBMMRecordTweakModelDefine to enable tweaked behaviors.
 */
+ (void)loadTweaksForManagedObjectModel:(NSManagedObjectModel *)model;


//////////////////////////////////////////////////////////////////////
// Methods for obtaining tweaked values for certain types of values //
//////////////////////////////////////////////////////////////////////

/**
 This method returns the tweaked string value for the keyPath of an entity. It will pull the tweak
 object for the given entity and return the current value of the tweak as long as that value is a
 valid string.
 @param entity The entity to request the tweaked value for.
 */
+ (NSString *)tweakedKeyPathForEntity:(NSEntityDescription *)entity;

/**
 This method returns the tweaked string value for the primary key of an entity. It will pull the
 tweak object for the given entity and return the current value of the tweak as long as that value
 is a valid string.
 @param entity The entity to request the tweaked value for.
 */
+ (NSString *)tweakedPrimaryKeyForEntity:(NSEntityDescription *)entity;

/**
 This method returns the tweaked string value for mapping the given attribute of the given entity.
 It will pull the tweak object for the given entity and return the current value of the tweak as
 long as that value is a valid string.
 @param attribute The attribute to request the mapping key path for.
 @param entity The entity to request the tweaked value for.
 */
+ (NSString *)tweakedKeyPathForMappingAttributeDescription:(NSAttributeDescription *)attribute
                                                    entity:(NSEntityDescription *)entity;

/**
 This method returns the tweaked string value for mapping the given relationship of the given entity.
 It will pull the tweak object for the given entity and return the current value of the tweak as
 long as that value is a valid string.
 @param relationship The relationship to request the mapping key path for.
 @param entity The entity to request the tweaked value for.
 */
+ (NSString *)tweakedKeyPathForMappingRelationshipDescription:(NSRelationshipDescription *)relationship
                                                       entity:(NSEntityDescription *)entity;


////////////////////////////////////////////////////////////////////////////
// Helper methods for obtaining tweak objects for certain types of values //
////////////////////////////////////////////////////////////////////////////

/**
 This method returns a tweak identifier for a given property and entity. The identifier for a name
 property on a User entity will be: "User.name".
 @param property The property description for a Core Data property on the given entity.
 @param entity The entity which the given property is on.
 */
+ (NSString *)tweakIdentifierForProperty:(NSPropertyDescription *)property
                                  entity:(NSEntityDescription *)entity;

/**
 This method returns an MMRecord tweak for a given property and entity.
 @discussion This is the primary accessor method for obtaining MMRecord tweak objects.
 @param property The property description for a Core Data property on the given entity.
 @param entity The entity which the given property is part of.
 */
+ (FBTweak *)tweakForProperty:(NSPropertyDescription *)property entity:(NSEntityDescription *)entity;


/**
 This method can be used for accessing the default MMRecord tweak category.
 */
+ (FBTweakCategory *)tweakCategory;

/**
 This is a convenience method for accessing the tweak collection for a given entity.
 @param entity The entity for which the tweak collection is being requested.
 */
+ (FBTweakCollection *)tweakCollectionForEntity:(NSEntityDescription *)entity;

/**
 This method returns the tweak object representing the primary key for a given entity. This tweak
 is intended to override the primary key that would normally be defined in the entity's user info
 dictionary.
 @param entity The entity to request the primary key tweak object for.
 */
+ (FBTweak *)tweakForPrimaryKeyForEntity:(NSEntityDescription *)entity;

/**
 This method returns the tweak object representing the keyPathForResponseObject for a given record
 class represented by an entity. This tweak is intended to override the keyPathForResponseObject
 that would normally be returned by an MMRecord subclass.
 @param entity The entity to request the keyPathForResponseObject tweak object for.
 */
+ (FBTweak *)tweakForKeyPathForEntity:(NSEntityDescription *)entity;

@end
