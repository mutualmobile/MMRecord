//
//  ADNRecord.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "ADNRecord.h"

static NSDateFormatter *ADNRecordDateFormatter;

@implementation ADNRecord

+ (NSString *)keyPathForResponseObject {
    return @"data";
}

+ (NSDateFormatter *)dateFormatter {
    if (!ADNRecordDateFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"]; // "2012-11-21T03:57:39Z"
        ADNRecordDateFormatter = dateFormatter;
    }
    
    return ADNRecordDateFormatter;
}

@end
