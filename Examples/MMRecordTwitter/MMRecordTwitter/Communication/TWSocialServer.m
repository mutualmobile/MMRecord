//
//  TWServer.m
//  MMRecordTwitter
//
//  Created by Conrad Stoll on 3/22/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "TWSocialServer.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

@implementation TWSocialServer

+ (void)startRequestWithURN:(NSString *)URN
                       data:(NSDictionary *)data
                      paged:(BOOL)paged
                     domain:(id)domain
                    batched:(BOOL)batched
              dispatchGroup:(dispatch_group_t)dispatchGroup
              responseBlock:(void (^)(id))responseBlock
               failureBlock:(void (^)(NSError *))failureBlock {
    NSString *text = @"snow";
    NSString *maxIdString = nil;
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    //  Step 1:  Obtain access to the user's Twitter accounts
    ACAccountType *twitterAccountType = [accountStore
                                         accountTypeWithAccountTypeIdentifier:
                                         ACAccountTypeIdentifierTwitter];
    
    [accountStore
     requestAccessToAccountsWithType:twitterAccountType
     options:NULL
     completion:^(BOOL granted, NSError *error) {
         if (granted) {
             //  Step 2:  Create a request
             NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
             NSString *fullURL = [NSString stringWithFormat:@"https://api.twitter.com/1.1/%@", URN];
             NSURL *url = [NSURL URLWithString:fullURL];
             NSMutableDictionary *params = [NSMutableDictionary dictionary];
             [params setObject:@"100" forKey:@"count"];
             [params setObject:text forKey:@"q"];
             
             if(maxIdString != nil) {
                 [params setObject:maxIdString forKey:@"since_id"];
             }
             
             SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                     requestMethod:SLRequestMethodGET
                                                               URL:url
                                                        parameters:params];
             [request setAccount:[twitterAccounts lastObject]];
             
             //  Step 3:  Execute the request
             [request performRequestWithHandler:^(NSData *responseData,
                                                  NSHTTPURLResponse *urlResponse,
                                                  NSError *error) {
                 if (responseData) {
                     if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                         NSError *jsonError;
                         NSDictionary *searchData;
                         searchData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                      options:NSJSONReadingAllowFragments
                                                                        error:&jsonError];
                         
                         if (searchData != nil) {
                             if (responseBlock != nil) {
                                 responseBlock(searchData);
                             }
                         } else {
                             if (failureBlock != nil) {
                                 failureBlock(error);
                             }
                         }
                     }
                     else {
                         if (failureBlock != nil) {
                             failureBlock(error);
                         }
                     }
                 }
             }];
         } else {
             if (failureBlock != nil) {
                 failureBlock(error);
             }
         }
     }];
}

@end
