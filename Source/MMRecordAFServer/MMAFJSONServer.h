//
//  MMAFHTTPServer.h
//  MMRecord
//
//  TODO: Replace with License Header
//

#import "MMServer.h"

@class AFHTTPClient;

/**
 This is a basic implementation of `MMServer` that uses a simple configuration along with an 
 AFHTTPClient as the backbone for making requests for MMRecord. This class allows you to register 
 your instance of an AFHTTPClient subclass to be used to make GET requests to whatever web server 
 it is configured for. The AFJSONRequestOperation will be used to make the requests sent to this 
 server, and the response JSON will be returned in the response block. Errors will get forwarded
 through the failureBlock if the request fails.
 
 This server implementation is not intended to be canonical. It is highly likely that this server 
 will not be sufficient for complex use cases and APIs. In those cases, it is highly recommended 
 that you subclass MMServer direction and provide your own implementation to fit your given API and 
 server. This implementation may be used as a guide to do that.
 
 ## AFNetworking
 
 AFNetworking is a highly popular iOS networking framework. AFNetworking is of course required to 
 use this server implementation. If you do not have AFNetworking linked in your project, this server 
 will not work.
 
 ## Batching
 
 This server implementation does support batching. If the request batching system in MMRecord is 
 used, then those requests will be batched using the AFHTTPClient supplied in the register method.
 
 ## Cancellation
 
 This server implementation does support cancellation. In this case, the class name of the domain 
 object is associated with the AFJSONRequestOperation. If the server is asked to cancel requests 
 for a given domain, all AFJSONRequestOperations associated with that domain will be cancelled.
 
 ## Pagination
 
 This server implementation does NOT support pagination. You may, however, subclass this server 
 class to provide your own page manager class, which will then support pagination.
 */

@interface MMAFJSONServer : MMServer

/**
 This method can be used to register an instance of an AFHTTPClient.
 
 @param client The client this server should use to make requests.
 @return YES if the client was successfully registered. No otherwise.
 */
+ (BOOL)registerAFHTTPClient:(AFHTTPClient *)client;

@end
