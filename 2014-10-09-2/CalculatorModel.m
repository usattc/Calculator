//
//  CalculatorModel.m
//  2014-10-09-2
//
//  Created by TTC on 10/10/14.
//  Copyright (c) 2014 TTC. All rights reserved.
//

#import "CalculatorModel.h"
// 采用栈数据结构进行计算器的计算
@interface CalculatorModel ()
{
    double _result; // 计算结果
}
@property(strong, nonatomic) NSMutableArray *operandStack; // 计算栈
@property(strong, nonatomic) NSMutableArray *operatorStack;// 计算符栈
- (double)computeStack;
@end

@implementation CalculatorModel
// 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.operandStack = [[NSMutableArray alloc] initWithCapacity:8]; //stack是属性
        self.operatorStack = [[NSMutableArray alloc] initWithCapacity:10];
        self.operatorDict = @{@"=":@"0", @"+":@"1", @"-":@"1", @"*":@"2", @"/":@"2"};
    }
    return self;
}

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        
//    }
//    return self;
//}

// 还可以用这种方法初始化, 自定义getter方法
//- (NSMutableArray*)stack{
//    if (!_stack) {
//        // 首次调用stack为空的时候, 创建之
//        _stack = [[NSMutableArray alloc] initWithCapacity:8];
//    }
//    return _stack;
//}

// 把操作数推入它自己的栈
- (void)pushOperand:(double)operand{
    [self.operandStack addObject:@(operand)]; // 基本数据类型转成NSNumber(数值对象)
}

// 把操作符推入它自己的栈
- (BOOL)pushOperator:(NSString*)operator withResult:(double*)result{
    NSLog(@"操作符推进来");
    // 栈为空直接推入
    if ([self.operatorStack count] == 0) {
        [self.operatorStack addObject:operator];
        return NO;
    }
    else{
//        if ([[self.operatorDict objectForKey:operator] intValue] == 0) {
//            [self computeStack];
//            return YES;
//        }
        
        // 不为空要先判断优先级
        if (/*[self compareOperatorPriority:operator withOther:[self.operatorStack lastObject]] == kSame ||*/ [self compareOperatorPriority:operator withOther:[self.operatorStack lastObject]] == kHigher) {
            [self.operatorStack addObject:operator];
            return NO;
        }
        else{
            // 引发弹栈操作
            for (; [self compareOperatorPriority:operator withOther:[self.operatorStack lastObject]] != kHigher && [self.operatorStack count] != 0; ) {
                [self computeStack];
                NSLog(@"for循环");
            }
            [self.operatorStack addObject:operator];
            *result = _result;
            return YES;
        }
    }
}

// 把操作数弹出计算栈 即弹出最后一个
- (double)popOperand{
    id operandObj = [self.operandStack lastObject]; // 先存最后一个对象 id改成NSNumber*也行
    double operand = [operandObj doubleValue]; // 取出最后一个元素(栈顶元素), 并转换为doubel
    [self.operandStack removeLastObject];
//    [self.operandStack removeObjectsInRange:NSMakeRange([self.operandStack count] - 1, 1)]; // 删除栈顶元素, 为了避免缓存机制带来同时删2个同样元素的问题, 不用removeObject方法. removeObjectsInRange:参数要结构体, 放一个结构体进去就行, NSMakeRange是系统的
    return operand;
}

// 把操作符弹出计算栈 即弹出最后一个
- (NSString*)popOperator{
    id operatorObj = [self.operatorStack lastObject];
    NSString *operator = operatorObj;
//    [self.operatorStack removeObject:operatorObj];
    [self.operatorStack removeLastObject];
//    [self.operatorStack removeObjectsInRange:NSMakeRange([self.operatorStack count] - 1, 1)];
    return operator;
}

// 根据操作符进行计算
- (double)computeStack{
    NSLog(@"compute进来");
    
    // 获得两个操作数
    double operandB = [self popOperand];
    double operandA = [self popOperand];
    
    NSString *operator = [self popOperator];
    
    // 判断operator类型进行相应的计算
//    double result;
    if([operator isEqualToString:@"+"]){
        _result = operandA + operandB;
    }
    else if([operator isEqualToString:@"-"]){
        _result = operandA - operandB;
    }
    else if([operator isEqualToString:@"*"]){
        _result = operandA * operandB;
    }
    else if([operator isEqualToString:@"/"]){
        if (operandB != 0) {
            _result = operandA / operandB;
        }
        else{
            NSLog(@"错误: 除数不能为0!");
            self.errorCode = dividedByZero;
            return 0;
        }
    }
    else if([operator isEqualToString:@"sin"]){
        _result = sin(operandA * M_PI / 180);
    }
    else if([operator isEqualToString:@"cos"]){
        _result = cos(operandA * M_PI / 180);
    }
    else if([operator isEqualToString:@"tan"]){
        _result = tan(operandA * M_PI / 180);
    }
    else if([operator isEqualToString:@"sqrt"]){
        _result = sqrt(operandA);
    }
    else if([operator isEqualToString:@"Lg"]){
        _result = log10(operandA);
    }
    self.errorCode = noError;
    
    // 把结果的数字再放回栈
    [self.operandStack addObject:@(_result)];
    return _result;
}

// 判断运算符的优先级
- (Priority)compareOperatorPriority:(NSString*)operatorA withOther:(NSString*)operatorB{
    int operatorNumberA = [[self.operatorDict objectForKey:operatorA] intValue];
    int operatorNumberB = [[self.operatorDict objectForKey:operatorB] intValue];
    
    if (operatorNumberA == operatorNumberB) {
        return kSame;
    }
    else if (operatorNumberA > operatorNumberB){
        return kHigher;
    }
    else if (operatorNumberA < operatorNumberB){
        return kLower;
    }
    return kSame;
}

//- (int)operatorNumber:(NSString*)operator{
//    
//    
//    if ([operator isEqualToString:@"+"] || [operator isEqualToString:@"-"]) {
//        return 1;
//    }
//    else if ([operator isEqualToString:@"*"] || [operator isEqualToString:@"/"]){
//        return 2;
//    }
//    return 0;
//}

// 把计算结果返回给ViewController
- (double)compute{
    double result = _result;
    return result;
}

// 清除计算栈
- (void)clean{
    [self.operandStack removeAllObjects];
    [self.operatorStack removeAllObjects];
    
}

@end
