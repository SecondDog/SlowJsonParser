//
//  main.m
//  StackAndJson1
//
//  Created by bliss_ddo on 16/3/30.
//  Copyright © 2016年 bliss_ddo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSStack.h"
#import "Tester.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Tester * tester = [[Tester alloc]init];
//        [tester testStack];
//        [tester testPD];
        [tester testTR];
    }
    return 0;
}
