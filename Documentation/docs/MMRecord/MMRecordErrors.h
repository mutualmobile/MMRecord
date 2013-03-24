//
//  MMRecordErrors.h
//  MMRecord
//
//  TODO: Replace with License Header
//

#import <Foundation/Foundation.h>

NSString * const MMRecordErrorDomain;

/**
 Error codes used by MMRecord to describe various error conditions. 
 */
typedef NS_ENUM(NSInteger, MMRecordErrorCode) {
    MMRecordErrorCodeUndefinedServer          = 1,
    MMRecordErrorCodeUndefinedPageManager     = 2,
    MMRecordErrorCodeMissingRecordPrimaryKey  = 3,
    MMRecordErrorCodeInvalidEntityDescription = 4,
    MMRecordErrorCodeCoreDataFetchError       = 5,
    MMRecordErrorCodeInvalidResponseFormat    = 6,
    MMRecordErrorCodeUnknown                  = 999
};
