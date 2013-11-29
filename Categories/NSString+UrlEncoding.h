//
//  NSString+UrlEncoding.h
//  MClip
//
//  Created by Wonpyo Hong on 12. 11. 6..
//  Copyright (c) 2012년 BMBComs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UrlEncoding)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
- (NSString *)decodeFromPercentEscapeString:(NSString *)string;
- (NSString *)stringByAddingRFC3875PercentEscapesUsingEncoding:(NSStringEncoding)encoding;
@end
