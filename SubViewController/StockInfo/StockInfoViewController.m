//
//  StockInfoViewController.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 21..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "StockInfoViewController.h"

#define HEIGHT            [CommonUtil osVersion]

@implementation UINavigationController (Rotation_IOS6)

-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end

@interface StockInfoViewController ()

@end

@implementation StockInfoViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    BOOL naviCheck = NO;
    for (UIView *view in self.view.subviews) {
        if (view == app.naviBar) {
            naviCheck = YES;
        }
    }
    
    if (!naviCheck) {
        [app.naviBar setDelegate:self];
        [app.naviBar setNaviTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"brandNm"]];
        [app.naviBar createComponents];
        [self.view addSubview:app.naviBar];
    }
    
    BOOL loadingViewCheck = NO;
    for (UIView *view in self.view.subviews) {
        if (view == app.loadingView) {
            loadingViewCheck = YES;
        }
    }
    
    if (!loadingViewCheck) {
        [self.view addSubview:app.loadingView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.naviBar menuAllClose];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    cntBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_CommonBG_01.jpg"]];
    [cntBgView setFrame:CGRectMake(0, 44 + HEIGHT, cntBgView.image.size.width, cntBgView.image.size.height)];
    [cntBgView setUserInteractionEnabled:YES];
    [self.view addSubview:cntBgView];
    
    UILabel *lbl;
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 34, 500, 40)];
    [lbl setText:@"상품조회"];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setFont:[UIFont boldSystemFontOfSize:36]];
    [cntBgView addSubview:lbl];
    
    UIImageView *titleUnderBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Img_TitleUnderBar"]];
    [titleUnderBarView setFrame:CGRectMake(20, 86, titleUnderBarView.image.size.width, titleUnderBarView.image.size.height)];
    [cntBgView addSubview:titleUnderBarView];
}

#pragma mark - Navigation bar delegate

- (void)clickedMobileMenuBtnAtIndex:(NSInteger)buttonIndex {
    [delegate menuIndexConnect:buttonIndex];
}

- (void)clickedFixedMenuBtnAtIndex:(NSInteger)buttonIndex {
    [delegate menuIndexConnect:buttonIndex];
}

- (void)goHome:(NavigationBar *)naviBar {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)goPrev {
//    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
