//
//  Media+MMRecord.h
//  MMRecordInstagram
//
//  Created by Rene S Cacheaux on 3/20/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "Media.h"

@interface Media (MMRecord)

+ (void)getMediaWithSearchText:(NSString *)text
                   resultBlock:(void(^)(NSArray *media, id pageManager, BOOL *requestNextPage))resultBlock;

@end
