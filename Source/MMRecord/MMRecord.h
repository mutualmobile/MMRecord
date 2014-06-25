// MMRecord.h
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

#import "MMRecordDebugger.h"
#import "MMRecordProtoRecord.h"

/** To provide custom parsing functionality for your records, such as the setting a custom key or
 establishing a relationship, use the keys below in the UserInfo dictionary of an attribute or 
 relationship:
 
 MMRecordAttributeAlternateNameKey  
 MMRecordEntityPrimaryAttributeKey
 
 MMRecordAttributeAlternateNameKey is used to specify an alernate name for an attribute.  It should 
 be used if the name of an attribute's dictionary key changes, or if the user wants the attribute 
 name to be different from the dictionary key name.  It should be set on an Attribute's user info 
 dictionary.  This feature supports keyPath values relative to the dictionary you specify in 
 -keyPathForResponseObject.  So for example, if that dictionary for your object contains a key 
 named "foo" that points to another dictionary, you can reference a value there called "bar" as 
 your alternate attribute by saying "foo.bar".
 
 MMRecordEntityPrimaryAttributeKey is used to designate the name of the primary attribute for an 
 entity.  It should be set on an Entity's user info dictionary.  In the latest version of MMRecord 
 this can be set to a relationship.  More information on that is available below.
 */

extern NSString * const MMRecordEntityPrimaryAttributeKey;
extern NSString * const MMRecordAttributeAlternateNameKey;

@class MMRecordOptions, MMServer, MMServerPageManager;

/**
 `MMRecord` provides a pattern for interfacing with a server to retrieve records.  A record is 
 an object that lives on a server.  MMRecord depends on the interface from MMServer for making 
 requests of various types.  MMRecord also inherits from NSManagedObject and it is assumed that 
 each type of record also corresponds to a certain type of Entity in a managed object model.
 
 ## Configuration - Primary Keys
  
 You must configure your Core Data model correctly for MMRecord to work effectively.  There are two 
 main parts to consider in configuring your data model.  The first is that all record types should 
 have a primary key identified by the MMRecordEntityPrimaryAttributeKey key in the Entity's userInfo
 dictionary.  This will be used to uniquely identify records in the event of an update.  Typically 
 this will be an integer or a string attribute.  
 
 ## Configuration - Primary Key Relationships
 
 The primary key property can also be a relationship. The way the relationship primary key works 
 is by establishing the existence of the parent relationship.  In order to do that, the root parent 
 relationship must have a primary key itself in order to be fetchable from Core Data.  If the root 
 parent object exists, then MMRecord will traverse the relationships of that existing object to see 
 if the child which we are trying to uniquely identify exists, and if so it will update that object 
 rather than create a duplicate entry in the database.  While this is supported for to-many 
 relationships, it is INTENDED for to-one relationships. It's much easier to reliably identify a 
 unique to-one relationship than a to-many relationship.  As such, while to-many relationships are 
 supported, they are ONLY supported if the fields in the Entity directly map to the fields in the 
 response object.  If you cannot depend on these fields matching exactly then you should look for 
 ways to refactor the API or your data model, possibly through the use of value transformers or 
 keyPaths.
 
 ## Configuration - Alternate Name Keys

 You can also configure your data model through the use of altername attribute name keys.  There 
 is more information on their use above, but these are generally used when the name of an object's 
 key in the response changes, or when the name is undesirable to use, such as if it is restricted by
 Core Data, or includes underscores.  
 
 ## Configuration - NSValueTransformers

 MMRecord will also respect the NSValueTransformer subclass defined on a transformable attribute. 
 If a value transformer is set on an attribute description, then MMRecord will use that transformer 
 to transform the value for that attribute. If no value transformer is set, then NSKeyedArchiver will
 be used.
 
 ## Configuration - Parsing and Population
 
 The parsing and population system of MMRecord can be configured to handle special cases as well. 
 The entry point for customizing this system is the MMRecordRepresentation class, and corresponding 
 MMRecordMarshaler class - which is defined by the representation. You can declare a custom 
 representation on a subclass of MMRecord. For more information about custom representations and 
 marshalers please see those corresponding header files.
 
 ## Configuration - Dates
 
 The parsing and population can support dates in either date format string form, or unix time stamp 
 number form. If the date from your request is a unix time stamp that is returned in the form of a 
 number, then the date attribute will be populated with a date created from that unix time stamp. No 
 action is required by you.If the value returned is a date format string, then you must override the
 dateFormatter method in your MMRecord subclass to provide a dateFormatter that can parse that given
 date format string. That formatter will then be used to populate date attributes for that class of
 record.
 
 ## Server
 
 You must create your own version of MMServer that implements the methods in it's interface.  Your 
 server class must make a request and call the response/failure blocks with a response object or 
 error.  You must also associate a MMServer subclass with MMRecord or your base subclass of MMRecord 
 that all of your individual records inherit from.
 
 ## Requests
 
 Each MMRecord subclass has access to methods to start a request.  The most basic version of these 
 methods simply takes a URN, data, a context, and a result/failure block.  There are other methods 
 for initiating a paged request, and for asking an instance of a record to obtain it's detail object
 from the server.  All of these methods handle the parsing of the response for you.  They use data 
 contained in the object model to know how to create record instances from the response.  This is 
 explained in more detail below.
 
 ## Subclassing Notes
 
 You must create a subclass of MMRecord for every entity in your data model that you wish to support 
 this pattern.  There is only one method that you must override: keyPathForResponseObject.  One 
 strategy for subclassing is to implement this method, and dateFormatter, in a base subclass for 
 common API responses.  You may override additional methods such as recordWithDictionary if you need
 to, but the idea is that you shouldn't have to.  You should override recordDetailURN if you wish to 
 support detail requests.
 
 ## Methods to Override
 
 To allow date attribute parsing you must override the dateFormatter method and return a date 
 formatter configured for your server's date format.  To support detail requests you must override 
 recordDetailURN.
 
 ## Object Construction
 
 Everything needed to populate your records should be defined in your Managed Object Model.  
 By default MMRecord will iterate through the record's entity's properties and look for response 
 items with matching names.  You can customize the names it searches for using various keys in the 
 entity's UserInfo dictionary.  This method works just as well for relationships and transformable 
 attributes as for normal attributes.  If an entity's inverse relationship entity is also of type 
 MMRecord then instances of that record will be created for a relationship property.  Transformable 
 attributes will be created by using the NSValueTransformer class specified in the data model.
 
 ## Custom Requests
 
 The intended use of this class is that you will create methods on your own record subclasses such
 as +tweetsForUser: which will call super's startRequestWithURN method and pass through a context, 
 resultBlock and failureBlock parameters to super.  The only parameters that would be determined 
 inside of tweetsForUser would be the request URN and the data parameters required to make that 
 request.  This accomplishes the goal of encapsulating request-making logic inside of the data model
 in a way where it only needs to be defined once for an entire project, as well as taking advantage 
 of the data parsing functionality of MMRecord so that every server call doesn't need to roll it's
 own parsing code.
 
 ## Custom Request Handlers
 
 You may wish to create and use request methods that include more information than just the 
 generated objects that are supplied by the request's response.  Support for this is supplied 
 through the Custom Request Handler block, which is a block passed into an advanced version of the
 -startRequestWithURN: method.  This block will be called with the full response object in a decoded
 JSON form to allow you to glean additional information and return it in the form of an object.  
 This works best with data which is not intended to be stored in the database.  That object will 
 then be passed to the actual resultBlock for you to use there as well.  As a best practice, 
 I recommend creating a custom NSObject subclass to encapsulate whatever piece of information you 
 intend on taking from that response and passing on to the resultBlock.  One example of where this
 may be useful is for driving a list request.  You may need to be able to tell how many objects are
 in the list even if you only received back a few of them.  If the request has that information in 
 the meta, or somewhere else, then grab it out, put it in an object and return it.  The total result
 count isn't something you need stored access to, because it's really only relevant in that one UI
 use-case.  As such it's a perfect candidate for this type of system.  Another example is
 MMServerPageManager support.  There's a category on MMRecord for supporting pagination which 
 includes a method called -startPagedRequestWithURN: that uses a Custom Request Handler in it's 
 implementation.  Please look at that as a starting point for implementing this functionality for 
 yourself.
 
 ## Caching
 
 In general, the best way to implement caching is through the use of NSURLCache and the server's 
 implementation of the HTTP Cache Control headers.  In the event that this is not enough, MMRecord 
 does provide an additional level of caching support.  The caching provided by MMRecord is in 
 accordance with the cache control headers and augments the system provided by NSURLCache.  
 If caching is enabled then MMRecord will store the object IDs for each request/response pair that 
 were parsed as part of the last response in a separate SQLite persistent store.  It's important to 
 note that these are stored UNENCRYPTED.  IF DATA SECURITY IS A REQUIREMENT CACHING SHOULD NOT BE 
 USED!  The methods required to support caching are listed below in the optional subclass methods.  
 The primary one is +isRecordLevelCachingEnabled, which should return YES if caching is desired.  
 In addition, the optional method +requestWithURN:data: on MMServer must be implemented as a 
 NSURLRequest object is required for accessing information in NSURLCache.
 
 ## Queues
 
 All MMRecord resultBlocks and failureBlocks are called on the Main Queue.  Support for specific
 callback queues will be added in a future version.
 */

@interface MMRecord : NSManagedObject

///--------------------------------
/// @name Required Subclass Methods
///--------------------------------

/**
 Must return the key path where records are located within the response object.  This will only be 
 called if your response object is of type dictionary.
 */
+ (NSString *)keyPathForResponseObject;


///--------------------------------
/// @name Optional Subclass Methods
///--------------------------------

/**
 This method can be implemented to determine if a sub entity record class should be used to 
 represent the data for a particular record.  The dictionary representation of the record is passed
 as a parameter, and the implementation should return YES or NO if that dictionary is a valid 
 representation for a record of this type.  This method is NOT intended to be used for validation,
 but for population when a record class has sub entities associated with it's entity description. 
 The typical use case would be for when you are requesting records of a given class, but depending 
 on the response values, some (or all) of the records contained in the response should result in a 
 sub entity record type being created or updated.
 
 @param dict The dictionary representation of a record.
 @return YES if the dictionary represents a record of this type, NO otherwise.
 @discussion This method will be called when startRequestForURN is called on a MMRecord class whose
 entity description contains sub entities.  This method will be called on each of those in no 
 particular order and will use the class for the first record class that returns YES.  If no record 
 classes return YES, the called MMRecord class will be used.
 */
+ (BOOL)shouldUseSubEntityRecordClassToRepresentData:(NSDictionary *)dict;

/**
 This method should be used when a user of this class would like to use a different representation 
 class for populating instances of this record class.
 @return The MMRecordRepresentation subclass you would like to use for this type of record.
 @discussion The default representation class is MMRecordRepresentation. See it's header for 
 more details.
 */
+ (Class)representationClass;

/**
 This method is used by the -startDetailRequestWithDomain: method to locate and obtain the resource 
 data for a specific record.  This URN should be everything after the base URL that is necesary to 
 provide a unique location for obtaining the specified resource.  A common implementation of this 
 method will be to return a resource URI obtained via a previous server call.  For APIs that do not 
 support this you will need to construct this URN yourself.
 
 @return A NSString containing the detail URN for the record.
 @warning If you do not implement this method then the startDetailRequest method 
 will implicitly fail.
 */
- (NSString *)recordDetailURN;

/**
 This method is used by all of the parsing method base implementations to obtain a date formatter 
 configured for handling the server's specified date format.
 
 @return A NSDateFormatter configured to handle the server's date format.
 @discussion You do not have to implement this method if your request returns unix date time stamps 
 as numbers.
 @warning If you do not implement this method and attempt to populate properties of type Date 
 with a string value you will receive a parsing error.
 @warning You should store the date formatter you create as a static variable so that it's not 
 recreated by every request.  Don't be surprised if this functionality is changed later so that 
 the user isn't responsible for handling this.
 */
+ (NSDateFormatter *)dateFormatter;

/**
 This method indicates whether records returned are cacheable. The record level cache is keyed by 
 the request URL and will obey the HTTP cache control headers.
 */
+ (BOOL)isRecordLevelCachingEnabled;

/**
 This method returns the key path where metadata for the records are located within the response 
 object.  This will only be called if your response object is of type dictionary.  Returning a 
 non-nil value will short-circuit parsing the cached response body and build a subset of the 
 response using this key and the value from the actual response.  This method is provided purely 
 for performance considerations and is not required.
 */
+ (NSString *)keyPathForMetaData;


///-----------------------------------------------
/// @name Setting and Accessing the MMServer Class
///-----------------------------------------------

/**
 Access to the registered server class.
 
 @return The server class that has been registered with MMRecord.
 */
+ (Class)server;                            

/**
 Register a server class with MMRecord.  This will be the class used for starting all requests from 
 MMRecord.
 
 @warning Must be a subclass of MMServer.
 
 @param server A class to be used for making requests.  Must be a subclass of MMServer.
 @return Yes if registration was successful, NO otherwise.
 @discussion Pass nil to unregister a previously registered server.
 */
+ (BOOL)registerServerClass:(Class)server;


///-----------------------------------------------------
/// @name Configuring the Output and Error Logging Level
///-----------------------------------------------------

/** 
 Set the desired logging level for internal warning, error, and debug log statements. Messages are 
 logged when certain events take place, such as parsing errors, missing data warnings, and 
 improperly configured data models.
 
 @warning The loggingLevel is ignored when Cocoa Lumberjack is being used.
 
 @param loggingLevel The desired logging level
 */
+ (void)setLoggingLevel:(MMRecordLoggingLevel)loggingLevel;

/**
 Access the set logging level for internal warning, error, and debug log statements.
 
 @warning The loggingLevel is stored but ignored when Cocoa Lumberjack is being used.
 */
+ (MMRecordLoggingLevel)loggingLevel;

///--------------------------------------------
/// @name Starting and Stopping Server Requests
///--------------------------------------------

/**
 Calls the registered server class's cancel requests method.
 
 @param domain The domain value for which requests should be cancelled.
 */
+ (void)cancelRequestsWithDomain:(id)domain;

/**
 Starts a request on the registered server class.  This is the default implementation of this 
 method.
 
 @param URN The base URN for the request endpoint.
 @param parameters A dictionary containing request parameters.
 @param context The managed object context that will be used for creating the records that are 
 returned in the response.
 @param domain The domain that this request should be associated with.
 @param resultBlock A block object to be executed when the request finishes successfully.  Before 
 the block is called the response will be parsed and records will be created.  The block is called 
 with those records as a parameter.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully.  
 The block contains an error object that describes a request failure or a record parsing failure.
 */
+ (void)startRequestWithURN:(NSString *)URN
                       data:(NSDictionary *)parameters
                    context:(NSManagedObjectContext *)context
                     domain:(id)domain
                resultBlock:(void(^)(NSArray *records))resultBlock
               failureBlock:(void(^)(NSError *error))failureBlock;

/**
 Starts a request on the registered server class.  This is an advanced implementation of this method
 with additional functionality.
 
 @param URN The base URN for the request endpoint.
 @param parameters A dictionary containing request parameters.
 @param context The managed object context that will be used for creating the records that are 
 returned in the response.
 @param domain The domain that this request should be associated with.
 @param customResponseBlock This block allows the user raw access to the parsed response from the 
 request. Users can then extract other information from the response, such as meta information, 
 result totals and indexes, etc. The user is expected to store that information in an object and 
 have this block return that object. That object will then be passed as a parameter to the result 
 block, giving the user access to that information. If this block returns nil, customResponseObject 
 will be nil in the result block.
 @param resultBlock A block object to be executed when the request finishes successfully.  Before 
 the block is called the response will be parsed and records will be created.  The block is called 
 with those records as a parameter. Before this block is called the customResponseBlock will be 
 called, and the second parameter will be the return of that block. If the customResponseBlock is 
 nil, the customResponseObject parameter will be nil.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully.  
 The block contains an error object that describes a request failure or a record parsing failure.
 */
+ (void)startRequestWithURN:(NSString *)URN
                       data:(NSDictionary *)parameters
                    context:(NSManagedObjectContext*)context
                     domain:(id)domain
        customResponseBlock:(id (^)(id JSON))customResponseBlock
                resultBlock:(void(^)(NSArray *records, id customResponseObject))resultBlock
               failureBlock:(void(^)(NSError *error))failureBlock;

/**
 Starts a detail request for an instance of a record.  This method calls the recordDetailURN method, 
 which should be implemented by a record needing to use this method.  The record detail URN will be 
 used as the location for fetching the detail resource for the record.
 
 @param domain The domain that this request should be associated with.
 @param resultBlock A block object to be executed when the request finishes successfully.  The block 
 contains a reference to the calling record which will have been updated with the returned data from 
 the detail request.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully.  
 The block contains an error object that describes a request failure or a record parsing failure.
 */
- (void)startDetailRequestWithDomain:(id)domain
                         resultBlock:(void(^)(MMRecord *record))resultBlock
                        failureBlock:(void(^)(NSError *error))failureBlock;

/** 
 Starts batched requests.
 
 @param batchExecutionBlock A block in which all batched requests should be started.  This block 
 will be executed immediately and all requests started inside of it will be associated with the 
 same dispatch group and started with the batched property set to YES.
 @param completionBlock A block to be executed when the dispatch group notify occurs signaling that 
 the group has finished executing.
 */
+ (void)startBatchedRequestsInExecutionBlock:(void(^)())batchExecutionBlock 
                         withCompletionBlock:(void(^)())completionBlock;


///-----------------------------------------
/// @name Error Handling Convenience Methods
///-----------------------------------------

- (id)primaryKeyValue;

@end


/**
 This category adds improved support for custom handling of pagination within requests.  It uses the 
 customResponseBlock functionality documented above to achieve this goal, and is intended both as a 
 great tool for implementing paginated HTTP requests, as well as a reference implementation for how 
 to use the customResponseBlock feature.
 */

@interface MMRecord (MMServerPageManager)

/**
 Starts a paged request on the registered server class.  This is achieved by passing YES as the 
 paging parameter.  The server class is responsible for handling this accordingly, if paging 
 functionality is desired.  The purpose of this method is to enable the caller to receive a first
 page for a given resource and to subsequently request further pages.  The signature of the result 
 block is therefore changed to account for this functionality.
 
 @param URN The base URN for the request endpoint.
 @param parameters A dictionary containing request parameters.
 @param context The managed object context that will be used for creating the records that are 
 returned in the response.
 @param domain The domain that this request should be associated with.
 @param resultBlock A block object to be executed when the request finishes successfully.  Before 
 the block is called the response will be parsed and records will be created.  An instance of the 
 MMServerPageManager class designated by MMRecord's registered server is also initialized.  This 
 class should be a subclass for your specific server that is implemented to handle that server's 
 paging functionality.  The page manager object will know the URN for the next and previous pages. 
 The block is called with the records and page manager object as parameters.  There is also a 
 reference to a boolean for requestNextPage.  This is defaulted to NO.  If the block changes this 
 parameter to YES then a subsequent request will be started to retrieve the next page.  
 The subsequent request will use the original result and failure blocks to handle it's response.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully.  
 The block contains an error object that describes a request failure or a record parsing failure.
 */
+ (void)startPagedRequestWithURN:(NSString *)URN
                            data:(NSDictionary *)parameters
                         context:(NSManagedObjectContext*)context
                          domain:(id)domain
                     resultBlock:(void(^)(NSArray *records, id pageManager, BOOL *requestNextPage))resultBlock   // Default is NO
                    failureBlock:(void(^)(NSError *error))failureBlock;

@end


/**
 This category adds support for running a fetch request alongside the URL request.  It is meant for 
 when data is likely to exist in some form, stale or otherwise, in the persistent store and it would 
 be useful to return the existing data as quickly as possible and then follow up soon thereafter 
 with the latest data from a web service.
 */

@interface MMRecord (MMRecordFetchRequests)

/**
 Starts a dual fetch and web request to retrieve information as quickly and as efficiently as 
 possible.  This method IS MEANT to be wrapped in a subclass's implementation which hides the fetch 
 request, URN, etc. from the caller.  The caller (presumably a view controller) should not need to 
 know about how to build the fetch request, it should only care about the data being received in the 
 result block.
 
 @param URN The base URN for the request endpoint.
 @param parameters A dictionary containing request parameters.
 @param context The managed object context that will be used for creating the records that are 
 returned in the response.
 @param domain The domain that this request should be associated with.
 @param fetchRequest An NSFetchRequest configured to fetch data of the same type as the request is 
 meant to receive from Core Data.
 @param customResponseBlock This block allows the user raw access to the parsed response from the 
 request. Users can then extract other information from the response, such as meta information, 
 result totals and indexes, etc. The user is expected to store that information in an object and 
 have this block return that object. That object will then be passed as a parameter to the result
 block, giving the user access to that information. If this block returns nil, customResponseObject 
 will be nil in the result block.
 @param resultBlock A block object to be executed when the request finishes successfully.  Before 
 the block is called the response will be parsed and records will be created.  The block is called 
 with those records as a parameter. Before this block is called the customResponseBlock will be 
 called, and the second parameter will be the return of that block. If the customResponseBlock is 
 nil, the customResponseObject parameter will be nil.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully.  
 The block contains an error object that describes a request failure or a record parsing failure.
 */
+ (void)startRequestWithURN:(NSString *)URN
                       data:(NSDictionary *)parameters
                    context:(NSManagedObjectContext*)context
                     domain:(id)domain
               fetchRequest:(NSFetchRequest *)fetchRequest
        customResponseBlock:(id (^)(id JSON))customResponseBlock
                resultBlock:(void(^)(NSArray *records, id customResponseObject, BOOL requestComplete))resultBlock
               failureBlock:(void(^)(NSError *error))failureBlock;

@end


/**
 This block should be used to conditionally delete orphaned records if they are not returned in a
 request's response.
 
 @param orphan The record which has now become an orphan.
 @param populatedRecords An array of records that were populated from the response.
 @param responseObject The JSON response object from the request.
 @param stop A boolean reference you can set to YES to short circuit the orphan deletion process.
 @return BOOL You should return YES if you want to delete the orphan and NO otherwise.
 */
typedef BOOL (^MMRecordOptionsDeleteOrphanedRecordBlock)(MMRecord *orphan,
                                                         NSArray *populatedRecords,
                                                         id responseObject,
                                                         BOOL *stop);

/**
 This block should be used to optionally inject a primary key that will be used to uniquely identify
 a record of a given type. The most common use case for this block should be when an API's JSON 
 response does not contain a record primary key, but the caller who makes the request already has 
 that key. Generally this will be the root level initial entity that the request to MMRecord is
 going to return. This could be used to return primary keys for sub-entities, but this is generally
 not recommended.
 
 You may choose to generate a primary key for a given record based on the dictionary passed into 
 the block. Hashing the dictionary to create the primary key may prove to be a valid solution for 
 your specific use case.
 
 @warning This block will only be executed if the primary key for a record cannot be obtained from 
 the record dictionary.
 
 @discussion This method can return nil.
 
 @param entity The entity type to evaluate and return a primary key for.
 @param dictionary The dictionary being used to populate the given record.
 @param parentProtoRecord The parent proto record of the one whose primary key is being evaluated
 here. This may be nil if the entity is the initial entity being populated by MMRecord.
 @return id The primary key to associate with the record. This value must conform to NSCopying.
 */
typedef id<NSCopying> (^MMRecordOptionsEntityPrimaryKeyInjectionBlock)(NSEntityDescription *entity,
                                                                       NSDictionary *dictionary,
                                                                       MMRecordProtoRecord *parentProtoRecord);

/**
 This block may be used for inserting custom logic into the record population workflow. This block, 
 if defined, will be executed prior to the MMRecordMarshaler's -populateProtoRecord: method.
 
 @warning This block should only be used in relatively rare cases. It is not a substitute for proper
 model configuration or for marshaler/representation subclassing. It is meant for rare cases where
 injecting data into the population flow is required for accurate record population. Because this
 block will be executed for each proto record for a given request, performance issues may arrise.
 Please use caution.
 @param protoRecord The proto record which is about to be populated.
 */
typedef void (^MMRecordOptionsRecordPrePopulationBlock)(MMRecordProtoRecord *protoRecord);


/**
 This class represents various user settable options that MMRecord will use when starting requests.
 */

@interface MMRecordOptions : NSObject

/** 
 Starts requests and tethers the managed objects generated from the response to a child context of 
 the one that is passed in rather than saving the objects directly to the persistent store.  This 
 option should be used when you want finer-grained control over the context saving behavior of the 
 request.  MMRecord will still call save on the underlying child context, as it assumes that the 
 context you pass in is where you want the objects to go.  It's important to note that calling save 
 on a child context only pushes the data up one layer, to the parent, unless the child has no 
 parent, in which case it saves directly to the persistent store.
 
 @discussion This option defaults to YES.
 */
@property (nonatomic, assign) BOOL automaticallyPersistsRecords;

/** 
 The queue that will be used by MMRecord when calling the result and failure blocks.
 
 @discussion The default callback queue is the main queue.
 */
@property (nonatomic) dispatch_queue_t callbackQueue;

/**
 Must specify the key path where records are located within the response object. This will only be
 used if your response object is of type dictionary. This option gives you the ability to specify a 
 different key path for an entity than the one in your subclass. Use this option sparingly.
 Generally speaking you should subclass and create a different entity to provide different 
 functionality.
 
 @discussion Default is whatever is returned by this method on the MMRecord subclass.
 @warning This option is NOT supported for batch requests!
 */
@property (nonatomic, copy) NSString *keyPathForResponseObject;

/**
 This option indicates whether records returned are cacheable. The record level cache is keyed by 
 the request URL and will obey the HTTP cache control headers. For more information on caching 
 please see above documentation.
 
 @discussion Default value is NO.
 @warning This method is supported for batching, but may result in unintended entities being cached.
 */
@property (nonatomic, assign) BOOL isRecordLevelCachingEnabled;

/**
 This option specifies the key path where metadata for the records are located within the response 
 object.  This will only be used if your response object is of type dictionary.  Returning a 
 non-nil value will short-circuit parsing the cached response body and build a subset of the 
 response using this key and the value from the actual response.  This option is provided purely for
 performance considerations and is not required.
 
 @discussion Default value is the value returned in the subclass method.
 */
@property (nonatomic, copy) NSString *keyPathForMetaData;

/**
 This option allows you to specify a page manager that will be used for the next request if it is
 paginated. This gives you the flexibility to use a different page manager class than is specified
 on your registered server class for a given entity. This may be useful if your API has different
 pagination behavior in certain situations.
 
 @discussion Default value is the page manager for the registered server class for the given entity.
 */
@property (nonatomic, strong) Class pageManagerClass;

/**
 This option allows you to specify your own debugger class for implementing custom error handling
 behavior. You might want to do this if you want to override certain MMRecord errors, or
 more strictly enforce errors of your own. You may also be able to provide support for custom
 errors. The MMRecordDebugger class and error handling system may grow more powerful overtime,
 possibly obviating the need for this, but also possibly making this even more useful.
 
 @discussion Default value for this is an instance of MMRecordDebugger.
 */
@property (nonatomic, strong) MMRecordDebugger *debugger;

/**
 This option allows you to specify a block that will be executed once per record which was orphaned
 by this request's response until either it has been called n times for n number of orphans or until
 you pass YES for the stop parameter.
 
 This block will only be called for orphans of the initial entity type that was requested by
 MMRecord. Sub-entities or child-entities will not be considered as orphans.
 
 @discussion Default value is nil which means orphans will be ignored.
 */
@property (nonatomic, copy) MMRecordOptionsDeleteOrphanedRecordBlock deleteOrphanedRecordBlock;

/**
 This option allows you to specify a block that will be executed when a record is populated and no
 primary key to identify it is found in the populating record dictionary. This allows you to return
 your own primary key that will be used to uniquely identify the record. You may also choose to
 generate a primary key for a given record based on the dictionary passed into the block. Hashing
 the dictionary to create the primary key may prove to be a valid solution for your specific use
 case.
 
 @discussion This block should return nil if you have no way to uniquely identify a record for the
 given type of entity. The default value of this option is nil.
 */
@property (nonatomic, copy) MMRecordOptionsEntityPrimaryKeyInjectionBlock entityPrimaryKeyInjectionBlock;

/**
 This option allows you to specify a block that will be executed immediately before record
 population in order to perform some task like inserting data into the population process.
 
 @discussion Default value is nil which means population will be performed normally.
 */
@property (nonatomic, copy) MMRecordOptionsRecordPrePopulationBlock recordPrePopulationBlock;

@end


/**
 This extenion to MMRecord enables the user to set various options to customize the behavior of a 
 specific MMRecord request.
 */
@interface MMRecord (MMRecordOptions)

/**
 This method allows you to set a specific set of options for a single MMRecord request. 
 MMRecordOptions follows the design paradigm set forth in Core Animation with the notion of an 
 implicit transaction. Every MMRecord request starts with a default set of options. The defaults are 
 specified above in the options class. Options are intended to be used sparingly and in special 
 circumstances. As such, a set of options will only be applied to the first request started after 
 -setOptions: is called. If you want those options to be used for every request, or for a specific 
 request every time it's called, you should encapsulate that request inside of another method which 
 sets a new set of options before starting the request on MMRecord.
 
 @param options The options object to be set on MMRecord.
 @warning Options are implicitly reset after a request is run
 @discussion Tip: if you want multiple requests to use a specific set of options, you can group 
 them in a batch block and they will all use the specified options that you set before starting the 
 batch request.
 */
+ (void)setOptions:(MMRecordOptions *)options;

/**
 Designated accessor for obtaining the default set of options for a given class of MMRecord.
 */
+ (MMRecordOptions *)defaultOptions;

@end

