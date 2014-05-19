//
//  MMFoursquareSessionManager.h
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/5/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface MMFoursquareSessionManager : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
