//
//  MMVenueViewController.h
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 12/21/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Venue;

@interface MMVenueViewController : UITableViewController

@property (nonatomic, strong) Venue *venue;

@end
