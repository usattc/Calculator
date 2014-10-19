//
//  CalculatorModel.h
//  2014-10-09-2
//
//  Created by TTC on 10/10/14.
//  Copyright (c) 2014 TTC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Error.h"

// 运算符的优先级
typedef enum {
    kLower,
    kSame,
    kHigher
}Priority;

@interface CalculatorModel : NSObject
@property(assign, nonatomic) ErrorCode errorCode;
@property(strong, nonatomic) NSDictionary *operatorDict; // 对象都不用assign, 对象都用strong(才用能ARC)
- (void)pushOperand:(double)operand;
- (BOOL)pushOperator:(NSString*)operator withResult:(double*)result;
- (double)popOperand;
- (NSString*)popOperator;
- (void)clean;
- (Priority)compareOperatorPriority:(NSString*)operatorA withOther:(NSString*)operatorB;
//- (int)operatorNumber:(NSString*)operator;
- (double)compute;
@end
