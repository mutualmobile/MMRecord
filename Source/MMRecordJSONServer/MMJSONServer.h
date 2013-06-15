// MMJSONServer.h
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

#import "MMServer.h"

/** 
 This is a server class that returns responses from local JSON files. This is very useful early in 
 development, especially when you don't have a working real live server to test against. This class 
 is meant to be subclassed, although you can use the default implementation if you wish. The key to 
 this class is associating a resource file with a given URN. You can do this the easy way, or the 
 hard way, depending on how complex the API is that you want to represent in this manner.
 
 ## Components
 
 The easy way to use this class is by associating a given JSON resource file with a path component.
 A path component will typically be something like a RESTful endpoint, say for example, a People 
 endpoint. If the server gets a request for a URN containing "people", then it would return the 
 "people" JSON file. You can register components individually using the register method, or you can 
 return a complete dictionary of resources and their componenets by subclassing and overriding the 
 -registeredResourceNamesWithPathComponenets method.
 
 ## Complex Resources
 
 If you want more fine grained control and want to actually inspect the guts of every URN, then you 
 can of course override resourceNameForURN: to get total control over the resource name that gets
 returned.
 
 ## Resources
 
 Once a resource name is located, it will be loaded and parsed as JSON into a JSON object. That 
 object will then be returned in the response block from MMServer back to the caller from MMRecord.
 
 ## Simulated Delay
 
 One thing that's good about local servers is that they are very fast. When you are dealing with 
 slow APIs, that can be a pain. However, sometimes we want our APIs to behave more realistically.
 For networked connections, we have network link conditioner. But that won't work here, because we 
 aren't hitting the network. As a substitute, consider overriding shouldSimulateServerDelay and 
 simulatedServerDelayTime. Those methods will allow you to make your local server artificially 
 slower, which can help you when working through performance handling issues in your UI. By default,
 shouldSimulateServerDelay returns NO.
 */

@interface MMJSONServer : MMServer

/** 
 This method returns the resource name for a given URN. This method is meant to be subclassed. 
 By default, this method returns the resource, if any, that is associated with a registered path
 component.
 
 @param URN The URN to request a resource for.
 @return The name of the resource for the URN.
 */
+ (NSString*)resourceNameForURN:(NSString*)URN;

/**
 This method can be subclassed to define a dictionary of resource names and path components.
 
 @return Dictionary of registered resource names and path componenents.
 @discussion The key should be the path component string, and the value should be the resource name.
 */
+ (NSMutableDictionary *)registeredResourceNamesWithPathComponents;

/** 
 This method allows you to register a resource name for a given path component.
 
 @param resourceName The resource name to be registered.
 @param pathComponent The path component associated with that resource.
 */
+ (void)registerResourceName:(NSString *)resourceName
            forPathComponent:(NSString *)pathComponent;

/**
 This method allows you to simulate a server delay on the local server.
 
 @return This method should return YES if a subclass wishes to simulate a server delay.
 @discussion This method returns NO by default.
 */
+ (BOOL)shouldSimulateServerDelay;

/**
 This method allows you to specify a time for a server delay on the local server.
 
 @return This method should return a time for requests to be delayed by.
 @discussion This method returns 0.1 by default.
 */
+ (NSTimeInterval)simulatedServerDelayTime;

/**
 This method allows you to load a specified JSON file with a given resource name.
 @param resourceName The name of the JSON file you want to load.
 @param responseBlock The response block to be executed with the contents of the file.
 @param failureBlock The failure block to be called in the event of an error.
 */
+ (void)loadJSONResource:(NSString *)resourceName
           responseBlock:(void(^)(NSDictionary *responseData))responseBlock
            failureBlock:(void(^)(NSError *error))failureBlock;

@end
