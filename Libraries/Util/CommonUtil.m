//
//  CommonUtil.m
//  SalesForce
//
//  Created by 여성현 on 13. 8. 30..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "CommonUtil.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

@implementation CommonUtil

//네트워크 연결여부 => YES:연결 NO:연결안됨
+(BOOL) isNetworkReachable
{
	struct sockaddr_in zeroAddr;
	bzero(&zeroAddr, sizeof(zeroAddr));
	zeroAddr.sin_len = sizeof(zeroAddr);
	zeroAddr.sin_family = AF_INET;
	
	SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddr);
	
	SCNetworkReachabilityFlags flag;
	SCNetworkReachabilityGetFlags(target, &flag);
	
	if(flag & kSCNetworkFlagsReachable)
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

//네트워크 연결유형 => YES:3G NO:Wifi
+(BOOL)isCellNetwork
{
	struct sockaddr_in zeroAddr;
	bzero(&zeroAddr, sizeof(zeroAddr));
	zeroAddr.sin_len = sizeof(zeroAddr);
	zeroAddr.sin_family = AF_INET;
	
	SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddr);
	
	SCNetworkReachabilityFlags flag;
	SCNetworkReachabilityGetFlags(target, &flag);
	
	if(flag & kSCNetworkReachabilityFlagsIsWWAN)
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

//네트워크 상태 체크..
+ (int)getNetworkState {
    struct sockaddr_in zeroAddr;
	bzero(&zeroAddr, sizeof(zeroAddr));
	zeroAddr.sin_len = sizeof(zeroAddr);
	zeroAddr.sin_family = AF_INET;
	
	SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddr);
	
	SCNetworkReachabilityFlags flag;
	SCNetworkReachabilityGetFlags(target, &flag);
	
	if(flag & kSCNetworkReachabilityFlagsIsWWAN)
	{
        //3g
		return 1;
    }
    else if(flag & kSCNetworkFlagsReachable)
	{
        //wifi
		return 2;
	}
	else
	{
        //none
		return 0;
	}
}

+ (NSData *)transform:(CCOperation)encryptOrDecrypt data:(NSData *)inputData {
    NSData *secretKey = [self md5:@"NTE3YjA0YjUtZGJkZS00NDQ5LTg4NzgtMzFiNWFjMjg1YmZi"];
    
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = kCCSuccess;
    
    uint8_t iv[kCCBlockSizeAES128];
    memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    status = CCCryptorCreate(encryptOrDecrypt, kCCAlgorithmAES128, kCCOptionECBMode|kCCOptionPKCS7Padding,
                             [secretKey bytes], kCCKeySizeAES128, iv, &cryptor);
    
    if (status != kCCSuccess) {
        return nil;
    }
    
    size_t bufsize = CCCryptorGetOutputLength(cryptor, (size_t)[inputData length], true);
    
    void * buf = malloc(bufsize * sizeof(uint8_t));
    memset(buf, 0x0, bufsize);
    
    size_t bufused = 0;
    size_t bytesTotal = 0;
    
    status = CCCryptorUpdate(cryptor, [inputData bytes], (size_t)[inputData length],
                             buf, bufsize, &bufused);
    
    if (status != kCCSuccess) {
        free(buf);
        CCCryptorRelease(cryptor);
        return nil;
    }
    
    bytesTotal += bufused;
    
    status = CCCryptorFinal(cryptor, buf + bufused, bufsize - bufused, &bufused);
    
    if (status != kCCSuccess) {
        free(buf);
        CCCryptorRelease(cryptor);
        return nil;
    }
    
    bytesTotal += bufused;
    
    CCCryptorRelease(cryptor);
    
    return [NSData dataWithBytesNoCopy:buf length:bytesTotal];
}

+ (NSData *) md5:(NSString *) stringToHash {
    const char *src = [stringToHash UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(src, strlen(src), result);
    
    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

+ (UIImage *)resizedImage:(UIImage*)inImage inRect:(CGRect)thumbRect {
    // Creates a bitmap-based graphics context and makes it the current context.
    UIGraphicsBeginImageContext(thumbRect.size);
    [inImage drawInRect:thumbRect];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

+ (UIImage *)cropedImage:(UIImage*)inImage  inRect:(CGRect)cropRect {
    // Creates a bitmap-based graphics context and makes it the current context.
    CGImageRef imageRef = CGImageCreateWithImageInRect([inImage CGImage], cropRect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return img;
}


+ (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)createNormalBtn:(NSString *)btnNm {
    CGSize stringSize = CGSizeZero;
    stringSize = [btnNm sizeWithFont:[UIFont fontWithName:@"Roboto-Bold" size:13.0f]];
    
    UILabel *normalLbl = [[UILabel alloc] init];
    [normalLbl setText:btnNm];
    [normalLbl setBackgroundColor:[UIColor clearColor]];
    [normalLbl setFont:[UIFont fontWithName:@"Roboto-Bold" size:13.0f]];
    [normalLbl setTextColor:[UIColor whiteColor]];
    [normalLbl setFrame:CGRectMake(13, 0, stringSize.width, stringSize.height)];
    
    UIImageView *bulletImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_TabBullet_N"] highlightedImage:[UIImage imageNamed:@"IM_Sub_TabBullet_O"]];
    [bulletImg setFrame:CGRectMake(0, 5, bulletImg.image.size.width, bulletImg.image.size.width)];
    [bulletImg setHighlighted:NO];
    
    UIView *normal = [[UIView alloc] initWithFrame:CGRectMake(0, 0, stringSize.width + 13, stringSize.height*2)];
    [normal setBackgroundColor:[UIColor clearColor]];
    [normal addSubview:bulletImg];
    [normal addSubview:normalLbl];
    
    return [self imageWithView:normal];
}

+ (UIImage *)createHighlightBtn:(NSString *)btnNm {
    CGSize stringSize = CGSizeZero;
    stringSize = [btnNm sizeWithFont:[UIFont fontWithName:@"Roboto-Bold" size:13.0f]];
    
    UILabel *highlightLbl = [[UILabel alloc] init];
    [highlightLbl setText:btnNm];
    [highlightLbl setBackgroundColor:[UIColor clearColor]];
    [highlightLbl setFont:[UIFont fontWithName:@"Roboto-Bold" size:13.0f]];
    [highlightLbl setTextColor:[UIColor colorWithRed:244/255.0f green:89/255.0f blue:71/255.0f alpha:1]];
    [highlightLbl setFrame:CGRectMake(13, 0, stringSize.width, stringSize.height)];
    
    UIImageView *bulletImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_TabBullet_N"] highlightedImage:[UIImage imageNamed:@"IM_Sub_TabBullet_O"]];
    [bulletImg setFrame:CGRectMake(0, 5, bulletImg.image.size.width, bulletImg.image.size.width)];
    [bulletImg setHighlighted:YES];
    
    UIView *highlight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, stringSize.width + 13, stringSize.height*2)];
    [highlight setBackgroundColor:[UIColor clearColor]];
    [highlight addSubview:bulletImg];
    [highlight addSubview:highlightLbl];
    
    return [self imageWithView:highlight];
}

//가격포멧 (3자리마다 ,)
+ (NSString *) makeComma:(NSNumber*)oriNum
{
    if (oriNum == nil) {
        return @"";
    }
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:3];
    return [formatter stringFromNumber:oriNum];
}

+ (NSString *)dateSecReturn:(NSString *)ex_dt withSelect:(NSString *)value {
    NSLog(@"dateMinReturn ex : %@", ex_dt);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // 포맷에 주의!
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateFromString = [dateFormatter dateFromString:ex_dt];
    
    NSDate *now = [NSDate date];
    
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMT];
    dateFromString = [dateFromString dateByAddingTimeInterval:currentGMTOffset];
    now = [now dateByAddingTimeInterval:currentGMTOffset];
    
    //    NSLog(@"ex_dt : %@, now_dt : %@", dateFromString, now);
    NSDateComponents *dateComp;
    if ([value isEqualToString:@"inverse"]) {
        dateComp  = [[NSCalendar currentCalendar] components:NSSecondCalendarUnit fromDate:now toDate:dateFromString options:0];
    } else {
        dateComp  = [[NSCalendar currentCalendar] components:NSSecondCalendarUnit fromDate:dateFromString toDate:now options:0];
    }
    NSLog(@"second : %d", [dateComp second]);
    return [NSString stringWithFormat:@"%d", [dateComp second]];
}

//keychain
+ (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:[[NSBundle mainBundle] bundleIdentifier] forKey:(__bridge id)kSecAttrService];
    
    return searchDictionary;
}

+ (NSData *)searchKeychainCopyMatching:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    
    // Add search attributes
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    // Add search return types
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    CFDataRef result;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, (CFTypeRef *)&result);
    
    return (__bridge_transfer NSData *)result;
}

+ (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:passwordData forKey:(__bridge id)kSecValueData];
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

+ (BOOL)updateKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:passwordData forKey:(__bridge id)kSecValueData];
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary, (__bridge CFDictionaryRef)updateDictionary);
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

+ (void)deleteKeychainValue:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    OSStatus junk = SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
    if (junk == noErr || junk == errSecItemNotFound) {
        NSLog(@"Problem deleting current dictionary.");
    }
}

+ (NSString *)machineName {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (int)osVersion {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
        return 0;
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        return 20;
    }
}

@end
