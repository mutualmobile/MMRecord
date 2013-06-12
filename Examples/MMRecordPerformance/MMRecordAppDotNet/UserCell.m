//
//  UserCell.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "UserCell.h"

#import "AFNetworking.h"
#import "Counts.h"
#import "User.h"

@interface UserCell ()

@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *countsLabel;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;

@end

@implementation UserCell

- (void)populateWithUser:(User *)user {
    self.userNameLabel.text = user.name;
    self.countsLabel.text = [user.counts formattedCountString];
    [self.avatarImageView setImageWithURL:user.avatarURL placeholderImage:[UIImage imageNamed:@"avatar.png"]];
}

@end