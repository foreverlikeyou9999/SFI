//
//  OutlineItem.m
//  Reader_Demo_1
//
//  Created by Zhou Shuyan on 10-4-12.
//  Copyright 2010 VIT. All rights reserved.
//

#import "OutlineItem.h"


@implementation OutlineItem

@synthesize title, children, page, x, y, level, pageVal;

-(id) init {
	if (self = [super init]) {
		children = [[NSMutableArray alloc] init];
	}
	return self;
}

@end
