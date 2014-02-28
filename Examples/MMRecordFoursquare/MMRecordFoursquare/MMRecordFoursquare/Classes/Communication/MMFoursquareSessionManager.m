//
//  MMFoursquareSessionManager.m
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/5/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMFoursquareSessionManager.h"

static NSString * const MMFoursquareAPIBaseURLString = @"https://api.foursquare.com/v2/";

@implementation MMFoursquareSessionManager

+ (instancetype)sharedClient {
    static MMFoursquareSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[MMFoursquareSessionManager alloc] initWithBaseURL:[NSURL URLWithString:MMFoursquareAPIBaseURLString]];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone]];
    });
    
    return _sharedClient;
}

+ (instancetype)serverClient {
    static MMFoursquareSessionManager *_serverClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serverClient = [[MMFoursquareSessionManager alloc] initWithBaseURL:[NSURL URLWithString:MMFoursquareAPIBaseURLString]];
        [_serverClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone]];
    });
    
    return _serverClient;
}

@end
