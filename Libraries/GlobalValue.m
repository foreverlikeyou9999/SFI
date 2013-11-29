//
//  GlobalValue.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 4..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "GlobalValue.h"

@implementation GlobalValue
@synthesize value = _value;
@synthesize pw = _pw;
@synthesize menuIndex = _menuIndex;

static GlobalValue *_globalValue = nil;

+(GlobalValue *)sharedSingleton
{
	@synchronized([GlobalValue class])
	{
		if (!_globalValue)
		{
			[[GlobalValue alloc] init];
		}
		return _globalValue;
	}
	return nil;
}

+(id)alloc
{
	@synchronized([GlobalValue class])
	{
		NSAssert(_globalValue == nil, @"Test...");
		_globalValue = [super alloc];
		return _globalValue;
	}
	return nil;
}

@end
