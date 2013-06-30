//
//  Tweet.m
//  MMRecordTwitter
//
//  Created by Conrad Stoll on 3/22/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "Tweet.h"
#import "User.h"


@implementation Tweet

@dynamic id;
@dynamic text;
@dynamic user;

- (BOOL)isFavorite {
    return [[self primitiveValueForKey:@"favorited"] boolValue];
}

@end
