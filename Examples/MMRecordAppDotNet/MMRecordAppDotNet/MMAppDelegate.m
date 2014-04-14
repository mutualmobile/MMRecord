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
#import "MMDataManager.h"
#import "FBMMRecordTweakModel.h"

@implementation MMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ADNServer registerAFHTTPClient:[ADNHTTPClient sharedClient]];
    [ADNRecord registerServerClass:[ADNServer class]];
    
    [FBMMRecordTweakModel loadTweaksForManagedObjectModel:[MMDataManager sharedDataManager].managedObjectModel];
    
    //[MMJSONServer registerResourceName:@"posts" forPathComponent:@"posts"];
    //[ADNRecord registerServerClass:[MMJSONServer class]];
    
    //[MMRecord setLoggingLevel:MMRecordLoggingLevelDebug];
    
    return YES;
}

@end
