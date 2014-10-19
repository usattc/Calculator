//
//  Error.m
//  2014-10-09-2
//
//  Created by TTC on 10/13/14.
//  Copyright (c) 2014 TTC. All rights reserved.
//

#import "Error.h"

@implementation Error
+ (NSString*)getErrorStringByCode:(NSInteger)code
{
    switch (code) {
        case dividedByZero:
            return @"除数不能为0";
            break;
            
        default:
            break;
    }
    return @"";
}
@end
