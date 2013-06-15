//
//  PostCell.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "PostCell.h"

#import "AFNetworking.h"
#import "Source.h"
#import "User.h"

static NSDateFormatter *Post_dateFormatter;

@interface PostCell () <UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *postTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIButton *clientButton;

@property (nonatomic, copy) NSString *clientName;
@property (nonatomic, strong) NSURL *clientURL;

@end

@implementation PostCell

- (NSDateFormatter *)dateFormatter {
    if (Post_dateFormatter != nil) {
        return Post_dateFormatter;
    }
    
    Post_dateFormatter = [[NSDateFormatter alloc] init];
    [Post_dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [Post_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return Post_dateFormatter;
}

- (void)populateWithPost:(Post *)post {
    self.postTextLabel.text = post.text;
    self.userNameLabel.text = post.user.name;
    [self.avatarImageView setImageWithURL:post.user.avatarURL placeholderImage:[UIImage imageNamed:@"avatar.png"]];
    [self.clientButton setTitle:post.source.name forState:UIControlStateNormal];
    
    NSDateFormatter *dateFormatter = [self dateFormatter];
    self.dateLabel.text = [dateFormatter stringFromDate:post.date];
    
    if (post.source.link != nil && post.source.name != nil) {
        self.clientURL = [NSURL URLWithString:post.source.link];
        self.clientName = post.source.name;
    } else {
        self.clientURL = nil;
        self.clientName = nil;
    }
}

+ (CGFloat)height {
    return 80.0f;
}

- (IBAction)tappedClientButton:(id)sender {
    if (self.clientURL) {
        NSString *message = [NSString stringWithFormat:@"Would you like to open Safari to check out %@?", self.clientName];
        
        [[[UIAlertView alloc] initWithTitle:@"Open Safari" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Open Safari", nil] show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[UIApplication sharedApplication] openURL:self.clientURL];
    }
}

@end
