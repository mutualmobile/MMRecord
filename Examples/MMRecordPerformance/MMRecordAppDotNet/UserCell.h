//
//  UserCell.h
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface UserCell : UITableViewCell

- (void)populateWithUser:(User *)user;

@end
