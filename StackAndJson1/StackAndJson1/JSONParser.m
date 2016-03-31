//
//  JSONParser.m
//  StackAndJson1
//
//  Created by bliss_ddo on 16/3/31.
//  Copyright © 2016年 bliss_ddo. All rights reserved.
//

#import "JSONParser.h"
#import "NSStack.h"
#import "TokenReader.h"
typedef enum:NSInteger {
    STATUS_EXPECT_BEGIN_DICTIONARY=1<<0,
    STATUS_EXPECT_END_DICTIONARY=1<<1,
    STATUS_EXPECT_BEGIN_ARRAY=1<<2,
    STATUS_EXPECT_END_ARRAY=1<<3,
    STATUS_EXPECT_SINGLE_VALUE=1<<4,
    STATUS_EXPECT_ARRAY_VALUE=1<<5,
    STATUS_EXPECT_DICTIONARY_KEY=1<<6,
    STATUS_EXPECT_DICTIONARY_VALUE=1<<7,
    STATUS_EXPECT_COLON=1<<8,
    STATUS_EXPECT_COMMA=1<<9,
    STATUS_EXPECT_END_DOCUMENT=1<<10,
}STATUS_EXPECT_;
@interface JSONParser()
{
    STATUS_EXPECT_ _status;
}
@end
@implementation JSONParser

-(BOOL)_hasStatus:(STATUS_EXPECT_)status
{
    return (_status&status)!=0;
}

-(id)parse:(NSString*)str
{
    NSStack * stack=[[NSStack alloc]initWithName:@"jsonStack" WithSize:1024*4];
    TokenReader * reader = [[TokenReader alloc]initWithString:str];
    _status =STATUS_EXPECT_SINGLE_VALUE|STATUS_EXPECT_BEGIN_DICTIONARY|STATUS_EXPECT_BEGIN_ARRAY;
    for (; ; ) {
        TokenType currentToken =reader.readNextToken;
        switch (currentToken) {
            case TokenTypeBoolean:
                if ([self _hasStatus:STATUS_EXPECT_SINGLE_VALUE]) {
                    NSNumber * boolNumber =reader.readBoolean;
                    [stack inStack:boolNumber];
                    _status = STATUS_EXPECT_END_DOCUMENT;
                    continue;
                }
                if ([self _hasStatus:STATUS_EXPECT_DICTIONARY_VALUE]) {
                    NSNumber * boolNumber = reader.readBoolean;
                    BOOL outstackFlag ;
                    NSString * key = [stack outStack:&outstackFlag];
                    NSMutableDictionary * dictInStack = [stack peek:&outstackFlag];
                    [dictInStack setObject:boolNumber forKey:key];
                    _status = STATUS_EXPECT_COMMA|STATUS_EXPECT_END_DICTIONARY;
                    continue;
                }
                if ([self _hasStatus:STATUS_EXPECT_ARRAY_VALUE]) {
                    NSNumber * boolNumber = reader.readBoolean;
                    BOOL outstackFlag ;
                    NSMutableArray * marrInStack = [stack peek:&outstackFlag];
                    [marrInStack addObject:boolNumber];
                    _status = STATUS_EXPECT_COMMA | STATUS_EXPECT_END_ARRAY;
                    continue;
                }
                
            case TokenTypeNull:
                if ([self _hasStatus:STATUS_EXPECT_SINGLE_VALUE]) {
                    NSNull * nulll= reader.readNull;
                    [stack inStack:nulll];
                    _status = STATUS_EXPECT_END_DOCUMENT;
                    continue;
                }

                if ([self _hasStatus:STATUS_EXPECT_DICTIONARY_VALUE]) {
                    NSNull * nulll= reader.readNull;
                    BOOL outstackFlag ;
                    NSString * key = [stack outStack:&outstackFlag];
                    NSMutableDictionary * dictInStack = [stack peek:&outstackFlag];
                    [dictInStack setObject:nulll forKey:key];
                    _status = STATUS_EXPECT_COMMA|STATUS_EXPECT_END_DICTIONARY;
                    continue;
                }
                if ([self _hasStatus:STATUS_EXPECT_ARRAY_VALUE]) {
                    NSNull * nulll= reader.readNull;
                    BOOL outstackFlag ;
                    NSMutableArray * marrInStack = [stack peek:&outstackFlag];
                    [marrInStack addObject:nulll];
                    _status = STATUS_EXPECT_COMMA | STATUS_EXPECT_END_ARRAY;
                    continue;
                }
            case TokenTypeNumber:
                if ([self _hasStatus:STATUS_EXPECT_SINGLE_VALUE]) {
                    NSNumber * num =reader.readNumber;
                    [stack inStack:num];
                    _status = STATUS_EXPECT_END_DOCUMENT;
                    continue;
                }
                if ([self _hasStatus:STATUS_EXPECT_DICTIONARY_KEY]) {
                    NSNumber * num = reader.readNumber;
                    [stack inStack:num];
                    _status=STATUS_EXPECT_COLON;
                    continue;
                }
                if ([self _hasStatus:STATUS_EXPECT_DICTIONARY_VALUE]) {
                    NSNumber * num = reader.readNumber;
                    BOOL outstackFlag ;
                    NSString * key = [stack outStack:&outstackFlag];
                    NSMutableDictionary * dictInStack = [stack peek:&outstackFlag];
                    [dictInStack setObject:num forKey:key];
                    _status = STATUS_EXPECT_COMMA|STATUS_EXPECT_END_DICTIONARY;
                    continue;
                }
                if ([self _hasStatus:STATUS_EXPECT_ARRAY_VALUE]) {
                    NSNumber * num = reader.readNumber;
                    BOOL outstackFlag ;
                    NSMutableArray * marrInStack = [stack peek:&outstackFlag];
                    [marrInStack addObject:num];
                    _status = STATUS_EXPECT_COMMA | STATUS_EXPECT_END_ARRAY;
                    continue;
                }
            case TokenTypeString:
                if ([self _hasStatus:STATUS_EXPECT_SINGLE_VALUE]) {
                    NSString * str =reader.readString;
                    [stack inStack:str];
                    _status = STATUS_EXPECT_END_DOCUMENT;
                    continue;
                }
                if ([self _hasStatus:STATUS_EXPECT_DICTIONARY_KEY]) {
                    NSString * str = reader.readString;
                    [stack inStack:str];
                    _status=STATUS_EXPECT_COLON;
                    continue;
                }
                if ([self _hasStatus:STATUS_EXPECT_DICTIONARY_VALUE]) {
                    NSString * str =reader.readString;
                    BOOL outstackFlag ;
                    NSString * key = [stack outStack:&outstackFlag];
                    NSMutableDictionary * dictInStack = [stack peek:&outstackFlag];
                    [dictInStack setObject:str forKey:key];
                    _status = STATUS_EXPECT_COMMA|STATUS_EXPECT_END_DICTIONARY;
                    continue;
                }
                if ([self _hasStatus:STATUS_EXPECT_ARRAY_VALUE]) {
                    NSString * str =reader.readString;
                    BOOL outstackFlag ;
                    NSMutableArray * marrInStack = [stack peek:&outstackFlag];
                    [marrInStack addObject:str];
                    _status = STATUS_EXPECT_COMMA | STATUS_EXPECT_END_ARRAY;
                    continue;
                }
            case TokenTypeSEPColon:
                if (_status == STATUS_EXPECT_COLON) {
                    _status=STATUS_EXPECT_DICTIONARY_VALUE|STATUS_EXPECT_BEGIN_DICTIONARY|STATUS_EXPECT_BEGIN_ARRAY;
                    continue;
                }
            case TokenTypeSEPComma:
                if ([self _hasStatus:STATUS_EXPECT_COMMA]) {
                    if ([self _hasStatus:STATUS_EXPECT_END_DICTIONARY]) {
                        _status = STATUS_EXPECT_DICTIONARY_KEY;
                        continue;
                    }
                    if ([self _hasStatus:STATUS_EXPECT_END_ARRAY]) {
                        _status = STATUS_EXPECT_ARRAY_VALUE|STATUS_EXPECT_BEGIN_ARRAY|STATUS_EXPECT_BEGIN_DICTIONARY;
                        continue;
                    }
                }
  
            case TokenTypeEndArray:
                if ([self _hasStatus:STATUS_EXPECT_END_ARRAY]) {
                    BOOL flag;
                    NSMutableArray * array = [stack outStack:&flag];
                    if (stack.isEmpty) {
                        [stack inStack:array];
                        _status = STATUS_EXPECT_END_DOCUMENT;
                        continue;
                    }
                    NSObject * topObj =[stack peek:&flag];
                    if ([topObj isKindOfClass:[NSString class]]) {
                        NSString * key = [stack outStack:&flag];
                        NSMutableDictionary * dict = [stack peek:&flag];
                        [dict setObject:array forKey:key];
                        _status = STATUS_EXPECT_COMMA | STATUS_EXPECT_END_DICTIONARY;
                        continue;
                    }
                    if ([topObj isKindOfClass:[NSMutableArray class]]) {
                        NSMutableArray * arr_container = [stack peek:&flag];
                        [arr_container addObject:array];
                        _status = STATUS_EXPECT_COMMA |STATUS_EXPECT_END_ARRAY;
                        continue;
                    }
                }
            case TokenTypeEndDict:
                if ([self _hasStatus:STATUS_EXPECT_END_DICTIONARY]) {
                    BOOL flag;
                    NSMutableDictionary * object = [stack outStack:&flag];
                    if (stack.isEmpty) {
                        [stack inStack:object];
                        _status = STATUS_EXPECT_END_DOCUMENT;
                        continue;
                    }
                    NSObject * topObj =[stack peek:&flag];
                    if ([topObj isKindOfClass:[NSString class]]) {
                        NSString * key = [stack outStack:&flag];
                        NSMutableDictionary * dict1 = [stack peek:&flag];
                        [dict1 setObject:object forKey:key];
                        _status = STATUS_EXPECT_COMMA | STATUS_EXPECT_END_DICTIONARY;
                        continue;
                    }
                    if ([topObj isKindOfClass:[NSMutableArray class]]) {
                        NSMutableArray * arr = [stack peek:&flag];
                        [arr addObject:object];
                        _status = STATUS_EXPECT_COMMA |STATUS_EXPECT_END_ARRAY;
                        continue;
                    }
                }
            case TokenTypeEndDocument:
                if ([self _hasStatus:STATUS_EXPECT_END_DOCUMENT]) {
                    BOOL flag;
                    NSObject * obj =[stack outStack:&flag];
                    if (stack.isEmpty) {
                        return obj;
                    }
                }
                
            case TokenTypeBeginArray:
                if ([self _hasStatus:STATUS_EXPECT_BEGIN_ARRAY]) {
                    NSMutableArray * arr = [NSMutableArray array];
                    [stack inStack:arr];
                    _status = STATUS_EXPECT_ARRAY_VALUE|STATUS_EXPECT_BEGIN_DICTIONARY|STATUS_EXPECT_BEGIN_ARRAY|STATUS_EXPECT_END_ARRAY;
                    continue;
                }
            case TokenTypeBeginDict:
                if ([self _hasStatus:STATUS_EXPECT_BEGIN_DICTIONARY]) {
                    NSMutableDictionary * d = [NSMutableDictionary dictionary];
                    [stack inStack:d];
                    _status = STATUS_EXPECT_DICTIONARY_KEY|STATUS_EXPECT_BEGIN_DICTIONARY|STATUS_EXPECT_END_DICTIONARY;
                    continue;
                }
            default:
                break;
        }
    }
    
    return nil;
}
@end
