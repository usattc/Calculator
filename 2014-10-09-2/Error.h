//
//  Error.h
//  2014-10-09-2
//
//  Created by TTC on 10/13/14.
//  Copyright (c) 2014 TTC. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
   noError,
   dividedByZero
}ErrorCode;

@interface Error : NSObject
+ (NSString*)getErrorStringByCode:(NSInteger)code;
@end
