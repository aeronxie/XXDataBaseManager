//
//  ViewController.m
//  XXDataBaseManager
//
//  Created by Fay on 2018/5/5.
//  Copyright © 2018年 com.fire. All rights reserved.
//

#import "ViewController.h"
#import "XXDataBaseManager.h"

@interface Person : NSObject

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSNumber *phoneNum;
@property (nonatomic, strong)NSData *photoData;
@property (nonatomic, assign)NSInteger luckyNum;
@property (nonatomic, assign)BOOL sex;
@property (nonatomic, assign)int age;
@property (nonatomic, assign)float height;
@property (nonatomic, assign)double weight;

@end

@implementation Person

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[[XXDataBaseManager sharedDataBase] createTableWithName:@"user" model:[Person class] excludeKeys:@[@"luckyNum"]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	Person *per = [Person new];
	per.name = @"daming";
	per.phoneNum = @(1004567890000);
	per.photoData = [NSData data];
	per.sex = YES;
	per.age = 1000;
	per.height = 123;
	per.height = 60;
	[[XXDataBaseManager sharedDataBase] insertDataModel:per inTable:@"user"];
}



- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
