//
//  EduSubViewController.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 4..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "EduSubViewController.h"

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

@interface EduSubViewController ()

@end

@implementation EduSubViewController
@synthesize delegate;
@synthesize thumbnailInfo = _thumbnailInfo;
@synthesize currentCtgryMenuIndex = _currentCtgryMenuIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        videoFullScreen = NO;
        
        menuList = [[NSMutableArray alloc] init];
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
    
    BOOL loadingViewCheck = NO;
    for (UIView *view in self.view.subviews) {
        if (view == app.loadingView) {
            loadingViewCheck = YES;
        }
    }

    if (!naviCheck) {
        [app.naviBar setDelegate:self];
        [app.naviBar setNaviTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"brandNm"]];
        [app.naviBar createComponents];
        [self.view addSubview:app.naviBar];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreen:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreen:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    cntBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_CommonBG_01.jpg"]];
    [cntBgView setFrame:CGRectMake(0, 44 + HEIGHT, cntBgView.image.size.width, cntBgView.image.size.height)];
    [cntBgView setUserInteractionEnabled:YES];
    [self.view addSubview:cntBgView];
    
    UILabel *lbl;
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 34, 500, 40)];
    [lbl setText:@"교육관리"];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setFont:[UIFont boldSystemFontOfSize:36]];
    [cntBgView addSubview:lbl];
    
    UIImageView *titleUnderBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Img_TitleUnderBar"]];
    [titleUnderBarView setFrame:CGRectMake(20, 86, titleUnderBarView.image.size.width, titleUnderBarView.image.size.height)];
    [cntBgView addSubview:titleUnderBarView];
    
    menuScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 56, 1, 12)];
    [menuScroll setDelegate:self];
    [menuScroll setTag:100031];
    [menuScroll setBackgroundColor:[UIColor clearColor]];
    [menuScroll setShowsVerticalScrollIndicator:NO];
    [menuScroll setContentSize:CGSizeZero];
    [cntBgView addSubview:menuScroll];
    
    menuList = [[NSUserDefaults standardUserDefaults] objectForKey:@"edumenulist2"];
    
    UIButton *btn;
    
    for (int i = 0; i < [menuList count] + 1; i++) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTag:i];
        [btn setAdjustsImageWhenHighlighted:NO];
        
        if (i == 0) {
            [btn setImage:[CommonUtil createNormalBtn:@"전체"] forState:UIControlStateNormal];
            [btn setImage:[CommonUtil createHighlightBtn:@"전체"] forState:UIControlStateSelected];
            
            [btn setSelected:NO];
            [btn setUserInteractionEnabled:YES];
            [btn setFrame:CGRectMake(0, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
        } else {
            [btn setImage:[CommonUtil createNormalBtn:[[menuList objectAtIndex:i - 1] objectForKey:@"ctgryNm"]] forState:UIControlStateNormal];
            [btn setImage:[CommonUtil createHighlightBtn:[[menuList objectAtIndex:i - 1] objectForKey:@"ctgryNm"]] forState:UIControlStateSelected];
            
            if (_currentCtgryMenuIndex == 0) {
                if ([[_thumbnailInfo objectForKey:@"ctgryNm"] isEqualToString:[NSString stringWithFormat:@"%@", [[menuList objectAtIndex:i - 1] objectForKey:@"ctgryNm"]]]) {
                    [btn setSelected:YES];
                    [btn setUserInteractionEnabled:NO];
                } else {
                    [btn setSelected:NO];
                    [btn setUserInteractionEnabled:YES];
                }
            } else {
                if (_currentCtgryMenuIndex == i) {
                    [btn setSelected:YES];
                    [btn setUserInteractionEnabled:NO];
                } else {
                    [btn setSelected:NO];
                    [btn setUserInteractionEnabled:YES];
                }
            }
            
            [btn setFrame:CGRectMake(((UIButton *)[btnArr objectAtIndex:i - 1]).frame.size.width + ((UIButton *)[btnArr objectAtIndex:i - 1]).frame.origin.x + 20, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
        }
        
        [btn addTarget:self action:@selector(viewChange:) forControlEvents:UIControlEventTouchUpInside];
        [btnArr addObject:btn];
    }
    
    [menuScroll setFrame:CGRectMake(cntBgView.image.size.width - (((UIButton *)[btnArr lastObject]).frame.origin.x + ((UIButton *)[btnArr lastObject]).frame.size.width) - 12, 56, ((UIButton *)[btnArr lastObject]).frame.origin.x + ((UIButton *)[btnArr lastObject]).frame.size.width, ((UIButton *)[btnArr lastObject]).frame.size.height)];
    [menuScroll setContentSize:CGSizeMake(((UIButton *)[btnArr lastObject]).frame.origin.x + ((UIButton *)[btnArr lastObject]).frame.size.width, ((UIButton *)[btnArr lastObject]).frame.size.height)];
    
    for (int i = 0; i < [btnArr count]; i++) {
        [menuScroll addSubview:((UIButton *)[btnArr objectAtIndex:i])];
    }
    
    NSURL *url = [NSURL URLWithString:[_thumbnailInfo objectForKey:@"linkUrl"]];
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [moviePlayer setControlStyle:MPMovieControlStyleDefault];
    [moviePlayer setScalingMode:MPMovieScalingModeNone];
    CGRect frame = CGRectMake(12, 120, [UIScreen mainScreen].bounds.size.width - 24, 420);
    [moviePlayer.view setFrame:frame];  // player's frame must match parent's
    [cntBgView addSubview: moviePlayer.view];
    [cntBgView bringSubviewToFront:moviePlayer.view];
    
    UIView *mpTitleBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, moviePlayer.view.frame.size.width, 30)];
    [mpTitleBg setBackgroundColor:[UIColor blackColor]];
    [mpTitleBg setAlpha:0.3f];
    [moviePlayer.view addSubview:mpTitleBg];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, moviePlayer.view.frame.size.width - 17, 30)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setText:[_thumbnailInfo objectForKey:@"cntntsNm"]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setTextColor:[UIColor whiteColor]];
    [moviePlayer.view addSubview:lbl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    
    [moviePlayer prepareToPlay];
    [moviePlayer play];
    
    UIView *mpCntntsBg = [[UIView alloc] initWithFrame:CGRectMake(12, 570, [UIScreen mainScreen].bounds.size.width - 24, 370)];
    [mpCntntsBg setBackgroundColor:[UIColor blackColor]];
    [mpCntntsBg setAlpha:0.3f];
    [cntBgView addSubview:mpCntntsBg];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:mpCntntsBg.frame];
    [textView setDelegate:self];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setTextColor:[UIColor whiteColor]];
    [textView setText:[NSString stringWithFormat:@"%@", [_thumbnailInfo objectForKey:@"cntntsCn"]]];
    [cntBgView addSubview:textView];
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
}

- (void)viewChange:(id)sender {
    [[self.navigationController.viewControllers objectAtIndex:1] viewChange:sender];
    [self goPrev];
}

//- (void)clickedMobileMenuBtnAtIndex:(NSInteger)buttonIndex {
//    [delegate clickedButtonAtIndex:buttonIndex];
//}
//
//- (void)clickedFixedMenuBtnAtIndex:(NSInteger)buttonIndex {
//    
//}

#pragma mark - Navigation bar delegate

- (void)clickedMobileMenuBtnAtIndex:(NSInteger)buttonIndex {
//    [delegate menuIndexConnect:buttonIndex];
    [delegate clickedButtonAtIndex:buttonIndex];
}

- (void)clickedFixedMenuBtnAtIndex:(NSInteger)buttonIndex {
//    [delegate menuIndexConnect:buttonIndex];
    [delegate clickedButtonAtIndex:buttonIndex];
}

- (void)goHome:(NavigationBar *)naviBar {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.naviBar setNaviTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"brandNm"]];
    
    if (moviePlayer.isPreparedToPlay) {
        [moviePlayer stop];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)goPrev {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.naviBar setNaviTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"brandNm"]];
    
    if (moviePlayer.isPreparedToPlay) {
        [moviePlayer stop];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)fullScreen:(id)sender {
    if ([((NSNotification *)sender).name isEqualToString:@"UIMoviePlayerControllerDidEnterFullscreenNotification"]) {
        videoFullScreen = YES;
    } else {
        videoFullScreen = NO;
    }
}

-(BOOL) shouldAutorotate {
    return videoFullScreen;
}

-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
