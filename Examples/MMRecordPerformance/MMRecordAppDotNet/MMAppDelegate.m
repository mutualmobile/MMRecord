//
//  MMAppDelegate.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMAppDelegate.h"

#import "ADNRecord.h"
#import "MMJSONPerformanceTestingServer.h"
#import "MMJSONServer.h"

@implementation MMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MMJSONPerformanceTestingServer setResultSetSize:10000];
    [ADNRecord registerServerClass:[MMJSONPerformanceTestingServer class]];
    //[MMRecord setLoggingLevel:MMRecordLoggingLevelAll];
    
    return YES;
}

@end
