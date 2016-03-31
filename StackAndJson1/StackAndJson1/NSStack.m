//
//  NSStack.m
//  StackAndJson1
//
//  Created by bliss_ddo on 16/3/30.
//  Copyright © 2016年 bliss_ddo. All rights reserved.
//

#import "NSStack.h"
@interface NSStack()
{
    NSInteger _maxSize;
    NSString * _stackName;
    NSMutableArray * _internalArray;
}
@end
@implementation NSStack
-(instancetype)init
{
    return [self initWithName:@"com.nsstack.default" WithSize:100];
}
-(instancetype)initWithName:(NSString*)name WithSize:(NSUInteger)psize;
{
    self=[super init];
    if (self) {
        _stackName=name;
        _maxSize=psize;
        _internalArray = [[NSMutableArray alloc]init];
    }
    return self;
}
-(BOOL)inStack:(id)obj
{
    if (obj==nil||_internalArray.count+1>_maxSize) {
        if (obj==nil) {
        }
        if (_internalArray.count+1>_maxSize) {
        }
        return NO;
    }
    [_internalArray addObject:obj];
    return YES;
}
-(id)outStack:(BOOL*)success
{
    if ([self isEmpty]) {
        *success=NO;
        return nil;
    }
    *success = YES;
    NSObject * obj = [_internalArray lastObject];
    [_internalArray removeObjectAtIndex:_internalArray.count-1];
    return obj;
}
-(id)peek:(BOOL*)success
{
    if ([self isEmpty]) {
        *success=NO;
        return nil;
    }
    NSObject * obj = [_internalArray lastObject];
    return obj;
}
-(BOOL)isEmpty
{
    return _internalArray.count==0;
}
-(NSInteger)size
{
    return _internalArray.count;
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"当前栈名称:%@,大小%ld,最大容量%ld",_stackName,_internalArray.count,_maxSize];
}
-(NSString *)stackName
{
    return _stackName;
}
@end
