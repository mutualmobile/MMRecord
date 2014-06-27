<p align="center">
  <img src="https://www.github.com/mutualmobile/MMRecord/raw/gh-pages/Images/MMRecord-blog_banner.png") alt="MMRecord Blog Banner"/>
</p>

MMRecord is a block-based seamless web service integration library for iOS and Mac OS X. It leverages the [Core Data](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/CoreData_ObjC/_index.html) model configuration to automatically create and populate a complete object graph from an API response. It works with any networking library, is simple to setup, and includes many popular features that make working with web services even easier. Here's how to make a request for App.net Post records:


```objective-c
NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];

[Post 
 startPagedRequestWithURN:@"stream/0/posts/stream/global"
 data:nil
 context:context
 domain:self
 resultBlock:^(NSArray *posts, ADNPageManager *pageManager, BOOL *requestNextPage) {
	 NSLog(@"Posts: %@", posts);
 }
 failureBlock:^(NSError *error) {
	 NSLog(@"%@", error);
 }];
```

Keep reading to learn more about how to start using MMRecord in your project!

## Getting Started

- [Download MMRecord](https://github.com/mutualmobile/MMRecord/archive/master.zip) and try out the included example apps.
- Continue reading the integration instructions below.
- Check out the [documentation](http://mutualmobile.github.com/MMRecord/Documentation/) for all the rest of the details.
- Review the [examples](https://github.com/mutualmobile/MMRecord#example-usage) below for inspiration on specific usage.
- Read about MMRecord's support for [Swift](https://github.com/mutualmobile/MMRecord#swift-examples) and [Tweaks](https://github.com/mutualmobile/MMRecord#tweaks).
- If you run into any issues, check out some useful [debugging](https://github.com/mutualmobile/MMRecord#debugging) tips.

---
##Installing MMRecord
<img src="https://cocoapod-badges.herokuapp.com/v/MMRecord/badge.png"/><br/>
You can install MMRecord in your project by using [CocoaPods](https://github.com/cocoapods/cocoapods):

```Ruby
pod 'MMRecord', '~> 1.4.0'
```

## Overview

MMRecord is designed to make it as easy and fast as possible to obtain native objects from a new web service request. It handles all of the fetching, creation, and population of NSManagedObjects for you in the background so that when you make a request, all you get back is the native objects that you can use immediately. No parsing required.

The library is architected to be as simple and lightweight as possible. Here's a breakdown of the core classes in MMRecord.

<table>
  <tr><th colspan="2" style="text-align:center;">Core</th></tr>
  <tr>
    <td><a href="http://mutualmobile.github.com/MMRecord/Documentation/Classes/MMRecord.html">MMRecord</a></td>
    <td>
      A subclass of <tt>NSManagedObject</tt> that defines the <tt>MMRecord</tt> interface and initiates the object graph population process.
      
      <ul>
        <li>Entry point for making requests</li>
        <li>Uses a registered <tt>MMServer</tt> class for making requests</li>
        <li>Initiaties the population process using the <tt>MMRecordResponse</tt> class</li>
		<li>Returns objects via a block based interface</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><a href="http://mutualmobile.github.com/MMRecord/Documentation/Classes/MMServer.html">MMServer</a></td>
    <td>
	  An abstract class that defines the request interface used by <tt>MMRecord</tt>.
	  
      <ul>
        <li>Designed to be subclassed</li>
        <li>Supports any networking framework, including local files and servers</li>
      </ul>
    </td>
  </tr>
</table>
  
<p align="center">
  <img src="https://www.github.com/mutualmobile/MMRecord/raw/gh-pages/Images/MMRecord-architecture-diagram.png") alt="MMRecord Architecture Diagram"/>
</p>

<table>
  <tr><th colspan="2" style="text-align:center;">Population</th></tr>
  <tr>
    <td><a href="http://mutualmobile.github.com/MMRecord/Documentation/Classes/MMRecordResponse.html">MMRecordResponse</a></td>
    <td>A class that handles the process of turning a response into native <tt>MMRecord</tt> objects.</td>
  </tr>
  <tr>
    <td><a href="http://mutualmobile.github.com/MMRecord/Documentation/Classes/MMRecordProtoRecord.html">MMRecordProtoRecord</a></td>
    <td>A container class used as a placeholder for the object graph during the population process.</td>
  </tr>
  <tr>
    <td><a href="http://mutualmobile.github.com/MMRecord/Documentation/Classes/MMRecordRepresentation.html">MMRecordRepresentation</a></td>
    <td>A class that defines the mapping between a dictionary and a Core Data <tt>NSEntityDescription</tt>.</td>
  </tr>
  <tr>
    <td><a href="http://mutualmobile.github.com/MMRecord/Documentation/Classes/MMRecordMarshaler.html">MMRecordMarshaler</a></td>
    <td>A class responsible for populating an instance of <tt>MMRecord</tt> based on the <tt>MMRecordRepresentation</tt>.</td>
  </tr>

  <tr><th colspan="2" style="text-align:center;">Pagination</th></tr>
  <tr>
    <td><a href="http://mutualmobile.github.com/MMRecord/Documentation/Classes/MMServerPageManager.html">MMServerPageManager</a></td>
    <td>An abstract class that defines the interface for handling pagination.</td>
  </tr>
  
  <tr><th colspan="2" style="text-align:center;">Caching</th></tr>
  <tr>
    <td><a href="http://mutualmobile.github.com/MMRecord/Documentation/Classes/MMRecordCache.html">MMRecordCache</a></td>
    <td>A class that maps <tt>NSManagedObject</tt> ObjectIDs to an <tt>NSCachedURLResponse</tt>.</td>
  </tr>
  
    <tr><th colspan="2" style="text-align:center;">Debugging</th></tr>
  <tr>
    <td><a href="http://mutualmobile.github.com/MMRecord/Documentation/Classes/MMRecordDebugger.html">MMRecordDebugger</a></td>
    <td>A class that manages <tt>NSError</tt> objects to provide debugging feedback.</td>
  </tr>
</table>

<p align="center">
  <img src="https://www.github.com/mutualmobile/MMRecord/raw/gh-pages/Images/MMRecord-parsing.png") alt="MMRecord Population Architecture"/>
</p>

<table>
  <tr><th colspan="2" style="text-align:center;">Subspecs</th></tr>
  <tr>
    <td><a href="https://github.com/mutualmobile/MMRecord/tree/master/Source/MMRecordAFServer">AFServer</a></td>
    <td>An example <tt>MMServer</tt> subclass that implements <tt>AFNetworking</tt> 1.0.</td>
  </tr>
  <tr>
    <td><a href="https://github.com/mutualmobile/MMRecord/tree/master/Source/AFMMRecordSessionManagerServer">SessionManagerServer</a></td>
    <td>An example <tt>MMServer</tt> subclass that implements <tt>AFNetworking</tt> 2.0.</td>
  </tr>
  <tr>
    <td><a href="https://github.com/mutualmobile/MMRecord/tree/master/Source/MMRecordJSONServer">JSONServer</a></td>
    <td>An example <tt>MMServer</tt> subclass that can read local JSON files.</td>
  </tr>
  <tr>
    <td><a href="https://github.com/mutualmobile/MMRecord/tree/master/Source/MMRecordDynamicModel">DynamicModel</a></td>
    <td>A custom <tt>MMRecordRepresentation</tt> and <tt>MMRecordMarshaler</tt> subclass pair that stores the original object dictionary as a transformable attribute.</td>
  </tr>
  <tr>
    <td><a href="https://github.com/mutualmobile/MMRecord/tree/master/Source/AFMMRecordResponseSerializer">ResponseSerializer</a></td>
    <td>A custom <tt>AFHTTPResponseSerializer</tt> that creates and returns <tt>MMRecord</tt> instances in an <tt>AFNetworking</tt> 2.0 success block.</td>
  </tr>
  <tr>
    <td><a href="https://github.com/mutualmobile/MMRecord/tree/master/Source/FBMMRecordTweakModel">TweakModel</a></td>
    <td>An <tt>MMRecord</tt> subspec that implements support for Facebook Tweaks to tweak <tt>MMRecord</tt> response handling behavior.</td>
  </tr>
</table>

## Integration Guide

MMRecord does require some basic setup before you can use it to make requests. This guide will go take you through the steps in that configuration process.

### Server Class Configuration

MMRecord requires a registered server class to make requests. The server class should know how to make a request to the API you are integrating with. The only requirement of a server implementation is that it return a response object (array or dictionary) that contains the objects you are requesting. A server might use [AFNetworking](https://github.com/AFNetworking/AFNetworking) to perform a GET request to a specific API. Or it might load and return local JSON files. There are two subspecs which provide pre-built servers that use AFNetworking and local JSON files. Generally speaking though, you are encouraged to implement your own server to talk to the API you are using.

Once you have defined your server class, you must register it with MMRecord:

```objective-c
[Post registerServerClass:[ADNServer class]];
```

Note that you can register different server classes on different subclasses of MMRecord.

```objective-c
[Tweet registerServerClass:[TWSocialServer class]];
[User registerServerClass:[MMJSONServer class]];
```

This is helpful if one endpoint you are working with is complete, but another is not, or is located on another API.

#### AFNetworking

While you are encouraged to create your own specific server subclass for your own integration, MMRecord does provide base server implementations as subspec examples for AFNetworking 1.0 and AFNetworking 2.0. You can consult the AFServer subspec for AFNetworking 1.0, or the AFMMRecordSessionManagerServer subspec for AFNetworking 2.0. You can check out the new AFNetworking 2.0 server in the [Foursquare example app](https://github.com/mutualmobile/MMRecord/tree/master/Examples/MMRecordFoursquare/MMRecordFoursquare).

In addition, we provide the AFMMRecordResponseSerializer subspec specially for AFNetworking 2.0. This response serializer can be used for AFNetworking 2.0 in order to provide parsed and populated MMRecord instances to you in an AFNetworking success block. For more information please check out this [blog post](http://mutualmobile.github.io/blog/2014/01/14/afnetworking-response-serialization-with-mmrecord-1-dot-2/) or view the example [below](https://github.com/mutualmobile/MMRecord/#afmmrecordresponseserializer).

### MMRecord Subclass Implementation

You are required to override one method on your subclass of MMRecord in order to tell the parsing system where to locate the object(s) are tbat you wish to parse. This method returns a key path that specifies the location relative to the root of the response object. If your response object is an array, you can just return nil.

In an App.net request, all returned objects are located in an object called "data", so our subclass of <tt>MMRecord</tt> will look like this:

```objective-c
@interface ADNRecord : MMRecord
@end

static NSDateFormatter *ADNRecordDateFormatter;

@implementation ADNRecord

+ (NSString *)keyPathForResponseObject {
    return @"data";
}

+ (NSDateFormatter *)dateFormatter {
    if (!ADNRecordDateFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"]; // "2012-11-21T03:57:39Z"
        ADNRecordDateFormatter = dateFormatter;
    }
    
    return ADNRecordDateFormatter;
}

@end
```
There are also some optional methods you may wish to implement on <tt>MMRecord</tt>. One such method returns a date formatter configured for populating attributes of type Date. You can override this method to populate date attributes using a formatted date string. Unix number time stamp dates are supported by default.

Note that these methods were implemented on a class called <tt>ADNRecord</tt>, which is a subclass of <tt>MMRecord</tt>. Additional entities are subclasses of <tt>ADNRecord</tt>, and do not need to implement these methods themselves.

### Model Configuration

The Core Data <tt>NSManagedObjectModel</tt> is very useful. At a highlevel, the model is composed of a list of entities. Likewise, an API is typically composed of a list of endpoints. MMRecord takes advantage of this convention to map an entity representation to an endpoint representation in order to create native objects from an API response. 

MMRecord leverages the introspective properties of the Core Data model to decide how to parse a response. The class you start the request from is considered to be the root of the object graph. From there, MMRecord looks at that <tt>NSEntityDescription</tt>'s attributes and relationships and attempts to populate each of them from the given response object. That information is very helpful, because it makes population of most attributes very straightforward. Because of this, it's helpful if your data model entity representations maps very closely to your API endpoint response representations.

#### Primary Key

MMRecord works best if there is a way to uniquely identify records of a given entity type. That allows it to fetch the existing record (if it exists) and update it, rather than create a duplicate one. To designate the primary key for an entity, we leverage the entity's user info dictionary. Specify the name of the primary key property as the value, and <b>MMRecordEntityPrimaryAttributeKey</b> as the key.

![MMRecord Primary Key](https://www.github.com/mutualmobile/MMRecord/raw/gh-pages/Images/MMRecord-primary-key.png)

Note that the primary key can be any property, which includes a relationship. If a relationship is used as the primary key, MMRecord will attempt to fetch the parent object and search for the associated object in the relationship.

![MMRecord Relationship Primary Key](https://www.github.com/mutualmobile/MMRecord/raw/gh-pages/Images/MMRecord-relationship-primary-key.png)

You can also inject a primary key at population time if you know the key for a record which does not exist in the API response dictionary being used to populate the record. An example of this being used is [below](https://github.com/mutualmobile/MMRecord/#mmrecordoptions-and-primary-key-injection). This option is not intended to replace proper model configuration, but can be used for additional flexibility. One way you can consider using this option is by parsing the contents of the dictionary to create your own unique identifier for a given record.

#### Alternate Property Names

Sometimes, you may need to define an alternate name for a property on one of your entities. This could be for a variety of reasons. Perhaps you don't like your Core Data property names to include underscores? Perhaps the API response changed, and you don't want to change your NSManagedObject property names. Or maybe the value of a property is actually inside of a sub-object, and you need to bring it up to root level. Well, that's what the <b>MMRecordAttributeAlternateNameKey</b> is for. You can define this key on any attribute or relationship user info dictionary. The value of this key can be an alternate name, or alternate keyPath that will be used to locate the object for that property.

![MMRecord Alternate Name Key](https://www.github.com/mutualmobile/MMRecord/raw/gh-pages/Images/MMRecord-alternate-name-key.png)

For reference, here's a truncated version of the App.net User object to illustrate how those configuration values were determined:

```json
{
    "id": "1", // note this is a string
    "username": "johnappleseed",
    "name": "John Appleseed",
    "avatar_image": {
        "height": 512,
        "width": 512,
        "url": "https://example.com/avatar_image.jpg",
        "is_default": false
    },
    "cover_image": {
        "width": 320,
        "height": 118,
        "url": "https://example.com/cover_image.jpg",
        "is_default": false
    },
	"counts": {
		"following": 100,
		"followers": 200,
        "posts": 24,
        "stars": 76
    }
}
```

## Example Usage
Here's a few examples of the various types of requests you can make with MMRecord. Notice that AFMMRecordResponseSerializer is a subspec of MMRecord.

### Standard Request

```objective-c
+ (void)favoriteTweetsWithContext:(NSManagedObjectContext *)context
                           domain:(id)domain
                      resultBlock:(void (^)(NSArray *tweets))resultBlock
                     failureBlock:(void (^)(NSError *))failureBlock {
    [Tweet startRequestWithURN:@"favorites/list.json"
                          data:nil
                       context:context
                        domain:self
                   resultBlock:resultBlock
                  failureBlock:failureBlock];
}
```

### Paginated Request

```objective-c
@interface Post : ADNRecord
+ (void)getStreamPostsWithContext:(NSManagedObjectContext *)context
                           domain:(id)domain
                      resultBlock:(void (^)(NSArray *posts, ADNPageManager *pageManager, BOOL *requestNextPage))resultBlock
                     failureBlock:(void (^)(NSError *error))failureBlock;
@end

@implementation Post
+ (void)getStreamPostsWithContext:(NSManagedObjectContext *)context
                           domain:(id)domain
                      resultBlock:(void (^)(NSArray *posts, ADNPageManager *pageManager, BOOL *requestNextPage))resultBlock
                     failureBlock:(void (^)(NSError *error))failureBlock {
    [self startPagedRequestWithURN:@"stream/0/posts/stream/global"
                              data:nil
                           context:context
                            domain:self
                       resultBlock:resultBlock
                      failureBlock:failureBlock];
}
@end
```

### Batched Request

```objective-c
[Tweet startBatchedRequestsInExecutionBlock:^{
    [Tweet
     timelineTweetsWithContext:context
     domain:self
     resultBlock:^(NSArray *tweets, MMServerPageManager *pageManager, BOOL *requestNextPage) {
         NSLog(@"Timeline Request Complete");
     }
     failureBlock:^(NSError *error) {
         NSLog(@"%@", error);
     }];
    
    [Tweet
     favoriteTweetsWithContext:context
     domain:self
     resultBlock:^(NSArray *tweets, MMServerPageManager *pageManager, BOOL *requestNextPage) {
         NSLog(@"Favorites Request Complete");
     }
     failureBlock:^(NSError *error) {
         NSLog(@"%@", error);
     }];
} withCompletionBlock:^{
    NSLog(@"Request Complete");
}];
```

### Fetch First Request

```objective-c
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
```

### AFMMRecordResponseSerializer

```objective-c
MMFoursquareSessionManager *sessionManager = [MMFoursquareSessionManager sharedClient];
    
NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];
AFHTTPResponseSerializer *HTTPResponseSerializer = [AFJSONResponseSerializer serializer];
    
AFMMRecordResponseSerializationMapper *mapper = [[AFMMRecordResponseSerializationMapper alloc] init];
[mapper registerEntityName:@"Venue" forEndpointPathComponent:@"venues/search?"];
    
AFMMRecordResponseSerializer *serializer =
    [AFMMRecordResponseSerializer serializerWithManagedObjectContext:context
                                            responseObjectSerializer:HTTPResponseSerializer
                                                        entityMapper:mapper];
    
sessionManager.responseSerializer = serializer;

[[MMFoursquareSessionManager sharedClient]
 GET:@"venues/search?ll=30.25,-97.75"
 parameters:requestParameters
 success:^(NSURLSessionDataTask *task, id responseObject) {
     NSArray *venues = responseObject;
         
     self.venues = venues;
         
     [self.tableView reloadData];
 } 
 failure:failureBlock];
```

## MMRecordOptions Examples
`MMRecordOptions` is a way to customize the behavior of a request. One of the ways you can use it is to specify blocks that apply to the following request after you specify a set of options. This allows you to do things like insert a new primary key for a record or specify orphan deletion behaviors.

### Primary Key Injection

```objective-c
MMRecordOptions *options = [Post defaultOptions];
    
options.entityPrimaryKeyInjectionBlock = ^id(NSEntityDescription *entity,
                                             NSDictionary *dictionary,
                                             MMRecordProtoRecord *parentProtoRecord) {
    if ([[entity name] isEqualToString:@"CoverImage"]) {
        if ([[parentProtoRecord.entity name] isEqualToString:@"User"]) {
            if (parentProtoRecord.primaryKeyValue != nil) {
                return parentProtoRecord.primaryKeyValue;
            }
        }
    }
    
    return nil;
};
    
[Post setOptions:options];

[Post
 getStreamPostsWithContext:context
 domain:self
 resultBlock:^(NSArray *posts, ADNPageManager *pageManager, BOOL *requestNextPage) {
    [self populatePostsTableWithPosts:posts];
 }
 failureBlock:failureBlock];
```

### Orphan Deletion

```objective-c
MMRecordOptions *options = [Tweet defaultOptions];

options.deleteOrphanedRecordBlock = ^(MMRecord *orphan,
                                      NSArray *populatedRecords,
                                      id responseObject,
                                      BOOL *stop) {
    Tweet *tweet = (Tweet *)orphan;
        
    if ([tweet isFavorite]) {
        return NO;
    }
        
    return YES;
};

[Tweet setOptions:options];
    
[Tweet
 timelineTweetsWithContext:context
 domain:self
 resultBlock:^(NSArray *tweets, MMServerPageManager *pageManager, BOOL *requestNextPage) {
     self.tweets = tweets;
     [self.tableView reloadData];
 }
 failureBlock:failureBlock];
```

## Swift Examples
While MMRecord is implemented in Objective-C, you can also use the library from to build your model in Swift. The main thing you should be aware of when building your model in Swift is that entity managed object class names need to be fully namespaced. An example of that is below.
  
<p align="center">
  <img src="https://www.github.com/mutualmobile/MMRecord/raw/gh-pages/Images/MMRecord-swift.png") alt="MMRecord Model Configuration for Swift"/>
</p>

Note that MMRecordAtlassian is used as the namespace for the Issue class in Swift. This is because the default namespace is the product name for your project. Please be aware that using special characters or spaces in your product name may lead to issues here. Typically those characters get replaced by underscores in your namespace, but for best results, simply use a single word for your product name to avoid issues.

You should also remember to import MMRecord.h, and any of its subspecs you use, in your Objective-C Bridging Header. Then, you're ready to go building your MMRecord model in Swift!

Here's a few examples of using MMRecord in Swift.

### Swift MMRecord Subclass Implementation

```swift
import CoreData

class Plan: ATLRecord {
    @NSManaged var name: NSString
    @NSManaged var id: NSString
    
    override class func keyPathForResponseObject() -> String {
        return "plans.plan"
    }
}
```

### Standard Swift Request

```swift
Plan.startRequestWithURN("/plans",
	data: nil,
	context: managedObjectContext,
	domain: self,
	resultBlock: {records in
		var results: Plan[] = records as Plan[]
                
		self.plans = results
		self.tableView.reloadData()
	},
	failureBlock: { error in
            
	})
```

### Swift Request with MMRecordOptions

```swift
var options = Issue.defaultOptions()

options.entityPrimaryKeyInjectionBlock = {(entity, dictionary, parentProtoRecord) -> NSCopying in
    let dict = dictionary as Dictionary
    let key: AnyObject? = dict["id"]
    let returnKey = key as String
    return returnKey
}

options.recordPrePopulationBlock = { protoRecord in
    let proto: MMRecordProtoRecord = protoRecord
    let entity: NSEntityDescription = protoRecord.entity
    
    var dictionary: AnyObject! = proto.dictionary.mutableCopy()
    var mutableDictionary: NSMutableDictionary = dictionary as NSMutableDictionary
    var primaryKey: AnyObject! = ""
    
    if (entity.name == "OutwardLink") {
        primaryKey = mutableDictionary.valueForKeyPath("outwardIssue.key")
    }
    
    if (entity.name == "InwardLink") {
        primaryKey = mutableDictionary.valueForKeyPath("inwardIssue.key")
    }
    
    mutableDictionary.setValue(primaryKey, forKey: "PrimaryKey")
    
    proto.dictionary = mutableDictionary
}

Issue.setOptions(options)

Issue.startRequestWithURN("/issue",
	data: nil,
	context: managedObjectContext,
	domain: self,
	resultBlock: { records in
   		var results: Issue[] = records as Issue[]
    	
    	self.results = results
    	self.tableView.reloadData()
	},
	failureBlock: { error in
    
	})
```

## Tweaks

MMRecord also provides the TweakModel subspec that implements support for Facebook Tweaks. You can use Tweaks to modify most MMRecord parsing and population parameters. This can be useful if you're working on an app where the API is in flux and is still being actively developed. The UI for Tweaks will show you a list of MMRecord entities in your data model, the primary key for each entity, all of the keys used to populate various attributes, and the key path that points to instances of that entity in the data model. Here's how you use it.

```objective-c
#define FBMMRecordTweakModelDefine
    [FBMMRecordTweakModel loadTweaksForManagedObjectModel:
        [MMDataManager sharedDataManager].managedObjectModel];
```

Thats all you need to enable Tweaks in your MMRecord project. As a best practice, you should only use the #define in Debug mode. 

After its setup, here's what the Tweaks UI looks like with MMRecord.


<p align="center">
  <img src="https://www.github.com/mutualmobile/MMRecord/raw/gh-pages/Images/MMRecord-tweaks.png") alt="MMRecord Tweaks UI"/>
</p>

## Debugging

`MMRecordDebugger` is a class used by `MMRecord` to provide debugging information back to you about how your model is configured and how MMRecord is handling the response handed to it by your server class. You can use MMRecordDebugger to help resolve issues that may exist in your model configuration, or identify inconsistencies with your response format.

MMRecord is designed to make it as fast and easy as possible to serialize managed objects from a web service. One of the goals of the library is to provide meaningful means of customization to support all sorts of response formats, while still maintaining an easy to use primary interface that does not require excessive configuration and setup. In most cases, the amount of configuration and customization required by a user of MMRecord will depend on how complex the response format of your web service is.

When MMRecord encounters an error while handling a request it may take a few measures based on the severity of the error.

- Assertions. In some cases, like if a managed object class being populated is not a subclass of MMRecord, an assertion will be thrown.
- Logs. In many cases, MMRecord will log a message containing the error to the console. By default MMRecord will not actually print anything to the console, unless you specify a logging level manually. This is for security reasons.
- Non-failure Errors. In some cases, MMRecord will create an `NSError` describing an issue, and associate it with the `MMRecordDebugger`. However, if the error isn't serious enough, the request will not fail.
- Failure Errors. In several cases, MMRecord will create an `NSError` describing a critical issue it encountered while handling a request. These errors are associated with the debugger, and will be passed back into the failureBlock indicating a reason that the request failed.

If you encounter issues with a request, your first step should be to enable MMRecord logging, using the command below.

```objective-c
[MMRecord setLoggingLevel:MMRecordLoggingLevelAll];
```

You can lower the logging level incrementally to receive finer grained logging information, but its a good idea to start with the highest level to get a broader picture of what is going on.

If your request is failing, you can use the `NSError` object that is passed into the failure block to review all sorts of data about the failure. The error parameter in the failure block will actually include the `MMRecordDebugger` instance, which contains all of the errors encountered while handling the request, and various bits of state relevant to the critical error.

The debugger is attached to the `NSError` in its userInfo dictionary. Here's an example of how you can use it.

```objective-c
     failureBlock:^(NSError *error) {
         NSDictionary *recordDictionary = [[error userInfo] valueForKey:MMRecordDebuggerParameterRecordDictionary];
         
         MMRecordDebugger *debugger = [[error userInfo] valueForKey:MMRecordDebuggerKey];
         NSArray *allErrors = [debugger errorsEncounteredWhileHandlingResponse];
         id responseObject = [debugger responseObject];
         NSString *entityName = [[debugger initialEntity] name];
     }];
```

If you encounter errors that you would like to see tracked, or have suggestions about the severity of some errors, please create an issue or file a pull request.

## Requirements

MMRecord 1.4.0 and higher requires either [iOS 6.0](https://developer.apple.com/library/ios/releasenotes/General/WhatsNewIniOS/Articles/iOS6.html) and above, or [Mac OS 10.8](https://developer.apple.com/library/mac/releasenotes/macosx/whatsnewinosx/Articles/MacOSX10_8.html) ([64-bit with modern Cocoa runtime](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtVersionsPlatforms.html)) and above.

### ARC

MMRecord uses ARC.

If you are using MMRecord in your non-arc project, you will need to set a `-fobjc-arc` compiler flag on all of the MMRecord source files.

## Credits

MMRecord was created by [Conrad Stoll](http://conradstoll.com) at [Mutual Mobile](http://www.mutualmobile.com).

## License

MMRecord is available under the MIT license. See the LICENSE file for more info.
