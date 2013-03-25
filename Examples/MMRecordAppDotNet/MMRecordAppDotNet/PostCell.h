//
//  PostCell.h
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Post.h"

@interface PostCell : UITableViewCell

- (void)populateWithPost:(Post *)post;

+ (CGFloat)height;

@end
