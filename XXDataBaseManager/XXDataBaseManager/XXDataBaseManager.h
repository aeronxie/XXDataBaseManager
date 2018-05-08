//
//  XXDataBaseManager.h
//  XXDataBaseManager
//
//  Created by Fay on 2018/5/5.
//  Copyright © 2018年 com.fire. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXDataBaseManager : NSObject

+ (instancetype)sharedDataBase;
+ (instancetype)shareDataBaseWithName:(NSString *)dbName;
+ (instancetype)shareDataBaseWithName:(NSString *)dbName dbPath:(NSString *)dbPath;

- (BOOL)createTableWithName:(NSString *)tableName model:(id)model excludeKeys:(NSArray *)excludeKeys;
- (BOOL)createTableWithName:(NSString *)tableName dic:(NSDictionary *)dic excludeKeys:(NSArray *)excludeKeys;

- (BOOL)insertDataModel:(id)model inTable:(NSString *)tableName;
- (BOOL)insertDataModelArray:(NSArray *)models inTable:(NSString *)tableName;

- (BOOL)deleteDataInTable:(NSString *)tableName whereFormat:(NSString *)format, ...;
- (BOOL)deleteAllDataInTable:(NSString *)tableName;
- (BOOL)deleteLastDataInTable:(NSString *)tableName;
- (BOOL)deleteTable:(NSString *)tableName;

- (BOOL)updateDataInTable:(NSString *)tableName parameters:(NSDictionary *)parameters whereFormat:(NSString *)format, ...;

- (NSArray *)lookupDataInTable:(NSString *)tableName model:(id)model whereFormat:(NSString *)format, ...;
- (NSInteger)allDataCountInTable:(NSString *)tableName;
- (NSArray *)getFieldNamesWithTableName:(NSString *)tableName;

- (BOOL)alterFieldNameInTable:(NSString *)tableName parameters:(NSDictionary *)parameters;
- (BOOL)isExistTable:(NSString *)tableName;

- (void)inDataBase:(void(^)(void))block;
- (void)inTransaction:(void(^)(BOOL *rollback))block;

+ (void)resetDataBase;

- (void)close;
- (void)open;

@end
