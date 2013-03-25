//
//  MMSearchManager.h
//  MMRecordInstagram
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMInstagramManager.h"

@interface MMSearchManager : MMInstagramManager

- (id)initWithSearchString:(NSString *)text;

- (void)getNextPageOfResults;

@end
