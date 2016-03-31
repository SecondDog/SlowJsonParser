//
//  NSStack.h
//  StackAndJson1
//
//  Created by bliss_ddo on 16/3/30.
//  Copyright © 2016年 bliss_ddo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSStack : NSObject
-(instancetype)init;//初始化 默认名字com.nsstack.default 默认大小100
-(instancetype)initWithName:(NSString*)name WithSize:(NSUInteger)size;
-(BOOL)inStack:(id)obj;//入栈
-(id)outStack:(BOOL*)success;//出栈
-(id)peek:(BOOL*)success;//读取栈顶元素
-(BOOL)isEmpty;//栈是否为空
-(NSInteger)size;//当前栈的大小
-(NSString*)stackName;//栈的名称
@end
