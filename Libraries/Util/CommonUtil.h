//
//  CommonUtil.h
//  SalesForce
//
//  Created by 여성현 on 13. 8. 30..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <Foundation/Foundation.h>
//
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>
#import <Security/Security.h>
#import <sys/utsname.h>

@interface CommonUtil : NSObject

// 네트워크 상태 체크
+(BOOL)isNetworkReachable;
+(BOOL)isCellNetwork;
+(int)getNetworkState;

//
+ (NSData *)transform:(CCOperation)encryptOrDecrypt data:(NSData *)inputData;
+ (NSData *)md5:(NSString *)stringToHash;
+ (UIImage *)resizedImage:(UIImage*)inImage inRect:(CGRect)thumbRect;
+ (UIImage *)cropedImage:(UIImage*)inImage  inRect:(CGRect)cropRect;
+ (UIImage *)imageWithView:(UIView *)view;

+ (NSString *)makeComma:(NSNumber*)oriNum;
+ (NSString *)dateSecReturn:(NSString *)ex_dt withSelect:(NSString *)value;

//keychain
+ (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier;
+ (NSData *)searchKeychainCopyMatching:(NSString *)identifier;
+ (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;
+ (BOOL)updateKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;
+ (void)deleteKeychainValue:(NSString *)identifier;

+ (NSString *)machineName;

+ (UIImage *)createNormalBtn:(NSString *)btnNm;
+ (UIImage *)createHighlightBtn:(NSString *)btnNm;

+ (int)osVersion;

@end
