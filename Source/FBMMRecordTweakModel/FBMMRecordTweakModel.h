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
 
 This class does not need to be initialized. The loadTweaksForManagedObjectModel method should be
 called before any requests will need to be run.
 */
@interface FBMMRecordTweakModel : NSObject

/**
 This method will load the set of tweaks for the given managed object model. It will traverse the
 list of entities and create the tweaks as outlined above.
 @param model The Core Data managed object model you are using for MMRecord.
 @warning This method must be executed in order for MMRecord tweaks to work.
 */
+ (void)loadTweaksForManagedObjectModel:(NSManagedObjectModel *)model;

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

@end
