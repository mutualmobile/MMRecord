//
//  Source.h
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 1/12/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "ADNRecord.h"

@interface Source : ADNRecord

@property (nonatomic, retain) NSString * clientID;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;

@end
