//
//  PostCell.m
//  MMRecordTwitter
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "TweetCell.h"

#import "User.h"

#import "AFNetworking.h"

@interface TweetCell ()

@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *tweetTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;

@end

@implementation TweetCell

- (void)populateWithTweet:(Tweet *)tweet {
    self.tweetTextLabel.text = tweet.text;
    self.userNameLabel.text = tweet.user.name;
    [self.avatarImageView setImageWithURL:tweet.user.avatarURL placeholderImage:[UIImage imageNamed:@"avatar.png"]];
}

@end
