// MMRecordCache.h
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

#import <CoreData/CoreData.h>

/**
 This class encapsulates the functionality for caching managed objects in correspondence to a 
 particular NSURLRequest's NSCachedURLResponse. It is meant to be a private class used by MMRecord 
 should you wish to enable caching support for a given entity type. However, it could be used as a 
 standalone way to cache NSManagedObject's for a given NSURLRequest. Your milage may vary.
 
 ## Caching
 
 In general, the best way to implement caching is through the use of NSURLCache and the server's
 implementation of the HTTP Cache Control headers.  In the event that this is not enough, MMRecord
 does provide an additional level of caching support.  The caching provided by MMRecord is in
 accordance with the cache control headers and augments the system provided by NSURLCache.
 If caching is enabled then MMRecord will store the object IDs for each request/response pair that
 were parsed as part of the last response in a separate SQLite persistent store.  It's important to
 note that these are stored UNENCRYPTED.  IF DATA SECURITY IS A REQUIREMENT CACHING SHOULD NOT BE
 USED!  
 
 ## Configuration
 
 Please see the MMRecord header for more information about configuring your app to support caching.
 */

@interface MMRecordCache : NSObject

/**
 This method returns YES if there are cached results for a given key. The key is typically the
 absolute URL for a given NSURLRequest. You can specify the key using the cacheRecords method below.
 @param cacheKey The key used to identify cached results.
 @return BOOL YES for has results, NO otherwise.
 */
+ (BOOL)hasResultsForKey:(NSString *)cacheKey;

/**
 This method retrieves cached results in a given context. If results are cached, it will fetch
 those objectIDs from the internal caching persistent store and attempt to obtain records matching 
 those object IDs in the provided managed object context. Those records, along with the cached 
 response object (if any) will be returned in the cache result block. This method will also respect 
 the caching policy of the NSURLCache and of this NSURLRequest. If the response for that request is 
 not cached, no results will be returned - regardless of what is found in the cache persistent store.
 @param request Request object to obtain cached results for.
 @param cacheKey Key used to identify the cached results.
 @param metaKeyPath Key used to identify metadata that may have been returned in the response.
 @param context managed object context to return cached results in.
 @param cacheResultBlock Result block that will be executed when this method finishes checking for
 cached results.
 */
+ (void)getCachedResultsForRequest:(NSURLRequest *)request
                          cacheKey:(NSString *)cacheKey
                       metaKeyPath:(NSString *)metaKeyPath
                           context:(NSManagedObjectContext *)context
                  cacheResultBlock:(void(^)(NSArray *cachedResults, id responseObject))cacheResultBlock;
/**
 This method caches the objectIDs of the given records. Those records should be subclasses of 
 NSManagedObject. The key provided will be used to locate those records later if a subsequent
 request is made for a certain NSURLRequest which you wish to associate with that key.
 @param records An array of records that should be cached.
 @param metadata Metadata contained in the response that should also be cached.
 @param key A key that will be associated with and used to identify cached results.
 @param context A managed object context where these records exist.
 */
+ (void)cacheRecords:(NSArray *)records
        withMetadata:(NSDictionary *)metadata
              forKey:(NSString *)key
         fromContext:(NSManagedObjectContext *)context;

@end
