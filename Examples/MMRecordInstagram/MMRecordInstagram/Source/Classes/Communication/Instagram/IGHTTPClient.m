#import "IGHTTPClient.h"

#import "AFJSONRequestOperation.h"


static NSString * const kAFInstagramAPIBaseURLString = @"https://api.instagram.com/v1/";
static NSString * const kIGInstagramClientID = @"626443716cb74180a206de014ed4f3cf";

@interface IGHTTPClient ()
@property(nonatomic, assign) NSUInteger count;
@end

@implementation IGHTTPClient

+ (IGHTTPClient *)sharedClient {
    static IGHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient =
        [[IGHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kAFInstagramAPIBaseURLString]];
    });
    return _sharedClient;
}

- (NSString *)clientID {
    return kIGInstagramClientID;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    self.count = 0;
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters {
    self.count += 1;
    NSMutableDictionary *mutableParameters =
    [NSMutableDictionary dictionaryWithDictionary:parameters];
    mutableParameters[@"client_id"] = kIGInstagramClientID;
    return [super requestWithMethod:method path:path parameters:[mutableParameters copy]];
}

@end
