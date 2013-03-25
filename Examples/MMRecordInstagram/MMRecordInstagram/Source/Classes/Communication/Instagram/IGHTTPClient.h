#import "AFHTTPClient.h"

@interface IGHTTPClient : AFHTTPClient

+ (IGHTTPClient *)sharedClient;

- (NSString *)clientID;

@end
