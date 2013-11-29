//
//  GlobalValue.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 4..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalValue : NSObject {
	NSString *value;
    NSString *pw;
    int menuIndex;
}

@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *pw;
@property int menuIndex;

+ (GlobalValue *)sharedSingleton;

@end
