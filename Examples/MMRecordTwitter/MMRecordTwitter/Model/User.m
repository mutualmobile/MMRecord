//
//  User.m
//  MMRecordTwitter
//
//  Created by Conrad Stoll on 3/22/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "User.h"
#import "Tweet.h"


@implementation User

@dynamic avatarPath;
@dynamic id;
@dynamic name;
@dynamic tweets;

- (NSURL *)avatarURL {
    return [NSURL URLWithString:self.avatarPath];
}

@end
