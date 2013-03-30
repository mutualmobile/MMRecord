// MMJSONServer.m
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

#import "MMJSONServer.h"

@interface NSString (MMJSONServerContains)

- (BOOL)MMJSONServer_containsString: (NSString*) substring;

@end

static NSMutableDictionary* MM_registeredResourceNames;

@implementation MMJSONServer

+ (NSString*)resourceNameForURN:(NSString*)URN {
    return [self registeredResourceNameFromPathComponentsForURN:URN];
}

+ (NSMutableDictionary *)registeredResourceNamesWithPathComponents {
    return nil;
}

+ (NSString *)registeredResourceNameFromPathComponentsForURN:(NSString *)URN {
    NSMutableDictionary *dict = [self registeredResourceNames];

    for (NSString *key in [dict allKeys]) {
        if ([URN MMJSONServer_containsString:key]) {
            return [dict objectForKey:key];
        }
    }
    
    return nil;
}

+ (NSMutableDictionary *)registeredResourceNames {
    if ([self registeredResourceNamesWithPathComponents] != nil) {
        MM_registeredResourceNames = [self registeredResourceNamesWithPathComponents];
        return MM_registeredResourceNames;
    }
    
    if (MM_registeredResourceNames != nil) {
        return MM_registeredResourceNames;
    }
    
    MM_registeredResourceNames = [NSMutableDictionary dictionary];
    return MM_registeredResourceNames;
}

+ (void)registerResourceName:(NSString *)resourceName
            forPathComponent:(NSString *)pathComponent {
    NSMutableDictionary *dict = [self registeredResourceNames];
    [dict setObject:resourceName forKey:pathComponent];
}

+ (BOOL)shouldSimulateServerDelay {
    return NO;
}

+ (NSTimeInterval)simulatedServerDelayTime {
    return 0.1;
}

+ (id)dataForJSONResource:(NSString *)resourceName error:(NSError **)error{
	id data = nil;
    
    NSURL *jsonURL = [[NSBundle mainBundle] URLForResource:resourceName withExtension:@"json"];
    
	if (jsonURL != nil) {
        NSError* parsingError = nil;
        NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL options:NSDataReadingUncached error:&parsingError];
        if (jsonData != nil) {
            NSError *jsonError;
            data = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonError];
            if (data == nil) {
                NSLog(@"JSON error: %@", parsingError);
                
                if (error != nil)
                    *error = parsingError;
            }
        }
	}
	
	return data;
}

+ (void)simulateServerDelayWithBlock:(void(^)(void))block {
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, [self simulatedServerDelayTime] * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		block();
	});
}

+ (void)loadJSONResource:(NSString *)resourceName
           responseBlock:(void(^)(NSDictionary *responseData))responseBlock
            failureBlock:(void(^)(NSError *error))failureBlock {
    if (resourceName != nil) {
        NSError *parsingError = nil;
        
        NSDictionary *responseObject = [self dataForJSONResource:resourceName error:&parsingError];
        
        void (^delayBlock)(void) = ^(void) {
            if (parsingError != nil) {
                if (failureBlock != nil) {
                    failureBlock(parsingError);
                }
            } else {
                if (responseBlock != nil) {
                    responseBlock(responseObject);
                }
            }
		};

        if ([self shouldSimulateServerDelay]) {
            [self simulateServerDelayWithBlock:delayBlock];
        } else {
            delayBlock();
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"com.mutualmobile.mmserver" code:0 userInfo:nil];
        
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }
}

+ (void)cancelRequests {
    
}

+ (void)startRequestWithURN:(NSString *)URN
                       data:(NSDictionary *)data
                      paged:(BOOL)paged
                     domain:(id)domain
                    batched:(BOOL)batched
              dispatchGroup:(dispatch_group_t)dispatchGroup
              responseBlock:(void (^)(id responseObject))responseBlock
               failureBlock:(void (^)(NSError *error))failureBlock {
    [self loadJSONResource:[self resourceNameForURN:URN]
             responseBlock:responseBlock
              failureBlock:failureBlock];
}

@end


@implementation NSString(MMJSONServerContains)

- (BOOL)MMJSONServer_containsString:(NSString *)substring {
    NSRange range = [self rangeOfString : substring];
    BOOL found = (range.location != NSNotFound);
    return found;
}

@end