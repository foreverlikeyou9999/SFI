//
//  LoadingViewController.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 9. 2..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "LoadingViewController.h"
//
#import "AppDelegate.h"
//
#import "LoginViewController/LoginViewController.h"

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

@interface LoadingViewController ()

@end

@implementation LoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIImageView *loadingImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
    [loadingImg setFrame:CGRectMake(0, -20, loadingImg.image.size.width, loadingImg.image.size.height)];
    [self.view addSubview:loadingImg];
    
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//    [self.navigationController presentViewController:app.navigationC2 animated:YES completion:^{
//        
//    }];
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
