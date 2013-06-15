//
//  User.h
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "ADNRecord.h"

@class Counts;
@class Post;

@interface User : ADNRecord

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * avatarImagePath;
@property (nonatomic, retain) NSString * coverImagePath;
@property (nonatomic, retain) NSSet *posts;
@property (nonatomic, retain) Counts *counts;

@property (nonatomic, readonly) NSURL *avatarURL;
@property (nonatomic, readonly) NSURL *coverURL;

+ (void)searchForUsersWithName:(NSString *)name
                       context:(NSManagedObjectContext *)context
                        domain:(id)domain
                   resultBlock:(void(^)(NSArray *users, BOOL requestComplete))resultBlock
                  failureBlock:(void(^)(NSError *error))failureBlock;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addPostsObject:(Post *)value;
- (void)removePostsObject:(Post *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
