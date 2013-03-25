//
//  ADNHTTPClient.h
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "AFHTTPClient.h"

@interface ADNHTTPClient : AFHTTPClient

+ (ADNHTTPClient *)sharedClient;

@end
