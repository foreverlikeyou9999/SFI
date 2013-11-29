/*
 [Base64 initialize];
 NSString * _key = @"1234567890123456"; //128bit
 CCOptions padding = kCCOptionPKCS7Padding;
 AESCrypt *crypto = [[[AESCrypt alloc] init] autorelease];
 //---------------------------------------------------------------------------------------------encryption Sample
 
  	NSString * _secret = @"blah..blah..blah.....";
 // 
  	NSData *encryptedData = [crypto encrypt:[_secret dataUsingEncoding:NSUTF8StringEncoding] key:[_key dataUsingEncoding:NSUTF8StringEncoding] padding:&padding];
   // 복호화  후 base64 인코딩
 	NSLog(@"encrypted data string for export: %@",[Base64 encode:encryptedData]);
 //----------------------------------------------------------------------------------------------decryption Sample
 padding = kCCOptionECBMode|kCCOptionPKCS7Padding;
 NSString * _deSecret= @"dXzNDNxckOrb7uz2ON0AAMa/oq6BhXPyhbLV8HHxnGedqUJOzxLpXuUILe6gX3JMNpdZIRegXrvMHnzDDzYwGBXRVuJlHJuDFVFGRV5aTDl1fM0M3FyQ6tvu7PY43QAAxr+iroGFc/KFstXwcfGcZ52pQk7PEule5Qgt7qBfckw2l1khF6Beu8wefMMPNjAYFdFW4mUcm4MVUUZFXlpMOXV8zQzcXJDq2+7s9jjdAADGv6KugYVz8oWy1fBx8ZxnvZMlpmNPd6ARV3a/AiYepg==";
 // Base64 lib 사용, 네트웍간 전송 후 디코딩 - > 복호화
 NSData *data = [crypto decrypt:[Base64 decode:_deSecret] key:[_key dataUsingEncoding:NSUTF8StringEncoding] padding:&padding];
 
 NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
 NSLog(@"decrypted string-------------------: %@", str);
*/

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#define _key    @"438owjkQWvu!@^%&"
#define kChosenCipherBlockSize	kCCBlockSizeAES128
#define kChosenCipherKeySize	kCCKeySizeAES128
#define kChosenDigestLength		CC_SHA256_DIGEST_LENGTH

@interface AESCrypt : NSObject

+ (NSString *) EncryptString:(NSString *)plainSourceStringToEncrypt;
+ (NSString *) DecryptString:(NSString *) base64StringToDecrypt;


- (NSData *)encrypt:(NSData *)plainText key:(NSData *)aSymmetricKey padding:(CCOptions *)pkcs7;
- (NSData *)decrypt:(NSData *)plainText key:(NSData *)aSymmetricKey padding:(CCOptions *)pkcs7;

- (NSData *)doCipher:(NSData *)plainText key:(NSData *)aSymmetricKey
			 context:(CCOperation)encryptOrDecrypt padding:(CCOptions *)pkcs7;

//- (NSData*) md5data: ( NSString *) str;


@end
