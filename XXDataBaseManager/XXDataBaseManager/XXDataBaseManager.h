//
//  XXDataBaseManager.h
//  XXDataBaseManager
//
//  Created by Fay on 2018/5/5.
//  Copyright © 2018年 com.fire. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXDataBaseManager : NSObject

/**
  Get DataBase

 @return instance
 */
+ (instancetype)sharedDataBase;

/**
 Get DataBase

 @param dbName DataBase Name
 @return instance
 */
+ (instancetype)shareDataBaseWithName:(NSString *)dbName;

/**
 Get DataBase

 @param dbName DataBase Name
 @param dbPath DataBase Path
 @return instance
 */
+ (instancetype)shareDataBaseWithName:(NSString *)dbName dbPath:(NSString *)dbPath;


/**
 Create Table
 @param tableName 表名
 @param model 数据模型，可以是字符串，对象，类
 @param excludeKeys 模型中哪些字段不需要创建
 @return 是否创建成功
 */
- (BOOL)createTableWithName:(NSString *)tableName model:(id)model excludeKeys:(NSArray *)excludeKeys;

/**
 Create Table

 @param tableName 表名
 @param dic 字段名，value 必须是 @"TEXT" @"INTEGER" @"REAL" (浮点) @"BLOB"（对象） 其中一种
 @param excludeKeys 模型中哪些字段不需要创建
 @return 是否创建成功
 */
- (BOOL)createTableWithName:(NSString *)tableName dic:(NSDictionary *)dic excludeKeys:(NSArray *)excludeKeys;

/**
 往表中插入一条数据

 @param model 数据模型，可传类，实例，字符串
 @param tableName 表名
 @return 是否插入成功
 */
- (BOOL)insertDataModel:(id)model inTable:(NSString *)tableName;

/**
 往表中插入一组数据

 @param models 模型数组
 @param tableName 表名
 @return 是否插入成功
 */
- (BOOL)insertDataModelArray:(NSArray *)models inTable:(NSString *)tableName;

/**
 删除表中数据

 @param tableName 表名
 @param format 删除语句  例：where name = 'daming'
 @return 是否删除成功
 */
- (BOOL)deleteDataInTable:(NSString *)tableName whereFormat:(NSString *)format, ...;

/**
 删除表中所有数据

 @param tableName 表名
 @return 是否删除成功
 */
- (BOOL)deleteAllDataInTable:(NSString *)tableName;

/**
 删除表中最后一条数据

 @param tableName 表名
 @return 删除是否成功
 */
- (BOOL)deleteLastDataInTable:(NSString *)tableName;

/**
 删除数据库中的表

 @param tableName 表名
 @return 是否删除成功
 */
- (BOOL)deleteTable:(NSString *)tableName;

/**
 更新数据库

 @param tableName 表名
 @param parameters 需要更新的字段名跟内容 例： updateDataInTable:@"author" parameters:@{@"name":@"helloworld"}
 @param format 更新SQL语句 例：where name = 'daming' 传 nil 表示表中所有匹配字段名都要修改
 @return 是否更新成功
 */
- (BOOL)updateDataInTable:(NSString *)tableName parameters:(NSDictionary *)parameters whereFormat:(NSString *)format, ...;

/**
 查询表中数据

 @param tableName 表名
 @param model 数据模型
 @param format 查询SQL语句
 @return 返回一个模型数组
 */
- (NSArray *)lookupDataInTable:(NSString *)tableName model:(id)model whereFormat:(NSString *)format, ...;

/**
 表中所有数据数

 @param tableName 表名
 @return 表中数据记录
 */
- (NSInteger)allDataCountInTable:(NSString *)tableName;

/**
 获取表中的所有字段

 @param tableName 表名
 @return 表中所有字段
 */
- (NSArray *)getFieldNamesWithTableName:(NSString *)tableName;

/**
 表中新增字段

 @param tableName 表名
 @param parameters 字段名跟类型 @"TEXT" @"INTEGER" @"REAL" (浮点) @"BLOB"（对象） 例：  @{@"city":@"BLOB"}
 @return 是否新增成功
 */
- (BOOL)alterFieldNameInTable:(NSString *)tableName parameters:(NSDictionary *)parameters;

/**
 表是否已经存在

 @param tableName 表名
 @return 是否存在
 */
- (BOOL)isExistTable:(NSString *)tableName;

/**
 数据库多线程操作

 @param block 操作block
 */
- (void)inDataBase:(void(^)(void))block;

/**
 数据库事务操作，用于批量操作数据

 @param block 操作block
 */
- (void)inTransaction:(void(^)(BOOL *rollback))block;

/**
 重置数据库，地址为默认地址
 */
+ (void)resetDataBase;

/**
 关闭数据库
 */
- (void)close;

/**
 打开数据库
 */
- (void)open;

@end
