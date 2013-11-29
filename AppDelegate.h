//
//  AppDelegate.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 21..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>
//
#import "NavigationBar.h"
#import "PasswordView.h"
#import "LoadingView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UISplitViewControllerDelegate, UIAlertViewDelegate> {
    CGPDFDocumentRef _pdfDoc;
    NSTimer *loginTimer;
    
    BOOL keyChainCheck;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationC;
@property (nonatomic, strong) UINavigationController *navigationC2;
@property (nonatomic, strong) UIAlertView *appAlertView;
@property (nonatomic, strong) NavigationBar *naviBar;
@property (nonatomic, strong) PasswordView *pwView;
@property (nonatomic, strong) LoadingView *loadingView;

- (void)logout:(NSString *)animation;
- (void)callAlertView;
- (void)mainChange;

- (void)setDocument:(CGPDFDocumentRef)document;
- (CGPDFDocumentRef)getDocument;

@end
