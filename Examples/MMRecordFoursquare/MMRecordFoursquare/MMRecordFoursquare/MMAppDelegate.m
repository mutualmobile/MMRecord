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

/*
 This appDelegate initialization implementation is customized to set up two different MMRecord
 stack configurations. This example uses MMRecord both in the traditional way, with a subclass of
 MMServer that gets used to make requests via MMRecord's request entry points. It also implements
 an example using the AFMMRecordResponseSerializer, where requests are made through an
 AFNetworking 2.0 session manager.
*/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // AFMMRecordSessionManagerServer Example
    MMFoursquareSessionManager *serverClientManager = [MMFoursquareSessionManager serverClient];

    [AFMMRecordSessionManagerServer registerAFHTTPSessionManager:serverClientManager];
    [FSRecord registerServerClass:[AFMMRecordSessionManagerServer class]];
    
    // AFMMRecordResponseSerializer Example
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
    
    //[MMRecord setLoggingLevel:MMRecordLoggingLevelAll];
    
    return YES;
}

@end
