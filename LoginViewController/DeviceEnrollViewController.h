//
//  DeviceEnrollViewController.h
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 14..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceEnrollViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
    NSMutableArray *textFieldArr;
    
    LoadingView *loadingView;
}

@property (nonatomic, strong) NSArray *userInfo;
@property (nonatomic, strong) NSString *userType;

@end
