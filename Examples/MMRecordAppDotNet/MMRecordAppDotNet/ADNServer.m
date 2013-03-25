//
//  ADNServer.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "ADNServer.h"

#import "ADNPageManager.h"

@implementation ADNServer

+ (Class)pageManagerClass {
    return [ADNPageManager class];
}

@end
