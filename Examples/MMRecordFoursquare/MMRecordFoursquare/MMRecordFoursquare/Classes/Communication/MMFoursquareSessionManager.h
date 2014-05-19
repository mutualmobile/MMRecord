//
//  MMFoursquareSessionManager.h
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/5/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface MMFoursquareSessionManager : AFHTTPSessionManager

/**
 A shared instance of the AFHTTPSessionManager configured for the foursquare API. This instance of
 the session manager is intended to be used as an example for the AFMMRecordResponseSerializer, and
 will be configured with that response serializer such that it returns MMRecord subclasses in the
 response object.
 */
+ (instancetype)sharedClient;

/**
 A shared instance of the AFHTTPSessionManager configured for the foursquare API. This instance of
 the session manager is intended to be used as an example for the AFMMRecordSessionManagerServer,
 and will be configured normally to return a standard dictionary/array response object such that
 it will function normally for the session manager server MNMRecord example.
 */
+ (instancetype)serverClient;

@end
