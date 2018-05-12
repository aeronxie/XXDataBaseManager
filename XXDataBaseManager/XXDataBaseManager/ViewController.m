//
//  ViewController.m
//  XXDataBaseManager
//
//  Created by Fay on 2018/5/5.
//  Copyright © 2018年 com.fire. All rights reserved.
//

#import "ViewController.h"
#import "XXDataBaseManager.h"

@interface Author : NSObject

@property (nonatomic, assign) NSInteger uniqueID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSNumber *phoneNum;
@property (nonatomic, assign) NSInteger luckyNum;
@property (nonatomic, strong) NSData    *image;
@property (nonatomic, assign) BOOL sex;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) double height;
@property (nonatomic, assign) double weight;
@property (nonatomic, strong) NSString *nationality;

@end

@implementation Author

@end

@interface ViewController ()
@property (nonatomic,strong) UITableView *table;
@property (nonatomic,strong) UIButton *button1;
@property (nonatomic,strong) UIButton *button2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _button1=[UIButton buttonWithType:UIButtonTypeCustom];
    _button1.frame=CGRectMake(0,20,100,30);
    [_button1 setTitle:@"Button1" forState:UIControlStateNormal];
    [_button1 setTitle:@"插入一条数据" forState:UIControlStateHighlighted];
    [_button1 addTarget:self action:@selector(buttonAction1) forControlEvents:UIControlEventTouchUpInside];
    [_button1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_button1.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    _button1.titleLabel.font = [UIFont systemFontOfSize:16];
    
    _button2=[UIButton buttonWithType:UIButtonTypeCustom];
    _button2.frame=CGRectMake(150,20,100,30);
    [_button2 setTitle:@"Button2" forState:UIControlStateNormal];
    [_button2 setTitle:@"插入一组数据" forState:UIControlStateHighlighted];
    [_button2 addTarget:self action:@selector(buttonAction2) forControlEvents:UIControlEventTouchUpInside];
    [_button2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_button2.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    _button2.titleLabel.font = [UIFont systemFontOfSize:16];
    
    [self.view addSubview:_button1];
    [self.view addSubview:_button2];
    [XXDataBaseManager shareDataBaseWithName:@"helloworld.sqlite"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[XXDataBaseManager shareDataBaseWithName:@"helloworld.sqlite"] createTableWithName:@"author" model:[Author class] excludeKeys:@[@"luckyNum"]];
}

- (void)buttonAction1 {
    Author *author = [[Author alloc] init];
    author.uniqueID = arc4random() % 10000000;
    author.name = @"daming";
    author.city = @"beijing";
    author.phoneNum = @(13626262626);
    author.luckyNum = 123;
    author.image = UIImageJPEGRepresentation(([UIImage imageNamed:@"1.jpg"]), 1);
    author.sex = YES;
    author.age = 20;
    author.height = 145;
    author.weight = 60;
//    [[XXDataBaseManager sharedDataBase] insertDataModel:author inTable:@"author"];
//    [[XXDataBaseManager sharedDataBase] deleteDataInTable:@"author" whereFormat:@"where name = 'daming7'"];
//    [[XXDataBaseManager sharedDataBase] deleteAllDataInTable:@"author"];
//    [[XXDataBaseManager sharedDataBase] deleteTable:@"author"];
//    [[XXDataBaseManager sharedDataBase] updateDataInTable:@"author" parameters:@{@"name":@"helloworld"} whereFormat:@"where name = 'daming7'"];
//    [[XXDataBaseManager sharedDataBase] updateDataInTable:@"author" parameters:@{@"name":@"godlike"} whereFormat:nil];
//    NSArray *array = [[XXDataBaseManager sharedDataBase] lookupDataInTable:@"author" model:author whereFormat:@"where city = 'beijing'"];
//    NSArray *array = [[XXDataBaseManager sharedDataBase] lookupDataInTable:@"author" model:author whereFormat:@"order by uniqueID ASC"];
//    NSInteger count = [[XXDataBaseManager sharedDataBase] allDataCountInTable:@"author"];
//    [[XXDataBaseManager sharedDataBase] alterFieldNameInTable:@"author" parameters:@{@"nationality" : @"TEXT"}];
}

- (void)buttonAction2 {
    NSMutableArray *arr = @[].mutableCopy;
    for (int i = 0; i < 10; i++) {
        Author *author = [[Author alloc] init];
        author.uniqueID = arc4random() % 10000000;
        author.name = [NSString stringWithFormat:@"daming%d",i];
        author.city = (i % 2 == 0) ? @"beijing" : @"shanghai";
        author.phoneNum = @(13626262626);
        author.luckyNum = arc4random() % 200;
        author.image = UIImageJPEGRepresentation(([UIImage imageNamed:@"1.jpg"]), 1);
        author.sex = (i % 2 == 1) ? YES : NO;
        author.age = arc4random() % 100;
        author.height = arc4random() % 200 + 100;
        author.weight = arc4random() % 100;
        author.nationality = @"China";
        [arr addObject:author];
    }
    [[XXDataBaseManager sharedDataBase] insertDataModelArray:arr inTable:@"author"];
    
}


@end

