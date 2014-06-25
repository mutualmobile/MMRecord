//
//  MMRecordAtlassian.h
//  MMRecordAtlassian
//
//  Created by Conrad Stoll on 6/24/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMRecordAtlassian.Issue;

@interface MMRecordAtlassian : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) MMRecordAtlassian.Issue *issue;

@end
