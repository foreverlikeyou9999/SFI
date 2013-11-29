//
//  BrandSelectViewController.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 9. 2..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "BrandSelectViewController.h"
//
#import "AppDelegate.h"

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

@interface BrandSelectViewController ()

@end

@implementation BrandSelectViewController
@synthesize brandListArr = _brandListArr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        self.brandListArr = [[[NSArray alloc] init] autorelease];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_CommonBG_01.jpg"]];
    [baseView setUserInteractionEnabled:YES];
    [baseView setFrame:CGRectMake(0, HEIGHT, baseView.image.size.width, baseView.image.size.height)];
    [self.view addSubview:baseView];
    
    UIImageView *box = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Login_BrandBG"]];
    [box setUserInteractionEnabled:YES];
    [box setFrame:CGRectMake(28, 116, box.image.size.width, box.image.size.height)];
    [baseView addSubview:box];
    
    UIScrollView *brandList = [[UIScrollView alloc] initWithFrame:CGRectMake(8, 52, 692, 730)];
    [brandList setDelegate:self];
    [brandList setBackgroundColor:[UIColor clearColor]];
    [brandList setShowsVerticalScrollIndicator:NO];
    [brandList setContentSize:CGSizeMake(692, (107 * (([self.brandListArr count]) / 3) + 1) + 101)];
    [box addSubview:brandList];
    
    UIButton *btn;
    for (int i = 0; i < [self.brandListArr count]; i++) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTag:i];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_small", [[self.brandListArr objectAtIndex:i] objectForKey:@"brandCd"]]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"IM_Login_BrandBox"] forState:UIControlStateNormal];
        [btn setFrame:CGRectMake(((i % 3) * 228) + ((i % 3) * 8), ((i / 3) * 101) + ((i / 3) * 6), 228, 101)];
        [btn addTarget:self action:@selector(selectedBrand:) forControlEvents:UIControlEventTouchUpInside];
        [brandList addSubview:btn];
    }
}

- (void)selectedBrand:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[[self.brandListArr objectAtIndex:((UIButton *)sender).tag] objectForKey:@"brandCd"] forKey:@"brandcd"];
    [[NSUserDefaults standardUserDefaults] setObject:[[self.brandListArr objectAtIndex:((UIButton *)sender).tag] objectForKey:@"shopCd"] forKey:@"shopCd"];
    [[NSUserDefaults standardUserDefaults] setObject:self.brandListArr forKey:@"brandList"];
//    brand 추가시 사용
//    [[NSUserDefaults standardUserDefaults] setObject:[[self.brandListArr objectAtIndex:((UIButton *)sender).tag] objectForKey:@"brandNm"] forKey:@"brandNm"];
    [[NSUserDefaults standardUserDefaults] setObject:@"KOLON SPORT" forKey:@"brandNm"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app mainChange];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        
        [[NSUserDefaults standardUserDefaults] setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"logintime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
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
