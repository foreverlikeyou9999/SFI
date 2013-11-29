//
//  NSData+AESAdditions.h
//  BLIPiOSSDK
//
//  Created by 박 정섭 on 12. 11. 6..
//
//

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSData (AESAdditions)
- (NSData*)AES128EncryptWithKey:(NSString*)key;
- (NSData*)AES256EncryptWithKey:(NSString*)key;
- (NSData*)AES256DecryptWithKey:(NSString*)key;
#pragma mark - String Conversion
- (NSString *)hexadecimalString;

@end
