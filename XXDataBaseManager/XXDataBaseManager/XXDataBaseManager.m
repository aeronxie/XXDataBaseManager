//
//  XXDataBaseManager.m
//  XXDataBaseManager
//
//  Created by Fay on 2018/5/5.
//  Copyright © 2018年 com.fire. All rights reserved.
//

#import "XXDataBaseManager.h"
#import "FMDB.h"
#import "NSString+Tools.h"
#import <objc/runtime.h>



static NSString *const kDefaultDBName = @"__xxdatabase__.sqlite";

@interface XXDataBaseManager ()

@property (nonatomic, strong) NSString *dbPath;
@property (nonatomic, strong) FMDatabaseQueue *fmdbQueue;
@property (nonatomic, strong) FMDatabase *fmdb;

@end


@implementation XXDataBaseManager

static XXDataBaseManager *_xxdb = nil;

+ (instancetype)sharedDataBase {
	return [self shareDataBaseWithName:nil];
}

+ (instancetype)shareDataBaseWithName:(NSString *)dbName {
	return [self shareDataBaseWithName:dbName dbPath:nil];
}

+ (instancetype)shareDataBaseWithName:(NSString *)dbName dbPath:(NSString *)dbPath {
	if (!_xxdb) {
		if ([dbName isEmptyString]) {
			dbName = kDefaultDBName;
		}
		if ([dbPath isEmptyString]) {
			dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:dbName];
		} else {
			dbPath = [dbPath stringByAppendingPathComponent:dbName];
		}
		
		FMDatabase *fmdb = [FMDatabase databaseWithPath:dbPath];
		if ([fmdb open]) {
			_xxdb = [[XXDataBaseManager alloc] init];
			_xxdb.fmdb = fmdb;
			_xxdb.dbPath = dbPath;
		}
	}
	if (![_xxdb.fmdb open]) {
		return nil;
	};
	return _xxdb;
}

- (BOOL)createTableWithName:(NSString *)tableName model:(id)model excludeKeys:(NSArray *)excludeKeys {
	if (!model || [tableName isEmptyString]) {
		return NO;
	}
	Class cls;
	if ([model isKindOfClass:[NSString class]]) {
		cls = NSClassFromString(model);
	} else if ([model isKindOfClass:[NSObject class]]) {
		cls = [model class];
	} else {
		cls = model;
	}
	NSMutableString *createSQL = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (uniqueid INTEGER PRIMARY KEY,", tableName];
	
	unsigned count = 0;
	objc_property_t *properties = class_copyPropertyList(cls, &count);
	
	for (NSInteger i = 0; i < count; i++) {
		NSString *propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
		
		if (excludeKeys && [excludeKeys containsObject:propertyName]) continue;
		
		NSString *propertyType = [NSString stringWithCString:property_getAttributes(properties[i]) encoding:NSUTF8StringEncoding];
		
		NSString *type = [propertyType convertPropertyType];

		[createSQL appendFormat:@" %@ %@,", propertyName, type];
	}
	[createSQL deleteCharactersInRange:NSMakeRange(createSQL.length - 1, 1)];
	[createSQL appendString:@")"];

	return [_fmdb executeUpdate:createSQL];
}

- (BOOL)createTableWithName:(NSString *)tableName dic:(NSDictionary *)dic excludeKeys:(NSArray *)excludeKeys {
	
	if ([tableName isEmptyString] || !dic) {
		return NO;
	}
	NSMutableString *createSQL = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (uniqueid INTEGER PRIMARY KEY,", tableName];
	
	for (NSString *key in dic.allKeys) {
		if (excludeKeys && [excludeKeys containsObject:key]) continue;
		[createSQL appendFormat:@" %@ %@,", key, dic[key]];
	}
	[createSQL deleteCharactersInRange:NSMakeRange(createSQL.length - 1, 1)];
	[createSQL appendString:@")"];
	return [_fmdb executeUpdate:createSQL];
}






+ (void)resetDataBase {
	NSFileManager *manager = [NSFileManager defaultManager];
	if ([manager fileExistsAtPath:_xxdb.dbPath]) {
		if ([manager removeItemAtPath:_xxdb.dbPath error:nil]) {
			_xxdb = nil;
			[self sharedDataBase];
		}
	}
}

@end
