//
//  Media+DataAccess.m
//  MMRecordInstagram
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "Media+DataAccess.h"

@implementation Media (DataAccess)

- (NSURL *)mediaURL {
    return [NSURL URLWithString:[self.media valueForKeyPath:@"images.low_resolution.url"]];
}

@end
