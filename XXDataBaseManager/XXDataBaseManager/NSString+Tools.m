//
//  NSString+Tools.m
//  XXDataBaseManager
//
//  Created by Fay on 2018/5/5.
//  Copyright © 2018年 com.fire. All rights reserved.
//

#import "NSString+Tools.h"

// 数据库中常见的几种类型
#define SQL_TEXT     @"TEXT" //文本
#define SQL_INTEGER  @"INTEGER" //int long integer ...
#define SQL_REAL     @"REAL" //浮点
#define SQL_BLOB     @"BLOB" //data


@implementation NSString (Tools)

- (BOOL)isEmptyString {
	if (self.length <= 0 || [self isEqualToString:@" "] || !self) {
		return YES;
	}
	return NO;
}

- (NSString *)convertPropertyType {
	NSString *resultStr = nil;
	if ([self hasPrefix:@"T@\"NSString\""]) {
		resultStr = SQL_TEXT;
	} else if ([self hasPrefix:@"T@\"NSData\""]) {
		resultStr = SQL_BLOB;
	} else if ([self hasPrefix:@"Ti"] || [self hasPrefix:@"TI"] || [self hasPrefix:@"Ts"] || [self hasPrefix:@"TS"] || [self hasPrefix:@"T@\"NSNumber\""] || [self hasPrefix:@"TB"] || [self hasPrefix:@"Tq"] || [self hasPrefix:@"TQ"]) {
		resultStr = SQL_INTEGER;
	} else if ([self hasPrefix:@"Tf"] || [self hasPrefix:@"Td"]) {
		resultStr= SQL_REAL;
	}
	return resultStr;
}


@end
