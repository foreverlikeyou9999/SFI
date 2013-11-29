//
//  PasswordView.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 8..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PasswordView;

@protocol PasswordViewDelegate <NSObject>

- (void)pwCheckResult:(BOOL)result;
- (void)pwCheckClose:(BOOL)goPrev;

@end

@interface PasswordView : UIView <UITextFieldDelegate> {
    id <PasswordViewDelegate> __weak delegate;
    
    UITextField *pwInput;
}

@property (nonatomic, weak) id <PasswordViewDelegate> delegate;

- (id)init;

@end
