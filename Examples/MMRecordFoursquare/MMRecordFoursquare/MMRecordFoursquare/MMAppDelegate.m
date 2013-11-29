//
//  MMAppDelegate.m
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/5/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMAppDelegate.h"

#import "MMDataManager.h"
#import "MMFoursquareSessionManager.h"
#import "MMFoursquareSerializationMapper.h"

@implementation MMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    MMFoursquareSessionManager *sessionManager = [MMFoursquareSessionManager sharedClient];
    
    NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];
    AFHTTPResponseSerializer *HTTPResponseSerializer = [AFJSONResponseSerializer serializer];
    MMFoursquareSerializationMapper *mapper = [[MMFoursquareSerializationMapper alloc] init];
    
    AFMMRecordResponseSerializer *serializer =
        [AFMMRecordResponseSerializer serializerWithManagedObjectContext:context
                                                responseObjectSerializer:HTTPResponseSerializer
                                                            entityMapper:mapper];
    
    sessionManager.responseSerializer = serializer;
    
    return YES;
}

@end
