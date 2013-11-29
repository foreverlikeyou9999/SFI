//
//  NSString+UrlEncoding.m
//  MClip
//
//  Created by Wonpyo Hong on 12. 11. 6..
//  Copyright (c) 2012년 BMBComs. All rights reserved.
//

#import "NSString+UrlEncoding.h"

@implementation NSString (UrlEncoding)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
}

- (NSString *)decodeFromPercentEscapeString:(NSString *)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                         (CFStringRef)self,
                                                                                         CFSTR(""),
                                                                                         kCFStringEncodingUTF8));
}

- (NSString *)stringByAddingRFC3875PercentEscapesUsingEncoding:(NSStringEncoding)encoding {
    CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);
    NSString *rfcEscaped = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
																			   NULL,
																			   (CFStringRef)self,
																			   NULL,
																			   (CFStringRef)@"+",
																			   cfEncoding));
    return rfcEscaped;
}

@end
