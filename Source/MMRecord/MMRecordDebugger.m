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

// This category adds custom errors and descriptions that describe error conditions in `MMRecord`.
@interface NSError (MMRecord)

+ (NSString*)descriptionForMCErrorCode:(MMRecordErrorCode)errorCode;
+ (NSError *)errorWithMMRecordCode:(MMRecordErrorCode)errorCode description:(NSString*)description;

@end

@interface MMRecordDebugger ()

@property (nonatomic, strong) NSMutableArray *errors;
@property (nonatomic, strong) NSError *primaryError;

@end

@implementation MMRecordDebugger

- (void)handleErrorCode:(MMRecordErrorCode)errorCode withParameters:(NSDictionary *)parameters {
    BOOL failureConditionError = [self failureConditionEncounteredWithErrorCode:errorCode];
    NSString *errorDescription = [self errorDescriptionWithErrorCode:errorCode parameters:parameters];
    NSError *error = [NSError errorWithMMRecordCode:errorCode description:errorDescription];
    
    if (failureConditionError) {
        self.primaryError = error;
    }
    
    [self.errors addObject:error];
    
    [self logMessageForCode:errorCode description:errorDescription isFatal:failureConditionError];
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

- (void)logMessageWithDescription:(NSString *)description minimumLoggingLevel:(MMRecordLoggingLevel)loggingLevel {
    
}

- (BOOL)failureConditionEncounteredWithErrorCode:(MMRecordErrorCode)errorCode {
    if (errorCode == MMRecordErrorCodeUndefinedServer ||
        errorCode == MMRecordErrorCodeUndefinedPageManager ||
        errorCode == MMRecordErrorCodeMissingRecordPrimaryKey ||
        errorCode == MMRecordErrorCodeInvalidEntityDescription ||
        errorCode == MMRecordErrorCodeInvalidResponseFormat ||
        errorCode == MMRecordErrorCodeCoreDataFetchError ||
        errorCode == MMRecordErrorCodeCoreDataSaveError) {
        return YES;
    }
    
    return NO;
}

- (NSString *)errorDescriptionWithErrorCode:(MMRecordErrorCode)errorCode parameters:(NSDictionary *)parameters {
    return [NSError descriptionForMCErrorCode:errorCode];
}

- (void)logMessageForCode:(MMRecordErrorCode)errorCode description:(NSString *)description isFatal:(BOOL)isFatal {
#if MMRecordLumberjack
    NSString *errorCodeDescription = [NSError descriptionForMCErrorCode:errorCode];
    
    if (isFatal) {
        MMRLogError(@"%@. %@", errorCodeDescription, description);
    }
    else{
        MMRLogWarn(@"%@. %@", errorCodeDescription, description);
    }
#else
    BOOL shouldLogMessage = NO;
    
    switch (self.loggingLevel) {
        case MMRecordLoggingLevelAll:
        case MMRecordLoggingLevelDebug:
        case MMRecordLoggingLevelInfo:
            shouldLogMessage = shouldLogMessage || errorCode == MMRecordErrorCodeMissingRecordPrimaryKey;
            shouldLogMessage = shouldLogMessage || errorCode == MMRecordErrorCodeUndefinedServer;
            shouldLogMessage = shouldLogMessage || errorCode == MMRecordErrorCodeUndefinedPageManager;
            shouldLogMessage = shouldLogMessage || errorCode == MMRecordErrorCodeInvalidEntityDescription;
            break;
        case MMRecordLoggingLevelNone:
            shouldLogMessage = NO;
        default:
            break;
    }
    
    if (shouldLogMessage) {
        NSString *logPrefix = @"--[MMRecord WARNING]-- %@. %@";
        
        if (isFatal) {
            logPrefix = @"--[MMRecord ERROR]-- %@. %@";
        }
        
        NSLog(logPrefix, [NSError descriptionForMCErrorCode:errorCode], description);
    }
#endif
}

@end

#pragma mark - Custom Error Additions

@implementation NSError (MMRecord)

+ (NSString *)descriptionForMCErrorCode:(MMRecordErrorCode)errorCode {
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
        default:
        case MMRecordErrorCodeUnknown:
            result = NSLocalizedString(@"Unknown Error",
                                       @"Unknown Error Description");
            break;
    }
    
    return result;
}

- (instancetype)initWithMMRecordCode:(MMRecordErrorCode)errorCode description:(NSString *)description {
    NSString *errorDescription = [[NSError descriptionForMCErrorCode:errorCode] stringByAppendingFormat:@" %@", description];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              errorDescription,NSLocalizedDescriptionKey,
                              nil];
    
    self = [self initWithDomain:MMRecordErrorDomain
                           code:errorCode
                       userInfo:userInfo];
    
    return self;
}

+ (NSError *)errorWithMMRecordCode:(MMRecordErrorCode)errorCode description:(NSString *)description {
    return [[NSError alloc] initWithMMRecordCode:errorCode description:description];
}

@end


#undef MMRLogInfo
#undef MMRLogWarn
#undef MMRLogError
#undef MMRLogVerbose

