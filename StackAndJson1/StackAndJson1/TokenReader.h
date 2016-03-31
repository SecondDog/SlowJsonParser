//
//  TokenReader.h
//  StackAndJson1
//
//  Created by bliss_ddo on 16/3/30.
//  Copyright © 2016年 bliss_ddo. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum:NSInteger{
    TokenTypeEndDocument, //结尾
    TokenTypeBeginDict, //{
    TokenTypeEndDict, //}
    TokenTypeBeginArray,//[
    TokenTypeEndArray,//]
    TokenTypeSEPColon,//:
    TokenTypeSEPComma,//,
    TokenTypeString,//string
    TokenTypeBoolean,//bool
    TokenTypeNumber,//number
    TokenTypeNull,//null
    
    TokenTypeError,
}TokenType;
@interface TokenReader : NSObject
-(TokenType)readNextToken;
-(instancetype)initWithString:(NSString*)jstr;
-(NSString*)readString;
-(NSNumber*)readBoolean;
-(NSNumber*)readNumber;
-(NSNull*)readNull;
@end
