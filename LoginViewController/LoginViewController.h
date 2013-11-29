//
//  LoginViewController.h
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 14..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>
//
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate> {
    NSMutableArray *textFieldArr;
    NSMutableArray *loginCheckArr;
    
    NSString *userType;
    
    UIImageView *switchBtn;
    
    LoadingView *loadingView;
    
    UIButton *idSaveChkBtn;
}

@end
