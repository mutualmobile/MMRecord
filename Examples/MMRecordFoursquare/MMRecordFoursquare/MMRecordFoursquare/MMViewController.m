//
//  MMViewController.m
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/5/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMViewController.h"

#import "MMFoursquareSessionManager.h"

#import "Venue.h"

@interface MMViewController ()

@property (nonatomic, weak) IBOutlet UILabel *venueLabel;

@end

@implementation MMViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *oAuthToken = @"RMRLHPHOTZBIHKAX2G1XMZ33XQYDYKVCAUTM5GCTAA03X04F";
    
    [[MMFoursquareSessionManager sharedClient]
     GET:@"venues/40a55d80f964a52020f31ee3"
     parameters:@{@"oauth_token": oAuthToken, @"v": @"20131105"}
     success:^(NSURLSessionDataTask *task, id responseObject) {
         NSArray *venues = responseObject;
         
         Venue *venue = [venues firstObject];
         
         self.venueLabel.text = venue.name;
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         
     }];
}

@end
