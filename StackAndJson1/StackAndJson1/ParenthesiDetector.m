//
//  ParenthesiDetector.m
//  StackAndJson1
//
//  Created by bliss_ddo on 16/3/30.
//  Copyright © 2016年 bliss_ddo. All rights reserved.
//

#import "ParenthesiDetector.h"
#import "NSStack.h"
@interface ParenthesiDetector()
{
    NSStack * _stack;
}
@end
@implementation ParenthesiDetector
-(instancetype)init
{
    self=[super init];
    if (self) {
        _stack = [[NSStack alloc]initWithName:@"detectorStack" WithSize:INTMAX_MAX];
    }
    return self;
}
-(BOOL)_isLeftPart:(NSString*)chr
{
    NSSet * leftSet = [NSSet setWithObjects:@"[",@"{",@"(",nil];
    return [leftSet containsObject:chr];
}
-(BOOL)_isRightPart:(NSString*)chr
{
    NSSet * leftSet = [NSSet setWithObjects:@"]",@"}",@")",nil];
    return [leftSet containsObject:chr];
}
-(BOOL)_isPatterness:(NSString*)left with:(NSString*)right
{
    if ([left isEqualToString:@"["])return [right isEqualToString:@"]"];
    if ([left isEqualToString:@"{"])return [right isEqualToString:@"}"];
    if ([left isEqualToString:@"("])return [right isEqualToString:@")"];
    return NO;
}
-(BOOL)isValidate:(NSString*)string
{
    if (string==nil)return NO;
    BOOL result = YES;
    NSString * left  = nil;
    NSString * right = nil;
    for (NSInteger i=0; i<string.length; i++) {
        NSString * oneChr = [string substringWithRange:NSMakeRange(i, 1)];
        
        if ([self _isLeftPart:oneChr]) {
            [_stack inStack:oneChr];
        }else if([self _isRightPart:oneChr]){
            BOOL outstackSuccess ;
            right=oneChr;
            left=[_stack outStack:&outstackSuccess];
            if (![self _isPatterness:left with:right]) {
                result=NO;
                break;
            }
        }
    }
    return result;
}
@end
