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
@end
