//
//  RepairInfoViewController.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 16..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "RepairInfoViewController.h"
//
#import "PriceListView.h"
#import "ImageListView.h"

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

@interface RepairInfoViewController ()

@end

@implementation RepairInfoViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        btnArr = [[NSMutableArray alloc] init];
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
    
    menuScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 56, 1, 12)];
    [menuScroll setDelegate:self];
    [menuScroll setBackgroundColor:[UIColor clearColor]];
    [menuScroll setShowsVerticalScrollIndicator:NO];
    [menuScroll setContentSize:CGSizeZero];
    [cntBgView addSubview:menuScroll];
    
    UILabel *lbl;
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 34, 500, 40)];
    [lbl setText:@"수선정보"];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setFont:[UIFont boldSystemFontOfSize:36]];
    [cntBgView addSubview:lbl];
    
    UIImageView *titleUnderBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Img_TitleUnderBar"]];
    [titleUnderBarView setFrame:CGRectMake(20, 86, titleUnderBarView.image.size.width, titleUnderBarView.image.size.height)];
    [cntBgView addSubview:titleUnderBarView];
    
    UIButton *btn;
    
    for (int i = 0; i < 2; i++) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTag:i];
        [btn setAdjustsImageWhenHighlighted:NO];
        
        if (i == 0) {
            [btn setImage:[CommonUtil createNormalBtn:@"수선 단가표"] forState:UIControlStateNormal];
            [btn setImage:[CommonUtil createHighlightBtn:@"수선 단가표"] forState:UIControlStateSelected];
            
            [btn setSelected:YES];
            [btn setUserInteractionEnabled:NO];
            [btn setFrame:CGRectMake(0, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
        } else {
            [btn setImage:[CommonUtil createNormalBtn:@"수선 전후 이미지"] forState:UIControlStateNormal];
            [btn setImage:[CommonUtil createHighlightBtn:@"수선 전후 이미지"] forState:UIControlStateSelected];
            
            [btn setSelected:NO];
            [btn setUserInteractionEnabled:YES];
            [btn setFrame:CGRectMake(((UIButton *)[btnArr objectAtIndex:i - 1]).frame.size.width + ((UIButton *)[btnArr objectAtIndex:i - 1]).frame.origin.x + 20, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
        }
        
        [btn addTarget:self action:@selector(viewChange:) forControlEvents:UIControlEventTouchUpInside];
        [btnArr addObject:btn];
        
        [menuScroll setFrame:CGRectMake(cntBgView.image.size.width - (((UIButton *)[btnArr lastObject]).frame.origin.x + ((UIButton *)[btnArr lastObject]).frame.size.width) - 12, 56, ((UIButton *)[btnArr lastObject]).frame.origin.x + ((UIButton *)[btnArr lastObject]).frame.size.width, ((UIButton *)[btnArr lastObject]).frame.size.height)];
        [menuScroll setContentSize:CGSizeMake(((UIButton *)[btnArr lastObject]).frame.origin.x + ((UIButton *)[btnArr lastObject]).frame.size.width, ((UIButton *)[btnArr lastObject]).frame.size.height)];
        
        for (int i = 0; i < [btnArr count]; i++) {
            [menuScroll addSubview:((UIButton *)[btnArr objectAtIndex:i])];
        }
    }
    
    [self viewChange:(UIButton *)[btnArr objectAtIndex:0]];
}

- (void)viewChange:(id)sender {
    NSLog(@"viewChange");
    
    for (int i = 0; i < 2; i++) {
        if (((UIButton *)sender).tag == i) {
            [(UIButton *)[btnArr objectAtIndex:i] setSelected:YES];
            [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:NO];
        } else {
            [(UIButton *)[btnArr objectAtIndex:i] setSelected:NO];
            [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:YES];
        }
    }
    
    if (((UIButton *)sender).tag == 0) {//all
        for (UIView *view in cntBgView.subviews) {
            if ([view isKindOfClass:[ImageListView class]]) {
                [view removeFromSuperview];
            }
        }
        
        PriceListView *priceListView = [[PriceListView alloc] initWithFrame:CGRectMake(0, 120, [UIScreen mainScreen].bounds.size.width, 884)];
        [cntBgView addSubview:priceListView];
        
    } else {//all 이외 모든 버튼
        for (UIView *view in cntBgView.subviews) {
            if ([view isKindOfClass:[PriceListView class]]) {
                [view removeFromSuperview];
            }
        }
        
        ImageListView *imageListView = [[ImageListView alloc] initWithFrame:CGRectMake(0, 120, [UIScreen mainScreen].bounds.size.width, 884)];
        [cntBgView addSubview:imageListView];
    }
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
