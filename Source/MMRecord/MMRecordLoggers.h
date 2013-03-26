//
//  MMRecordLoggers.h
//  
//
//  Created by Lars Anderson on 3/25/13.
//
//

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

#define MMRecordLogUndefine #undefine MMRLogInfo\
#undefine MMRLogWarn\
#undef MMRLogError\
#undef MMRLogVerbose\