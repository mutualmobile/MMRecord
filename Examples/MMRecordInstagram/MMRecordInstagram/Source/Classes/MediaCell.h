//
//  MediaCell.h
//  MMRecordInstagram
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaCell : UICollectionViewCell

- (void)populateWithMedia:(Media *)media;

@end
