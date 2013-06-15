//
//  User.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "User.h"
#import "Post.h"


@implementation User

@dynamic id;
@dynamic name;
@dynamic posts;
@dynamic avatarImagePath;
@dynamic coverImagePath;
@dynamic counts;

- (NSURL *)avatarURL {
    return [NSURL URLWithString:self.avatarImagePath];
}

- (NSURL *)coverURL {
    return [NSURL URLWithString:self.coverImagePath];
}

+ (NSString *)keyPathForResponseObject {
    return nil;
}

+ (void)searchForUsersWithName:(NSString *)name
                       context:(NSManagedObjectContext *)context
                        domain:(id)domain
                   resultBlock:(void (^)(NSArray *users, BOOL requestComplete))resultBlock
                  failureBlock:(void (^)(NSError *error))failureBlock {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@", name];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    [self
     startRequestWithURN:[NSString stringWithFormat:@"stream/0/users/%@", name]
     data:nil
     context:context
     domain:domain
     fetchRequest:fetchRequest
     customResponseBlock:nil resultBlock:^(NSArray *records, id customResponseObject, BOOL requestComplete) {
         if (resultBlock != nil) {
             resultBlock(records, requestComplete);
         }
     }
     failureBlock:failureBlock];
}

@end
