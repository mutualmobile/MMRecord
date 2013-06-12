//
//  Counts.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "Counts.h"
#import "User.h"


@implementation Counts

@dynamic followers;
@dynamic following;
@dynamic posts;
@dynamic stars;
@dynamic user;

- (NSString *)formattedCountString {
    NSString *string = [NSString stringWithFormat:@"Followers: %@  Following: %@\nPosts: %@  Stars: %@", self.followers, self.following, self.posts, self.stars];
    return string;
}

@end
