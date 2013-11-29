//
//  OutlineItem.h
//  Reader_Demo_1
//
//  Created by Zhou Shuyan on 10-4-12.
//  Copyright 2010 VIT. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OutlineItem : NSObject {
	NSString* title;
    NSValue * pageVal;
	NSMutableArray* children;
	NSUInteger page;
	NSUInteger x;
	NSUInteger y;
	// sub item level
	NSUInteger level;
}

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSValue * pageVal;
@property (nonatomic, retain) NSMutableArray* children;
@property NSUInteger page;
@property NSUInteger x;
@property NSUInteger y;
@property NSUInteger level;

@end
