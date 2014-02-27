//
//  MMAppDelegate.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMAppDelegate.h"

#import "ADNHTTPClient.h"
#import "ADNRecord.h"
#import "ADNServer.h"
#import "MMJSONServer.h"

@implementation MMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ADNServer registerAFHTTPClient:[ADNHTTPClient sharedClient]];
    [ADNRecord registerServerClass:[ADNServer class]];
    
    //[MMJSONServer registerResourceName:@"posts" forPathComponent:@"posts"];
    //[ADNRecord registerServerClass:[MMJSONServer class]];
    
    [MMRecord setLoggingLevel:MMRecordLoggingLevelInfo];
    
    return YES;
}

@end
