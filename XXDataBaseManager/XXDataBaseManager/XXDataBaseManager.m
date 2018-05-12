//
//  XXDataBaseManager.m
//  XXDataBaseManager
//
//  Created by Fay on 2018/5/5.
//  Copyright © 2018年 com.fire. All rights reserved.
//

#import "XXDataBaseManager.h"
#import "FMDB.h"
#import <objc/runtime.h>

// 数据库中常见的几种类型
#define SQL_TEXT     @"TEXT" //文本
#define SQL_INTEGER  @"INTEGER" //int long integer ...
#define SQL_REAL     @"REAL" //浮点
#define SQL_BLOB     @"BLOB" //data


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
		if (isEmpty(dbName)) {
			dbName = kDefaultDBName;
		}
		if (isEmpty(dbPath)) {
            dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)        lastObject] stringByAppendingPathComponent:dbName];
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

#pragma mark ---- CURD

- (BOOL)createTableWithName:(NSString *)tableName model:(id)model excludeKeys:(NSArray *)excludeKeys {
	if ([self isExistTable:tableName] || !model || isEmpty(tableName)) {
		return NO;
	}
    Class cls = [self convertModelToClass:model];
    
	NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (uniqueID INTEGER PRIMARY KEY,", tableName];
	
	unsigned count = 0;
	objc_property_t *properties = class_copyPropertyList(cls, &count);
	
	for (NSInteger i = 0; i < count; i++) {
		NSString *propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
		
		if ((excludeKeys && [excludeKeys containsObject:propertyName]) || [propertyName isEqualToString:@"uniqueID"]) continue;
		
		NSString *propertyType = [NSString stringWithCString:property_getAttributes(properties[i]) encoding:NSUTF8StringEncoding];
		
		NSString *type = [self convertPropertyType:propertyType];

		[sql appendFormat:@" %@ %@,", propertyName, type];
	}
    free(properties);
	[sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
	[sql appendString:@")"];

	return [_xxdb.fmdb executeUpdate:sql];
}

- (BOOL)createTableWithName:(NSString *)tableName dic:(NSDictionary *)dic excludeKeys:(NSArray *)excludeKeys {
	if (isEmpty(tableName) || !dic) {
		return NO;
	}
	NSMutableString *createSQL = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (uniqueID INTEGER PRIMARY KEY,", tableName];

	for (NSString *key in dic.allKeys) {
		if (excludeKeys && [excludeKeys containsObject:key]) continue;
		[createSQL appendFormat:@" %@ %@,", key, dic[key]];
	}
	[createSQL deleteCharactersInRange:NSMakeRange(createSQL.length - 1, 1)];
	[createSQL appendString:@")"];
	return [_xxdb.fmdb executeUpdate:createSQL];
}

- (BOOL)insertDataModel:(id)model inTable:(NSString *)tableName {
    if (isEmpty(tableName)) {
        return NO;
    }
    NSMutableString *resultSql = [[NSMutableString alloc] initWithFormat:@"INSERT INTO %@ (", tableName];
	NSMutableString *argumentsSql = [[NSMutableString alloc] initWithFormat:@"("];
    NSDictionary *keyValues = [self modelToDic:model];
    NSArray *fieldNames = [self getFieldNamesWithTableName:tableName];
    NSMutableArray *values = @[].mutableCopy;

    for (NSString *key in keyValues.allKeys) {
        if (![fieldNames containsObject:key]) continue;
        [resultSql appendFormat:@"%@,",key];
        [argumentsSql appendString:@"?,"];
        [values addObject:keyValues[key]];
    }
    [argumentsSql deleteCharactersInRange:NSMakeRange(argumentsSql.length - 1, 1)];
    [argumentsSql appendFormat:@")"];
    [resultSql deleteCharactersInRange:NSMakeRange(resultSql.length - 1, 1)];
    [resultSql appendFormat:@") values "];
    [resultSql appendString:argumentsSql];

    BOOL succeed = [_xxdb.fmdb executeUpdate:resultSql withArgumentsInArray:values];
    return succeed;
}

- (BOOL)insertDataModelArray:(NSArray *)models inTable:(NSString *)tableName {
    if (!models || models.count == 0 || isEmpty(tableName)) {
        return NO;
    }
    __block BOOL succeed = YES;
    [self inTransaction:^(BOOL *rollback) {
        [models enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            succeed = [self insertDataModel:obj inTable:tableName];
            if (!succeed) {
                *rollback = YES;
                *stop = YES;
            }
        }];
    }];
    return succeed;
}

- (BOOL)deleteDataInTable:(NSString *)tableName whereFormat:(NSString *)format, ... {
    if (isEmpty(tableName)) {
        return NO;
    }
    va_list args;
    va_start(args, format);
    NSString *where = format ? [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args] : format;
    va_end(args);
    NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"DELETE FROM %@  %@", tableName, where];
    BOOL succeed = [_xxdb.fmdb executeUpdate:sql];
    return succeed;
}

- (BOOL)deleteAllDataInTable:(NSString *)tableName {
    if (isEmpty(tableName)) {
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    if (![_xxdb.fmdb executeUpdate:sql]) {
        return NO;
    }
    return YES;
}

- (BOOL)deleteLastDataInTable:(NSString *)tableName {
    return [self deleteDataInTable:tableName whereFormat:@"WHERE rowid = (SELECT max(rowid) FROM %@)",tableName];
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

- (BOOL)deleteTable:(NSString *)tableName {
    if (isEmpty(tableName)) return NO;
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    if (![_xxdb.fmdb executeUpdate:sql]) {
        return NO;
    }
    return YES;
}

- (BOOL)updateDataInTable:(NSString *)tableName parameters:(NSDictionary *)parameters whereFormat:(NSString *)format, ... {
    if (isEmpty(tableName) || !parameters || parameters.allKeys.count == 0) {
        return NO;
    }
    va_list args;
    va_start(args, format);
    NSString *where = format ? [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args] : format;
    va_end(args);
    
    NSMutableString *resultSql = [[NSMutableString alloc] initWithFormat:@"UPDATE %@ SET ", tableName];
    NSArray *fieldNames = [self getFieldNamesWithTableName:tableName];
    NSMutableArray *arguments = @[].mutableCopy;
    for (NSString *key in parameters.allKeys) {
        if (![fieldNames containsObject:key]) continue;
        [resultSql appendFormat:@"%@ = %@,", key, @"?"];
        [arguments addObject:parameters[key]];
    }
    [resultSql deleteCharactersInRange:NSMakeRange(resultSql.length - 1, 1)];
    if (where.length) [resultSql appendFormat:@" %@", where];
    BOOL succeed = [_xxdb.fmdb executeUpdate:resultSql withArgumentsInArray:arguments];
    return succeed;
}

- (NSArray *)lookupDataInTable:(NSString *)tableName model:(id)model whereFormat:(NSString *)format, ... {
    if (isEmpty(tableName))  return nil;

    va_list args;
    va_start(args, format);
    NSString *where = format ? [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args] : format;
    va_end(args);
    
    NSMutableDictionary *nameAndType = @{}.mutableCopy;
    NSArray *fieldNames = [self getFieldNamesWithTableName:tableName];
    Class cls = [self convertModelToClass:model];
    unsigned count = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &count);

    for (NSInteger i = 0; i < count; i++) {
        NSString *propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        if (!fieldNames || ![fieldNames containsObject:propertyName]) continue;
        NSString *propertyType = [NSString stringWithCString:property_getAttributes(properties[i]) encoding:NSUTF8StringEncoding];
        NSString *type = [self convertPropertyType:propertyType];
        [nameAndType setValue:type forKey:propertyName];
    }
    free(properties);
    
    NSMutableString *resultSql = [[NSMutableString alloc] initWithFormat:@"SELECT * FROM %@  %@", tableName, where ? where : @""];
    __block NSMutableArray *resultArray = @[].mutableCopy;

    [self inTransaction:^(BOOL *rollback) {
        FMResultSet *set = [_xxdb.fmdb executeQuery:resultSql];
        while ([set next]) {
            id model = [[cls alloc] init];
            for (NSString *name in nameAndType.allKeys) {
                if ([nameAndType[name] isEqualToString:SQL_TEXT]) {
                    [model setValue:[set stringForColumn:name] forKey:name];
                } else if ([nameAndType[name] isEqualToString:SQL_INTEGER]) {
                    [model setValue:@([set longLongIntForColumn:name]) forKey:name];
                } else if ([nameAndType[name] isEqualToString:SQL_REAL]) {
                    [model setValue:[NSNumber numberWithDouble:[set doubleForColumn:name]] forKey:name];
                } else if ([nameAndType[name] isEqualToString:SQL_BLOB]) {
                    [model setValue:[set dataForColumn:name] forKey:name];
                }
            }
            [resultArray addObject:model];
        }
    }];
    return resultArray;
}


- (BOOL)alterFieldNameInTable:(NSString *)tableName parameters:(NSDictionary *)parameters {
    if (isEmpty(tableName) || !parameters || parameters.count == 0) return NO;
    
    __block BOOL succeed = NO;
    [self inTransaction:^(BOOL *rollback) {
        NSArray *fieldNames = [self getFieldNamesWithTableName:tableName];
        for (NSString *key in parameters.allKeys) {
            if ([fieldNames containsObject:key]) continue;
            succeed = [_xxdb.fmdb executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, key, parameters[key]]];
            if (!succeed) {
                *rollback = YES;
                return;
            }
        }
    }];
    return succeed;
}

- (NSInteger)allDataCountInTable:(NSString *)tableName {
    if (isEmpty(tableName)) {
        return 0;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@", tableName];
    FMResultSet *set = [_xxdb.fmdb executeQuery:sql];
    while ([set next]){
        return [set intForColumn:@"count"];
    }
    return 0;
}

- (NSDictionary *)modelToDic:(id)model {
    if (!model) {
        return nil;
    }
    NSMutableDictionary *dic = @{}.mutableCopy;
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    
    for (NSInteger i = 0; i < outCount; i++) {
        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        id value = [model valueForKey:name];
        if (value) {
            [dic setValue:value forKey:name];
        } else {
            [dic setValue:[NSNull null] forKey:name];
        }
    }
    free(properties);
    return dic;
}

- (NSArray *)getFieldNamesWithTableName:(NSString *)tableName {
    NSMutableArray *fieldNames = @[].mutableCopy;
    FMResultSet *resultSet = [_xxdb.fmdb getTableSchema:tableName];
    while ([resultSet next]) {
        [fieldNames addObject:[resultSet stringForColumn:@"name"]];
    }
    return fieldNames;
}

- (BOOL)isExistTable:(NSString *)tableName {
    if (isEmpty(tableName)) return NO;
    FMResultSet *set = [_xxdb.fmdb executeQuery:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = ?", tableName];
    while ([set next]) {
        NSInteger count = [set intForColumn:@"count"];
        if (count == 0) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}


- (void)inDataBase:(void(^)(void))block {
    [self.fmdbQueue inDatabase:^(FMDatabase *db) {
        block();
    }];
}

- (void)inTransaction:(void(^)(BOOL *rollback))block {
    [self.fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        block(rollback);
    }];
}

- (void)close {
    [_xxdb.fmdb close];
}

- (void)open {
    [_xxdb.fmdb open];
}

#pragma mark ---- Private

- (Class)convertModelToClass:(id)model {
    if (!model) {
        return nil;
    }
    Class cls;
    if ([model isKindOfClass:[NSString class]]) {
        cls = NSClassFromString(model);
    } else if ([model isKindOfClass:[NSObject class]]) {
        cls = [model class];
    } else {
        cls = model;
    }
    return cls;
}

bool isEmpty(NSString *string) {
    if (string.length <= 0 || [string isEqualToString:@" "] || !string) {
        return true;
    }
    return false;
}

- (NSString *)convertPropertyType:(NSString *)name {
    NSString *resultStr = nil;
    if ([name hasPrefix:@"T@\"NSString\""]) {
        resultStr = SQL_TEXT;
    } else if ([name hasPrefix:@"T@\"NSData\""]) {
        resultStr = SQL_BLOB;
    } else if ([name hasPrefix:@"Ti"] || [name hasPrefix:@"TI"] || [name hasPrefix:@"Ts"] || [name hasPrefix:@"TS"] || [name hasPrefix:@"T@\"NSNumber\""] || [name hasPrefix:@"TB"] || [name hasPrefix:@"Tq"] || [name hasPrefix:@"TQ"]) {
        resultStr = SQL_INTEGER;
    } else if ([name hasPrefix:@"Tf"] || [name hasPrefix:@"Td"]) {
        resultStr= SQL_REAL;
    }
    return resultStr;
}

#pragma mark ---- Getter

- (FMDatabaseQueue *)fmdbQueue {
    if (!_fmdbQueue) {
        FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
        self.fmdbQueue = dbQueue;
        [_fmdb close];
        self.fmdb = [dbQueue valueForKey:@"_db"];
    }
    return _fmdbQueue;
}

@end
