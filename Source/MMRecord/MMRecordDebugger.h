//
// MMRecordDebugger.h
//
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMRecordOptions;

/**
 MMRecordLoggingLevel is used to determine when certain messages get logged. The default logging
 level is none. MMRecord can support Cocoa Lumberjack. Logging level is ignored when 
 Cocoa Lumberjack is used.
 */
typedef NS_ENUM(NSInteger, MMRecordLoggingLevel) {
    MMRecordLoggingLevelNone = 0,
    MMRecordLoggingLevelInfo = 1,
    MMRecordLoggingLevelDebug = 2,
    MMRecordLoggingLevelAll = 999
};

// MMRecordErrorDomain is the domain used for all errors created and returned by MMRecordDebugger
FOUNDATION_EXTERN NSString * const MMRecordErrorDomain;

/**
 MMRecordDebuggerKey can be used to access the instance of MMRecordDebugger on
 the error object's userInfo dictionary. You may want to use this to view all
 errors encountered on the population process, as well as metadata about the
 request itself, including the response object and initial entity.
 */
FOUNDATION_EXTERN NSString * const MMRecordDebuggerKey;

/**
 MMRecordDebuggerParameters are keys used to pass information along to
 MMRecordDebugger when asking it to handle an error. These identify
 specific objects that the debugger can use to customize its debugging
 information.
 
 These keys can also be used to access their associated objects from within
 an error's userInfo dictionary if those objects have been passed into the
 handleErrorCode:withParameters: method defined below.
 */
FOUNDATION_EXTERN NSString * const MMRecordDebuggerParameterErrorDescription;
FOUNDATION_EXTERN NSString * const MMRecordDebuggerParameterResponseObject;
FOUNDATION_EXTERN NSString * const MMRecordDebuggerParameterRecordClassName;
FOUNDATION_EXTERN NSString * const MMRecordDebuggerParameterKeyPathForResponseObject;
FOUNDATION_EXTERN NSString * const MMRecordDebuggerParameterEntityDescription;
FOUNDATION_EXTERN NSString * const MMRecordDebuggerParameterPropertyName;
FOUNDATION_EXTERN NSString * const MMRecordDebuggerParameterRecordDictionary;
FOUNDATION_EXTERN NSString * const MMRecordDebuggerParameterServerClassName;


/**
 Error codes used by MMRecord to describe various error conditions.
 */
typedef NS_ENUM(NSInteger, MMRecordErrorCode) {
    MMRecordErrorCodeUndefinedServer          = 1,
    MMRecordErrorCodeUndefinedPageManager     = 2,
    MMRecordErrorCodeMissingRecordPrimaryKey  = 3,
    MMRecordErrorCodeInvalidEntityDescription = 4,
    MMRecordErrorCodeInvalidResponseFormat    = 6,
    MMRecordErrorCodeEmptyResultSet           = 7,
    MMRecordErrorCodeCoreDataFetchError       = 700,
    MMRecordErrorCodeCoreDataSaveError        = 701,
    MMRecordErrorCodeUnknown                  = 999
};


/**
 This class is intended as the primary access point for debugging model configuration
 and response handling issues and errors that may occur while building your application
 with MMRecord. This class is called a Debugger to indicate that it is not intended
 to be used in production. It is designed to help you while configuring your
 model and setting up your requests.
 
 You may still use MMRecordDebugger to handle actual errors in a production setting.
 However, you should also understand that these issues typically should never happen
 in production, and likely mean that your API has broken or is experiencing
 unexpected behavior. Please plan accordingly.
 
 MMRecordDebugger combines both error handling and debug logging to provide you with
 helpful feedback about issues in your model configuration and response handling.
 The type of errors handled by the debugger are listed above. Those errors
 will be added to over time to provide even more helpful feedback.
 */
@interface MMRecordDebugger : NSObject

/**
 The responseObject returned by the request associated with this debugger.
 */
@property (nonatomic, strong) id responseObject;

/**
 The initialEntity where the request associated with this debugger started.
 */
@property (nonatomic, strong) NSEntityDescription *initialEntity;

/**
 The logging level for the debugger.
 
 @discussion The default for this is the default set on MMRecord.
 @discussion The default for MMRecord is MMRecordLoggingLevelNone.
 */
@property (nonatomic) MMRecordLoggingLevel loggingLevel;

/**
 This method is the workhorse of the debugger. This method should be
 called to indicate that an error has been encountered and that it should
 be tracked by the debugger.
 
 Calling this method will create an NSError object with the appropriate
 code and error description. An instance of the debugger will also exist
 in the error's userInfo dictionary.
 
 Depending on your logging level settings, this error also may or may
 not be logged to the console.
 
 @param errorCode The error code to handle.
 @param parameters Custom parameters to provide additional information about the
 error. These parameters will also be included in the error's userInfo
 dictionary.
 */
- (void)handleErrorCode:(MMRecordErrorCode)errorCode
         withParameters:(NSDictionary *)parameters;

/**
 This method can be used to log a helpful message through the debugger.
 The message will only be logged if its minimumLoggingLevel is lower than
 or equal to the current debugger logging level.
 
 @param description The message you want to display in the log.
 @param loggingLevel The minimum logging level for the log message.
 */
- (void)logMessageWithDescription:(NSString *)description
              minimumLoggingLevel:(MMRecordLoggingLevel)loggingLevel;

/**
 This method can be used to log a helpful message through the debugger.
 This message will be handled in a stateless fashion, and will leverage the current logging level
 set on MMRecord itself.
 @param description The message you want to display in the log.
 @warning Messages sent to this method will ONLY be logged if the logging level from MMRecord is
 set to MMRecordLoggingLevelAll.
 @discussion This method will only log messages when the logging level is set to ALL in order to
 prevent excessive messages being sent to the console, and also to ensure that only the highest
 level of logging will include messages sent in a stateless fashion.
 */
+ (void)logMessageWithDescription:(NSString *)description;

/**
 This is the main error that is associated with this debugger instance. This will be the error
 that gets shown in an MMRecord failureBlock.
 @return NSError an error object with an MMRecord error code and domain.
 */
- (NSError *)primaryError;

/**
 Way to provide access to every single error thrown by MMRecord.
 @return NSArray an array of errors encountered while handling the response.
 */
- (NSArray *)errorsEncounteredWhileHandlingResponse;

/**
 This method can be used to determine if a serious error representing a condition that causes
 MMRecord's request handling process to fail has occurred. If that has happened then the highest
 priority error will be present in the primaryError accessor.
 
 @return BOOL YES if a failing error has been encountered, otherwise NO.
 */
- (BOOL)encounteredFailureCondition;

/**
 Convenience method for setting up a parameters dictionary with keys and values.
 
 @param keys An array of MMRecordDebuggerParameter keys
 @param values An array of objects to associate with the given keys.
 */
- (NSDictionary *)parametersWithKeys:(NSArray *)keys values:(NSArray *)values;

@end
