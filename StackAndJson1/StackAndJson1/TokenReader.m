//
//  TokenReader.m
//  StackAndJson1
//
//  Created by bliss_ddo on 16/3/30.
//  Copyright © 2016年 bliss_ddo. All rights reserved.
//

#import "TokenReader.h"

@interface TokenReader()
{
    NSInteger _scanIndex;
    NSString *_jsonString;
    NSString *_readString;
    NSNumber *_readNumber;
    BOOL _readBool;
    NSNull * _readNull;
    
    char * _jsonStringCFArray;
    char * _tmpReadStringCFArray;
    int _tmpReadIndex;
    
}
@end
@implementation TokenReader
static inline bool isWhiteSpace(unichar ch)
{
    return ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r';
}

-(instancetype)initWithString:(NSString*)jstr;
{
    self=[super init];
    if (self) {
        _jsonString=jstr;
        _scanIndex=0;
        _jsonStringCFArray=malloc(sizeof(char)*4096*2);
        memccpy(_jsonStringCFArray, [_jsonString UTF8String], 0, sizeof(char)*4096*2) ;
    
    }
    return self;
}
-(char)_stepRead
{
    return  _jsonStringCFArray[_scanIndex++];
}
-(char)_peedRead
{
    return _jsonStringCFArray[_scanIndex];
}
-(BOOL)_hasMore
{
    return !(_scanIndex>= strlen(_jsonStringCFArray));
}
-(void)_append:(char)ch
{
    _tmpReadStringCFArray[_tmpReadIndex++]=ch;
}
-(TokenType)readNextToken
{

    char oneChar = '?';
    for (; ; ) {
        if (_scanIndex>= strlen(_jsonStringCFArray)) {
            return TokenTypeEndDocument;
        }
        oneChar=[self _peedRead];
        if (!isWhiteSpace(oneChar)) {
            break;
        }
        [self _stepRead];
    }
    switch (oneChar) {
        case '{':
            [self _stepRead];
            return TokenTypeBeginDict;
        case '}':
            [self _stepRead];
            return TokenTypeEndDict;
        case '[':
            [self _stepRead];
            return TokenTypeBeginArray;
        case ']':
            [self _stepRead];
            return TokenTypeEndArray;
        case ':':
            [self _stepRead];
            return TokenTypeSEPColon;
        case ',':
            _scanIndex++;
            return TokenTypeSEPComma;
        case '\"':
            return TokenTypeString;
        case 'n':
            return TokenTypeNull;
            // true / false
        case 't':
        case 'f':
            return TokenTypeBoolean;
        case '-':
            return TokenTypeNumber;
    }
    if (oneChar >= '0' && oneChar <= '9') {
        return TokenTypeNumber;
    }
    return TokenTypeError;
}
-(NSString*)readString
{
    if (_tmpReadStringCFArray==NULL) {
        _tmpReadStringCFArray=malloc(sizeof(char)*1024);
    }
    memset(_tmpReadStringCFArray, 0, sizeof(char)*1024);
    _tmpReadIndex=0;
    char ch = [self _stepRead];

    if (ch!='\"') {
        NSLog(@"error");
    }
    for (; ; ) {
        ch=[self _stepRead];
        if (ch=='\\') {
            char ech = [self _stepRead];
            switch (ech) {
                case '\"':
                    [self _append:ech];
                    break;
                case '\\':
                    [self _append:ech];
                    break;
                case '/':
                    [self _append:'/'];
                    break;
                case 'b':
                    [self _append:'\b'];
                    break;
                case 'f':
                    [self _append:'\f'];
                    break;
                case 'n':
                    [self _append:'\n'];
                    break;
                case 'r':
                    [self _append:'\r'];
                    break;
                case 't':
                    [self _append:'\t'];
                    break;
                case 'u':{
                    int u=0;
                    for (int i=0; i<4; i++) {
                        char uch = [self _stepRead];
                        if (uch>='0'&&uch<='9') {
                            u=(u<<4)+(uch-'0');
                        }else if (uch>='a'&&uch<='f'){
                            u=(u<<4)+(uch-'a')+10;
                        }else if (uch>='A'&&uch<='F'){
                            u=(u<<4)+(uch-'A')+10;
                        }else{
                            NSLog(@"error");
                        }
                    }
                    [self _append:u];
                }
                    break;
                
                default:
                    break;
            }
        }else if(ch=='\"'){
            break;
        }else if (ch=='\r'||ch=='\n'){
        
        }else{
            [self _append:ch];
        }
    }
    _readString = [[NSString alloc]initWithUTF8String:_tmpReadStringCFArray];
    return _readString;
}
-(NSNumber*)readBoolean{
    char ch = [self _stepRead];
    char *s;
    if (ch=='t') {
        s="rue";
    }else if (ch == 'f'){
        NSLog(@"read boolean error");
    }
    for (int i=0; i<strlen(s); i++) {
        char charTobeExp = [self _stepRead];
        if (charTobeExp!=s[i]) {
            NSLog(@"read bool error");
        }
    }
    return @(ch=='t');
}
-(NSNull*)readNull
{
    char* s ;
    s="null";
    for (int i=0; i<strlen(s); i++) {
        char c =[self _stepRead];
        if (c!=s[i]) {
            NSLog(@"read null error");
        }
    }
    return [NSNull null];
}
static const int READ_NUMBER_INT_PART = 0;
static const int READ_NUMBER_FRA_PART = 1;
static const int READ_NUMBER_EXP_PART = 2;
static const int READ_NUMBER_END=3;
-(NSNumber*)readNumber
{
    char * intPartS=malloc(sizeof(char)*20);
    char * fraPartS=malloc(sizeof(char)*20);
    char * expPartS=malloc(sizeof(char)*20);
    int intIndex=0;
    int fraIndex=0;
    int expIndex=0;
    
    BOOL hasFraPart = NO;
    BOOL hasExpPart = NO;
    char ch = [self _peedRead];
    BOOL minusSign = (ch=='-');
    BOOL expMinusSign = NO;
    if (minusSign) {
        [self _stepRead];
    }
    int status = READ_NUMBER_INT_PART;
    for (; ; ) {
        if ([self _hasMore]) {
            ch = [self _peedRead];
        }else{
            status=READ_NUMBER_END;
        }
        switch (status) {
            case READ_NUMBER_INT_PART:
                if (ch >= '0' && ch <= '9') {
                    intPartS[intIndex++]=[self _stepRead];
                }else if (ch == '.'){
                    [self _stepRead];
                    hasFraPart=YES;
                    status=READ_NUMBER_FRA_PART;
                }else if (ch == 'e'||ch =='E'){
                    [self _stepRead];
                    hasExpPart = YES;
                    char signChar = [self _peedRead];
                    if (signChar =='-'||signChar=='+') {
                        expMinusSign = (signChar=='-');
                        [self _stepRead];
                    }
                }else{
                    if (strlen(intPartS)==0) {
                        NSLog(@"error");
                    }
                    status=READ_NUMBER_END;
                }
                continue;
            case READ_NUMBER_FRA_PART:
                if (ch >= '0' && ch<='9') {
                    fraPartS[fraIndex++]=ch;
                }else if(ch == 'e'|| ch == 'E'){
                    [self _stepRead];
                    hasExpPart = YES;
                    char signChar =[self _peedRead];
                    if (signChar == '-'|| signChar =='+') {
                        expMinusSign=(signChar =='-');
                        [self _stepRead];
                    }
                    status = READ_NUMBER_EXP_PART;
                }else{
                    if (strlen(fraPartS)==0) {
                        NSLog(@"error");
                    }
                    status = READ_NUMBER_END;
                }
                    continue;
            case READ_NUMBER_EXP_PART:
                if (ch >= '0' && ch<= '9') {
                    expPartS[expIndex++]=[self _stepRead];
                }else{
                    if (strlen(expPartS)==0) {
                        NSLog(@"error");
                    }
                    status = READ_NUMBER_END;
                }
                continue;
            case READ_NUMBER_END:{
                long lInt =minusSign?(-[self _strongToLong:intPartS]):([self _strongToLong:intPartS]);
                if (!hasFraPart&&!hasExpPart) {
                    return @(lInt);
                }
                double dFraPart = hasExpPart?(minusSign?([self _string2Fraction:fraPartS]):([self _string2Fraction:fraPartS])):0.0f;
                double number = hasExpPart?(lInt+dFraPart)*pow(10, expMinusSign? -([self _strongToLong:expPartS]):([self _strongToLong:expPartS])):(lInt+dFraPart);
                return @(number);
            }

            default:
                break;
        }
    }
    
    
    return @(0);
}
-(long)_strongToLong:(char*)s
{
    long n=0;
    for (int i=0; i<strlen(s); i++) {
        n=n*10+(s[i]-'0');
    }
    return n;
}
-(double)_string2Fraction:(char*)s{
    double d = 0.0;
    for(int i=0;i<strlen(s);i++){
        int n=s[i]-'0';
        d=d+(n==0?0:n/pow(10, i+1));
    }
    return d;
}
@end
