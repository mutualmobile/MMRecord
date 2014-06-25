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

// List of parameter keys for the parameters dictionary
// Pass in things like the entity name, or entity description, or primary key, etc.
// Provide easy constructors for doing these things

// Combination of Logging and Error Handling
@interface MMRecordDebugger : NSObject

// Workhorse
// Called for every error condition
// May or may not print out to the log based on log level settings
- (void)handleErrorCode:(MMRecordErrorCode)errorCode
         withParameters:(NSDictionary *)parameters;

// Main error that will get shown in failure block
- (NSError *)primaryError;

// Way to provide access to every single error thrown by MMRecord
- (NSArray *)errorsEncounteredWhileHandlingResponse;

@end
