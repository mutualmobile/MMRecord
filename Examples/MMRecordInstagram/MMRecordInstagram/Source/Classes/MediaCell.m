//
//  MediaCell.m
//  MMRecordInstagram
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MediaCell.h"

#import "AFNetworking.h"
#import "Media.h"
#import "Media+DataAccess.h"
#import "Tag.h"

@interface MediaCell ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation MediaCell

- (void)populateWithMedia:(Media *)media {
    [self.imageView setImageWithURL:media.mediaURL];
}

@end
