//
//  User.h
//  MMRecordTwitter
//
//  Created by Conrad Stoll on 3/22/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "TWRecord.h"

@class Tweet;

@interface User : TWRecord

@property (nonatomic, retain) NSString * avatarPath;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *tweets;

@property (nonatomic, readonly) NSURL * avatarURL;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(Tweet *)value;
- (void)removeTweetsObject:(Tweet *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

@end
