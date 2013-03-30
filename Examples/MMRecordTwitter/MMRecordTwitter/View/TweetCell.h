//
//  TweetCell.h
//  MMRecordTwitter
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Tweet.h"

@interface TweetCell : UITableViewCell

- (void)populateWithTweet:(Tweet *)tweet;

@end
