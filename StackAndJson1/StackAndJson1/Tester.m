//
//  Tester.m
//  StackAndJson1
//
//  Created by bliss_ddo on 16/3/30.
//  Copyright © 2016年 bliss_ddo. All rights reserved.
//

#import "Tester.h"
#import "NSStack.h"
#import "ParenthesiDetector.h"
#import "TokenReader.h"
#import "JSONParser.h"
@implementation Tester


-(void)testTR
{
    
    NSAssert(YES, @"先去Tester里把JSON文件的路径给改了。");

    NSString * path = @"/Users/bliss_ddo/Desktop/StackAndJson1/StackAndJson1/test.json";
    
    NSString * stringToBeScaned = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    JSONParser * jp = [[JSONParser alloc]init];
    NSObject * obj=[jp parse:stringToBeScaned];
    NSLog(@"!!!!!=========>>>%@<<<",obj);
    
    //    NSLog(@"%@",stringToBeScaned);
//    TokenReader * tr = [[TokenReader alloc]initWithString:stringToBeScaned];
//    while (YES) {
//         TokenType t= [tr readNextToken];
////        NSLog(@"%ld",t);
//        if (TokenTypeString==t) {
//            NSString * ttt= tr.readString;
//            NSLog(@"%@",ttt);
//        }
//        if (TokenTypeBoolean==t) {
//            NSNumber * ttt= tr.readBoolean;
//            NSLog(@"😃😃😃😃😃😃😃%@",ttt);
//        }
//        if (TokenTypeNull==t) {
//            NSLog(@"hit null%@",tr.readNull);
//        }
//        if (TokenTypeNumber==t) {
//            NSLog(@"%@",tr.readNumber);
//        }
//        
//        if (TokenTypeEndDocument==t) {
//            break;
//        }
//        
//    }
}

-(void)testPD
{
    ParenthesiDetector * pd = [[ParenthesiDetector alloc]init];
    NSString * case1 =nil;//invalidate input should no
    NSString * case2 =@"";//empty pd should yes
    NSString * case3 =@"{}()[]";//normal case1 should yes
    NSString * case4 =@"{[()]}";//normal case2 should yes
    NSString * case5 =@"{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}";//normal long case should yes
    NSString * case6 =@"{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{)";//all left but one right
    NSString * case7 =@"}";//start with right
    
    BOOL result1 = [pd isValidate:case1];
    BOOL result2 = [pd isValidate:case2];
    BOOL result3 = [pd isValidate:case3];
    BOOL result4 = [pd isValidate:case4];
    BOOL result5 = [pd isValidate:case5];
    BOOL result6 = [pd isValidate:case6];
    BOOL result7 = [pd isValidate:case7];

    NSAssert(result1==NO, @"1 if not no you are wrong");
    NSAssert(result2==YES, @"2 if not yes you are wrong");
    NSAssert(result3==YES, @"3 if not yes you are wrong");
    NSAssert(result4==YES, @"4 if not yes you are wrong");
    NSAssert(result5==YES, @"5 if not yes you are wrong");
    NSAssert(result6==NO , @"6 if not no are wrong");
    NSAssert(result7==NO , @"7 if not no are wrong");
    
}
-(void)testStack
{

#define PRE_DEFINE_STACK_SIZE 100 //stack size
    
    //init the stack
    NSStack * stackToBeTest = [[NSStack alloc]initWithName:@"testStack" WithSize:PRE_DEFINE_STACK_SIZE];
    
    //init obj of different types
    NSString     * testStringObject     = @"testString";
    NSNumber     * testNumberObject     = @(12306);
    NSData       * testDataObject       = [NSData dataWithBytes:"data" length:4];
    NSDate       * testDateObject       = [NSDate date];
    NSArray      * testArrayObject      = @[@"index1",@"index2",@"index3"];
    NSDictionary * testDictionaryObject = @{@"key1":@"value1",@"key2":@"value2"};
    NSArray      * vector               = @[testStringObject,
                                            testNumberObject,
                                            testDataObject,
                                            testDateObject,
                                            testArrayObject,
                                            testDictionaryObject];
    
    //test instack an outstack logic
    for (NSInteger i=0; i<100; i++) {
        if ([stackToBeTest inStack:@(i)]) {
            NSLog(@"instack success %@",@(i));
        }
    }
    for (NSInteger i=0; i<100; i++) {
        BOOL outstackSuccess;
        id obj = [stackToBeTest outStack:&outstackSuccess];
        if (outstackSuccess) {
            NSLog(@"out stack success %@",obj);
        }
    }
    //test make a full stack with different type of object
    for (NSInteger i=0; i<PRE_DEFINE_STACK_SIZE; i++) {
        NSObject * randomOBJ = [vector objectAtIndex:(arc4random()%vector.count)];
        BOOL inStackSuccess =[stackToBeTest inStack:[randomOBJ copy]];
        NSString * status = inStackSuccess?@"success":@"fail";
        NSLog(@"inStack:%@,object:【%@】%@",status,NSStringFromClass([randomOBJ class]),randomOBJ);
    }
    //test in stack when stack is full
    for (NSInteger i=0; i<100; i++) {
        NSObject * randomOBJ = [vector objectAtIndex:(arc4random()%vector.count)];
        BOOL inStackSuccess =[stackToBeTest inStack:[randomOBJ copy]];
        NSString * status = inStackSuccess?@"success":@"fail";
        NSLog(@"inStack:%@,object:【%@】%@",status,NSStringFromClass([randomOBJ class]),randomOBJ);
    }
}
@end
