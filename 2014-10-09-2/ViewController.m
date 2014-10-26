//
//  ViewController.m
//  2014-10-09-2
//
//  Created by TTC on 10/9/14.
//  Copyright (c) 2014 TTC. All rights reserved.
//
//  此版本为自己编写的计算器, 修改以此版本为准
//  GitHub测试

#import "ViewController.h"
#import "CalculatorModel.h"

// 普通按钮起始尺寸
#define BUTTON_NORMAL_WIDTH    55
#define BUTTON_NORMAL_HEIGHT   45

// 首按钮起始位置
#define START_X_POS 33
#define START_Y_POS 85

// 普通按钮位置偏移
#define OFFSET_X    10
#define OFFSET_Y    10

// 无效字符
#define INVALID_CHAR @" "

@interface ViewController ()
{
    UILabel *_resultLabel; // 数字显示区
    UILabel *_displayLabel; // 显示已经输入的数
    BOOL _bIsEntering; // 是否正在输入
}
@property(strong, nonatomic) CalculatorModel *brain; // 计算器算法, 申明. 类似于NSString* 这个属性是个类
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"GitHub测试");
    
    // 显示已经输入的数
    _displayLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 25, 200, 20)];
    _displayLabel.text = @"";
    _displayLabel.textAlignment = NSTextAlignmentRight;
    [_displayLabel setFont:[UIFont fontWithName:@"Arial" size:15]];
    [self.view addSubview:_displayLabel];
    
    // 1_计算结果的Label
    _resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 240, 40)];
    _resultLabel.text = @"0";
    _resultLabel.textAlignment = NSTextAlignmentRight;
    [_resultLabel setFont:[UIFont fontWithName:@"Arial" size:20]];
    [self.view addSubview:_resultLabel];
    
    // 2_生成普通按钮、退格、AC键
    // 退格、AC键
    NSMutableArray *topButtonTitles = [[NSMutableArray alloc] initWithCapacity:1];
    [topButtonTitles addObject:@[@"AC", @"<-"]];
    for (int i = 0; i < topButtonTitles.count; i++) {
        for (int j = 0; j < [topButtonTitles[i] count]; j++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setFrame:CGRectMake(35 + (55 + 170) * j, 40 + (45 + 0) * i, 55, 45)];
            [button setTitle:topButtonTitles[i][j] forState:UIControlStateNormal];
            if ([topButtonTitles[i][j] isEqualToString:@"AC"]) {
                [button addTarget:self action:@selector(acBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                [button addTarget:self action:@selector(backSpaceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            [self.view addSubview:button];
        }
    }
    
    // 其它按键
    NSMutableArray *buttonTitles = [[NSMutableArray alloc] initWithCapacity:6];
    [buttonTitles addObject:@[@"7", @"8", @"9", @"*"]];
    [buttonTitles addObject:@[@"4", @"5", @"6", @"/"]];
    [buttonTitles addObject:@[@"1", @"2", @"3", @"+"]];
    [buttonTitles addObject:@[@".", @"0", INVALID_CHAR, @"-"]];
    [buttonTitles addObject:@[@"pai", @"e", INVALID_CHAR, @"+/-"]];
    [buttonTitles addObject:@[@"sin", @"cos", @"sqrt", @"Lg"]];
    
    for (int i = 0; i < buttonTitles.count; i++) {
        for (int j = 0; j < [buttonTitles[i] count]; j++) {
            if (![buttonTitles[i][j] isEqualToString:INVALID_CHAR]) {
                // button的生命周期就在for里, 每次都消失后重建
                UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
                [button setFrame:CGRectMake(START_X_POS + (BUTTON_NORMAL_WIDTH + OFFSET_X) * j,
                                            START_Y_POS + (BUTTON_NORMAL_HEIGHT + OFFSET_Y) * i,
                                            BUTTON_NORMAL_WIDTH, BUTTON_NORMAL_HEIGHT)];
                [button setTitle:buttonTitles[i][j] forState:UIControlStateNormal];
                if ([self isDigit:buttonTitles[i][j]] || [buttonTitles[i][j] isEqualToString:@"pai"] || [buttonTitles[i][j] isEqualToString:@"e"] || [buttonTitles[i][j] isEqualToString:@"."] || [buttonTitles[i][j] isEqualToString:@"+/-"]){ // buttonTitles 不是Button
                    // 数字按钮
                    [button addTarget:self action:@selector(digitBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                }
                else{
                    // 非数字按钮
                    [button addTarget:self action:@selector(operatorBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                }
                [self.view addSubview:button];
            }
        }
    }
    // 3_生成enter键
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(START_X_POS + (BUTTON_NORMAL_WIDTH + OFFSET_X) * 2,
                                START_Y_POS + (BUTTON_NORMAL_HEIGHT + OFFSET_Y) * 3,
                                BUTTON_NORMAL_WIDTH, BUTTON_NORMAL_HEIGHT * 2)];
    [button setTitle:@"Enter" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(operatorBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // 4_实例化model
    self.brain = [[CalculatorModel alloc] init];
    
    // 5_初始化输入状态
    _bIsEntering = NO;
}

// 判断是不是数字
- (BOOL)isDigit:(NSString*)title {
    char c = [title characterAtIndex:0];
    return (c >= '0' && c <= '9');
}

// 数字按钮处理事件
// 几种异常情况:1.不能输入01这类 2.不能输入多个小数点
- (void)digitBtnClick:(UIButton*)sender {
    if([[sender currentTitle] isEqualToString:@"pai"]) {
        _resultLabel.text = [NSString stringWithFormat:@"%g", M_PI];
        return;
    }
    
    else if([[sender currentTitle] isEqualToString:@"e"]) {
        _resultLabel.text = [NSString stringWithFormat:@"%g", M_E];
        return;
    }
    
    else if([[sender currentTitle] isEqualToString:@"+/-"]) {
        double digit = [_resultLabel.text doubleValue];
        if ([_resultLabel.text isEqualToString:@"0"]) {
            return;
        }
        else{
            _resultLabel.text = [NSString stringWithFormat:@"%g", -1 * digit];
            return;
        }
    }
    
    if (_bIsEntering) {
        // 处理首字符为0,但是连续输入0的异常
        // 这句可以不用
        if (_resultLabel.text.length == 1){
            if([_resultLabel.text containsString:@"0"]){
                // 如果首字符为0, 只能输入点
                // 这句永远进不去, 因为不让输入0
                if (![[sender currentTitle] isEqualToString:@"."]){
                    return;
                }
            }
        }
        
        // 处理
//        if ([[sender currentTitle] isEqualToString:@"0"] &&
//            ![_resultLabel.text containsString:@"."]) {
//            return;
//        }
        
        // 处理一个数字有超过1个小数点的异常
        if ([[sender currentTitle] isEqualToString:@"."]
            && [_resultLabel.text containsString:@"."]){
            return;
        }
    
        // 一切正常 就追加字符
        _resultLabel.text = [_resultLabel.text stringByAppendingString:[sender currentTitle]];
    }
    else{
        // 刚开始不让输入0, 就不会出现00、01的情况
//        if([[sender currentTitle] isEqualToString:@"0"] ){
//            return;
//        }
        // 第一个字符是点, 就直接加0.
        if ([[sender currentTitle] isEqualToString:@"."]){
            _resultLabel.text = @"0.";
        }
        else{
            _resultLabel.text = [sender currentTitle];
        }
        _bIsEntering = YES;
    }
    NSLog(@"%@", [sender currentTitle]);
    
    // 把当前输入的显示出来
    _displayLabel.text = [_displayLabel.text stringByAppendingString:[sender currentTitle]];
}

// 操作符按钮处理事件
- (void)operatorBtnClick:(UIButton*)sender{
    double result = 0.0;
    NSLog(@"%@", [sender currentTitle]);
    if ([[sender currentTitle] isEqualToString:@"Enter"]) {
        // Enter点击处理
        [self.brain pushOperand:[_resultLabel.text doubleValue]];
        [self.brain pushOperator:@"=" withResult:&result]; // 把=号推进去, 让栈结果计算
        double result = [self.brain compute]; // 获得计算结果
        if(self.brain.errorCode == noError){
            _resultLabel.text = [NSString stringWithFormat:@"%g", result]; // 显示到结果
        }
        else{
            NSString *errorString = [Error getErrorStringByCode:self.brain.errorCode];
            _resultLabel.text = [NSString stringWithFormat:@"%@", errorString];
        }
        [self.brain popOperator];
        [self.brain popOperand];
        
        // 把当前输入的显示出来
        _displayLabel.text = [_displayLabel.text stringByAppendingString:@"="];
    }
    else{
        // 其它操作符
        [self.brain pushOperand:[_resultLabel.text doubleValue]];
        
        // 由于ObjC不能有多返回值, 就传地址的参数
        if ([self.brain pushOperator:[sender currentTitle] withResult:&result]) {
            _resultLabel.text = [NSString stringWithFormat:@"%g",result];
        }
        
        // 把当前输入的显示出来
        _displayLabel.text = [_displayLabel.text stringByAppendingString:[sender currentTitle]];
    }
    
    _bIsEntering = NO;
}


// 清空计算的一切结果
- (void)acBtnClick:(UIButton*)sender{
    _resultLabel.text = @"0";
    _displayLabel.text = @"";
    [self.brain clean];
    _bIsEntering = NO;
}

// 退格
- (void)backSpaceBtnClick:(UIButton*)sender{
    _resultLabel.text = [_resultLabel.text substringToIndex:_resultLabel.text.length - 1];
    if (_resultLabel.text.length == 0) {
        _resultLabel.text = @"0";
        _bIsEntering = NO;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
