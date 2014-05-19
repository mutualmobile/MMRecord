//
//  MMAppDelegate.m
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/5/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMAppDelegate.h"

#import "AFMMRecordResponseSerializer.h"
#import "AFMMRecordResponseSerializationMapper.h"
#import "AFMMRecordSessionManagerServer.h"
#import "FSRecord.h"
#import "MMDataManager.h"
#import "MMFoursquareSessionManager.h"

@implementation MMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    MMFoursquareSessionManager *serverClientManager = [MMFoursquareSessionManager sharedClient];

    [AFMMRecordSessionManagerServer registerAFHTTPSessionManager:serverClientManager];
    [FSRecord registerServerClass:[AFMMRecordSessionManagerServer class]];
    
    MMFoursquareSessionManager *sessionManager = [MMFoursquareSessionManager sharedClient];

    NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];
    AFHTTPResponseSerializer *HTTPResponseSerializer = [AFJSONResponseSerializer serializer];
    
    AFMMRecordResponseSerializationMapper *mapper = [[AFMMRecordResponseSerializationMapper alloc] init];
    [mapper registerEntityName:@"Venue" forEndpointPathComponent:@"venues/search?"];
    
    AFMMRecordResponseSerializer *serializer =
        [AFMMRecordResponseSerializer serializerWithManagedObjectContext:context
                                                responseObjectSerializer:HTTPResponseSerializer
                                                            entityMapper:mapper];
    
    sessionManager.responseSerializer = serializer;
    
    return YES;
}

@end
