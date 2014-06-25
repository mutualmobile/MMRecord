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
 Use the method below to set the MMRecord Logging Level.  The default logging level is none.
 MMRecord can support Cocoa Lumberjack. Logging level is ignored when Cocoa Lumberjack is used.
 */

typedef NS_ENUM(NSInteger, MMRecordLoggingLevel) {
    MMRecordLoggingLevelNone = 0,
    MMRecordLoggingLevelInfo = 1,
    MMRecordLoggingLevelDebug = 2,
    MMRecordLoggingLevelAll = 999
};

NSString * const MMRecordErrorDomain;
NSString * const MMRecordDebuggerKey;

NSString * const MMRecordDebuggerPropertyErrorDescription;
NSString * const MMRecordDebuggerPropertyResponseObject;
NSString * const MMRecordDebuggerPropertyRecordClassName;
NSString * const MMRecordDebuggerPropertyEntityDescription;
NSString * const MMRecordDebuggerPropertyPropertyName;
NSString * const MMRecordDebuggerPropertyRecordDictionary;
NSString * const MMRecordDebuggerPropertyServerClassName;


/**
 Error codes used by MMRecord to describe various error conditions.
 */
typedef NS_ENUM(NSInteger, MMRecordErrorCode) {
    MMRecordErrorCodeUndefinedServer          = 1,
    MMRecordErrorCodeUndefinedPageManager     = 2,
    MMRecordErrorCodeMissingRecordPrimaryKey  = 3,
    MMRecordErrorCodeInvalidEntityDescription = 4,
    MMRecordErrorCodeInvalidResponseFormat    = 6,
    MMRecordErrorCodeCoreDataFetchError       = 700,
    MMRecordErrorCodeCoreDataSaveError        = 701,
    MMRecordErrorCodeUnknown                  = 999
};

// List of parameter keys for the parameters dictionary
// Pass in things like the entity name, or entity description, or primary key, etc.
// Provide easy constructors for doing these things

// Combination of Logging and Error Handling
@interface MMRecordDebugger : NSObject

@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSEntityDescription *initialEntity;

@property (nonatomic) MMRecordLoggingLevel loggingLevel;

// Workhorse
// Called for every error condition
// May or may not print out to the log based on log level settings
- (void)handleErrorCode:(MMRecordErrorCode)errorCode
         withParameters:(NSDictionary *)parameters;

- (void)logMessageWithDescription:(NSString *)description
              minimumLoggingLevel:(MMRecordLoggingLevel)loggingLevel;

// Main error that will get shown in failure block
- (NSError *)primaryError;

// Way to provide access to every single error thrown by MMRecord
- (NSArray *)errorsEncounteredWhileHandlingResponse;

- (BOOL)encounteredFailureCondition;

- (NSDictionary *)parametersWithKeys:(NSArray *)keys values:(NSArray *)values;

@end
