// AFMMRecordResponseSerializationMapper.m
//
// Copyright (c) 2013 Mutual Mobile (http://www.mutualmobile.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFMMRecordResponseSerializationMapper.h"

@interface AFMMRecordResponseSerializationMapper ()

@property (nonatomic, strong) NSMutableDictionary *mapping;

@end

@implementation AFMMRecordResponseSerializationMapper

- (id)init {
    if ((self = [super init])) {
        _mapping = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)registerEntityName:(NSString *)entityName forEndpointPathComponent:(NSString *)endpoint {
    NSParameterAssert(entityName != nil);
    NSParameterAssert(endpoint != nil);
    
    [self.mapping setObject:entityName forKey:endpoint];
}


#pragma mark - Private Methods

- (BOOL)response:(NSURLResponse *)response containsPathComponentString:(NSString *)pathComponent {
    NSRange range = [[[response URL] absoluteString] rangeOfString:pathComponent];
    
    if (range.length != 0 && range.location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

- (NSEntityDescription *)entityName:(NSString *)entityName
                     mapsToEndPoint:(NSString *)endpoint
                       withResponse:(NSURLResponse *)response
                            context:(NSManagedObjectContext *)context {
    if ([self response:response containsPathComponentString:endpoint]) {
        return [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    }
    
    return nil;
}


#pragma mark - AFMMRecordResponseSerializationEntityMapping Methods

- (NSEntityDescription *)recordResponseSerializer:(AFMMRecordResponseSerializer *)serializer
                                entityForResponse:(NSURLResponse *)response
                                   responseObject:(id)responseObject
                                          context:(NSManagedObjectContext *)context {
    for (NSString *endpoint in self.mapping.allKeys) {
        NSString *entityName = [self.mapping objectForKey:endpoint];
        
        NSEntityDescription *entity = [self entityName:entityName
                                        mapsToEndPoint:endpoint
                                          withResponse:response
                                               context:context];
        
        if (entity != nil) {
            return entity;
        }
    }
    
    return nil;
}

@end
