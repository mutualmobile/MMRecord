//
//  Post.h
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "ADNRecord.h"

@class ADNPageManager;
@class Source;
@class User;

@interface Post : ADNRecord

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * thread_id;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Source *source;

// A method for returning the latest 20 posts from the global app.net stream.
// Please see the ADNPageManager for methods to update the stream of posts.
+ (void)getStreamPostsWithContext:(NSManagedObjectContext *)context
                           domain:(id)domain
                      resultBlock:(void (^)(NSArray *posts))resultBlock
                     failureBlock:(void (^)(NSError *error))failureBlock;

@end
