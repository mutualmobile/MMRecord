//
// MMRecordDebugger.m
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

#import "MMRecordDebugger.h"

#import "MMRecord.h"

#ifdef LOG_VERBOSE
#define MMRLogInfo(fmt, ...) DDLogInfo((@"--[MMRecord INFO]-- %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define MMRLogWarn(fmt, ...) DDLogWarn((@"--[MMRecord WARNING]-- %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define MMRLogError(fmt, ...) DDLogError((@"--[MMRecord ERROR]-- %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define MMRLogVerbose(fmt, ...) DDLogVerbose((@"--[MMRecord]-- %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define MMRLogInfo(fmt, ...) NSLog((@"--[MMRecord INFO]-- %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define MMRLogWarn(fmt, ...) NSLog((@"--[MMRecord WARNING]-- %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define MMRLogError(fmt, ...) NSLog((@"--[MMRecord ERROR]-- %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define MMRLogVerbose(fmt, ...) NSLog((@"--[MMRecord]-- %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#endif

#ifdef LOG_VERBOSE
#define MMRecordLumberjack 1
#else
#define MMRecordLumberjack 0
#endif

NSString* const MMRecordErrorDomain = @"com.mutualmobile.mmrecord";
NSString* const MMRecordDebuggerKey = @"MMRecordDebuggerKey";

NSString* const MMRecordDebuggerParameterErrorDescription = @"MMRecordDebuggerParameterErrorDescription";
NSString* const MMRecordDebuggerParameterResponseObject = @"MMRecordDebuggerParameterResponseObject";
NSString* const MMRecordDebuggerParameterRecordClassName = @"MMRecordDebuggerParameterRecordClassName";
NSString* const MMRecordDebuggerParameteryKeyPathForResponseObject = @"MMRecordDebuggerParameterKeyPathForResponseObject";
NSString* const MMRecordDebuggerParameterEntityDescription = @"MMRecordDebuggerParameterEntityDescription";
NSString* const MMRecordDebuggerParameterPropertyName = @"MMRecordDebuggerParameterPropertyName";
NSString* const MMRecordDebuggerParameterRecordDictionary = @"MMRecordDebuggerParameterRecordDictionary";
NSString* const MMRecordDebuggerParameterServerClassName = @"MMRecordDebuggerParameterServerClassName";

@interface MMRecordDebugger ()

@property (nonatomic, strong) NSMutableArray *errors;
@property (nonatomic, strong) NSError *primaryError;

@end

@implementation MMRecordDebugger

- (id)init {
    if ((self = [super init])) {
        _errors = [NSMutableArray array];
        _loggingLevel = [MMRecord loggingLevel];
    }
    
    return self;
}

- (void)handleErrorCode:(MMRecordErrorCode)errorCode withParameters:(NSDictionary *)parameters {
    BOOL failureConditionError = [self failureConditionEncounteredWithErrorCode:errorCode];
    NSString *errorDescription = [self errorDescriptionWithErrorCode:errorCode
                                                          parameters:parameters];
    NSError *error = [self errorWithErrorCode:errorCode
                                  description:errorDescription
                                   parameters:parameters];
    
    if (failureConditionError) {
        self.primaryError = error;
    }
    
    [self.errors addObject:error];
    
    [self logMessageForCode:errorCode description:errorDescription];
}

- (NSArray *)errorsEncounteredWhileHandlingResponse {
    return self.errors;
}

- (BOOL)encounteredFailureCondition {
    if (self.primaryError) {
        return YES;
    }
    
    return NO;
}

- (NSDictionary *)parametersWithKeys:(NSArray *)keys values:(NSArray *)values {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    return parameters;
}

- (void)logMessageWithDescription:(NSString *)description
              minimumLoggingLevel:(MMRecordLoggingLevel)loggingLevel {
    [self logMessageWithDescription:description
                minimumLoggingLevel:loggingLevel
                   failureCondition:NO
                 informationMessage:YES];
}

- (void)logMessageWithDescription:(NSString *)description
              minimumLoggingLevel:(MMRecordLoggingLevel)loggingLevel
                 failureCondition:(BOOL)failureCondition
               informationMessage:(BOOL)informationMessage {
    BOOL shouldPerformLog = [[self class] shouldPerformLogForLoggingLevel:loggingLevel
                                                             currentLevel:self.loggingLevel];

    if (shouldPerformLog) {
        [[self class] logMessageWithDescription:description
                               failureCondition:failureCondition
                             informationMessage:informationMessage];
    }
}

+ (void)logMessageWithDescription:(NSString *)description
                 failureCondition:(BOOL)failureCondition
               informationMessage:(BOOL)informationMessage {
#if MMRecordLumberjack
    if (failureCondition) {
        MMRLogError(@"%@.", description);
    } else if (informationMessage) {
        MMRLogInfo(@"%@.", description);
    } else {
        MMRLogWarn(@"%@.", description);
    }
#else
    NSString *logPrefix = @"--[MMRecord WARNING]-- %@.";
    
    if (failureCondition) {
        logPrefix = @"--[MMRecord ERROR]-- %@.";
    } else if (informationMessage) {
        logPrefix = @"--[MMRecord INFO]-- %@.";
    }
    
    NSLog(logPrefix, description);
#endif
}

- (MMRecordLoggingLevel)loggingLevelForErrorCode:(MMRecordErrorCode)errorCode {
    switch (errorCode) {
        case MMRecordErrorCodeMissingRecordPrimaryKey:
            return MMRecordLoggingLevelInfo;
        case MMRecordErrorCodeUndefinedServer:
            return MMRecordLoggingLevelInfo;
        case MMRecordErrorCodeUndefinedPageManager:
            return MMRecordLoggingLevelInfo;
        case MMRecordErrorCodeInvalidEntityDescription:
            return MMRecordLoggingLevelInfo;
        case MMRecordErrorCodeEmptyResultSet:
            return MMRecordLoggingLevelInfo;
        default:
            break;
    }
    
    return MMRecordLoggingLevelAll;
}

+ (BOOL)shouldPerformLogForLoggingLevel:(MMRecordLoggingLevel)minimumLevel
                           currentLevel:(MMRecordLoggingLevel)currentLevel {
    // Any logging level equal to or lower than the current level should be logged.
    if (currentLevel >= minimumLevel &&
        currentLevel > MMRecordLoggingLevelNone) {
        return YES;
    }
    
    return NO;
}

- (BOOL)failureConditionEncounteredWithErrorCode:(MMRecordErrorCode)errorCode {
    if (errorCode == MMRecordErrorCodeUndefinedServer ||
        errorCode == MMRecordErrorCodeUndefinedPageManager ||
        errorCode == MMRecordErrorCodeInvalidEntityDescription ||
        errorCode == MMRecordErrorCodeInvalidResponseFormat ||
        errorCode == MMRecordErrorCodeCoreDataFetchError ||
        errorCode == MMRecordErrorCodeCoreDataSaveError) {
        return YES;
    }
    
    return NO;
}

- (NSString *)errorDescriptionWithErrorCode:(MMRecordErrorCode)errorCode
                                 parameters:(NSDictionary *)parameters {
    NSString *errorDescription = [self descriptionForErrorCode:errorCode];
    
    if (errorCode == MMRecordErrorCodeCoreDataFetchError ||
        errorCode == MMRecordErrorCodeCoreDataSaveError) {
        NSString *parameterErrorDescription = [parameters objectForKey:MMRecordDebuggerParameterErrorDescription];
        
        if (parameterErrorDescription) {
            errorDescription = [errorDescription stringByAppendingString:parameterErrorDescription];
        }
    }
    
    return errorDescription;
}

- (void)logMessageForCode:(MMRecordErrorCode)errorCode description:(NSString *)description {
    MMRecordLoggingLevel loggingLevel = [self loggingLevelForErrorCode:errorCode];
    BOOL failureConditionError = [self failureConditionEncounteredWithErrorCode:errorCode];

    [self logMessageWithDescription:description
                minimumLoggingLevel:loggingLevel
                   failureCondition:failureConditionError
                 informationMessage:NO];
}

+ (void)logMessageWithDescription:(NSString *)description {
    BOOL shouldPerformLog = [self shouldPerformLogForLoggingLevel:MMRecordLoggingLevelAll
                                                     currentLevel:[MMRecord loggingLevel]];
    
    if (shouldPerformLog) {
        [self logMessageWithDescription:description failureCondition:NO informationMessage:YES];
    }
}

- (NSString *)descriptionForErrorCode:(MMRecordErrorCode)errorCode {
    NSString *result = nil;
    switch (errorCode) {
        case MMRecordErrorCodeUndefinedServer:
            result = NSLocalizedString(@"Undefined Server. A server class must be registered with MMRecord in order to start requests.",
                                       @"A server class must be registered with MMRecord in order to start requests.");
            break;
        case MMRecordErrorCodeUndefinedPageManager:
            result = NSLocalizedString(@"Missing Page Manager. A page manager class must be defined on your MMServer subclass in order to use paging.",
                                       @"A page manager class must be defined on your MMServer subclass in order to use paging.");
            break;
        case MMRecordErrorCodeInvalidEntityDescription:
            result = NSLocalizedString(@"Invalid Entity Description. This could be because this record class is not used in your managed object model, or because your persistent store coordinator or managed object model are not defined properly. An entity description is required for creating records.",
                                       @"This could be because this record class is not used in your managed object model, or because your persistent store coordinator or managed object model are not defined properly. An entity description is required for creating records.");
            break;
        case MMRecordErrorCodeInvalidResponseFormat:
            result = NSLocalizedString(@"Invalid Response Format.",
                                       @"The server response was in an unexpected format that could not be handled by MMRecord.");
            break;
        case MMRecordErrorCodeEmptyResultSet:
            result = NSLocalizedString(@"Empty Result Set.", @"The result set returned from the server is empty. This is a warning, and may not be the result an error.");
            break;
        case MMRecordErrorCodeMissingRecordPrimaryKey:
            result = NSLocalizedString(@"Missing Record Primary Key. No primary key was found for this proto record. This could mean that the primary key was not defined on the Managed Object Model, or that no primary key was injected into the population process.",
                                       @"Missing Record Primary Key. No primary key was found for this proto record. This could mean that the primary key was not defined on the Managed Object Model, or that no primary key was injected into the population process.");
            break;
        case MMRecordErrorCodeCoreDataFetchError:
        case MMRecordErrorCodeCoreDataSaveError:
            result = NSLocalizedString(@"Core Data Error.",
                                       @"Core Data Error.");
            break;
        default:
        case MMRecordErrorCodeUnknown:
            result = NSLocalizedString(@"Unknown Error",
                                       @"Unknown Error Description");
            break;
    }
    
    return result;
}

- (NSError *)errorWithErrorCode:(MMRecordErrorCode)errorCode
                    description:(NSString *)description
                     parameters:(NSDictionary *)parameters {
    NSString *errorDescription = [[self descriptionForErrorCode:errorCode] stringByAppendingFormat:@" %@", description];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjects:@[errorDescription, self]
                                                         forKeys:@[NSLocalizedDescriptionKey, MMRecordDebuggerKey]];
    
    [userInfo addEntriesFromDictionary:parameters];
    
    NSError *error = [[NSError alloc] initWithDomain:MMRecordErrorDomain
                                                code:errorCode
                                            userInfo:userInfo];
    
    return error;
}

@end


#undef MMRLogInfo
#undef MMRLogWarn
#undef MMRLogError
#undef MMRLogVerbose

