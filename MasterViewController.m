//
//  MasterViewController.m
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 14..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "MasterViewController.h"
//
#import "AppDelegate.h"
//subView
#import "SubViewController/Contents/ContentsViewController.h"
#import "SubViewController/Education/EduListViewController.h"
#import "SubViewController/ShopInfo/ShopInfoViewController.h"
#import "SubViewController/RepairInfo/RepairInfoViewController.h"
#import "SubViewController/StockInfo/StockInfoViewController.h"
//
#import "LoadingView.h"
//
#import "httpRequest.h"
#import "downloadRequest.h"
#import "JSONKit.h"
#import "ZipArchive.h"
#import "AESCrypt.h"
#import "CommonUtil.h"
#import "NSData+AESAdditions.h"

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

@interface MasterViewController ()

@end

@implementation MasterViewController
//@synthesize category = _category;
@synthesize selectIndex = _selectIndex;
@synthesize screenSaverTimer = _screenSaverTimer;
@synthesize timeTimer = _timeTimer;
@synthesize dirPath = _dirPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        menuList = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"mainmenulist"]];
        scrollArr = [[NSMutableArray alloc] init];
        thumbArr = [[NSMutableArray alloc] init];
        
        receivedData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.timeTimer == nil) {
        self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeViewTimer) userInfo:nil repeats:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.timeTimer invalidate];
    self.timeTimer = nil;
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
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.naviBar setNaviTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"brandNm"]];
    
    UIImageView *baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_CommonBG_01.jpg"]];
    [baseView setFrame:CGRectMake(0, HEIGHT, baseView.image.size.width, baseView.image.size.height)];
    [baseView setUserInteractionEnabled:YES];
    [self.view addSubview:baseView];
    
    UIScrollView *_scrollView;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(152, 88, [UIScreen mainScreen].bounds.size.width - 152, 838)];//메인이미지
    [_scrollView setTag:0];
    [_scrollView setDelegate:self];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setContentOffset:CGPointZero];
    [_scrollView setHidden:YES];
    [baseView addSubview:_scrollView];
    [scrollArr addObject:_scrollView];
    
    menuListBase = [[UIView alloc] initWithFrame:CGRectMake(0, 88, 148, 912)];
    [menuListBase setBackgroundColor:[UIColor clearColor]];
    [baseView addSubview:menuListBase];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(4, 0, 144, 764)];//메인메뉴
    [_scrollView setTag:1];
    [_scrollView setDelegate:self];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [scrollArr addObject:_scrollView];
    [menuListBase addSubview:_scrollView];
    
    //시계
    UIImageView *timeInfoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Main_TimeBG"]];
    [timeInfoView setFrame:CGRectMake(3, 768, timeInfoView.image.size.width, timeInfoView.image.size.height)];
    [menuListBase addSubview:timeInfoView];
    
    UIView *calendarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 144, 36)];
    [calendarView setBackgroundColor:[UIColor clearColor]];
    [timeInfoView addSubview:calendarView];
    
    NSDate *now = [[NSDate alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    UILabel *weekLbl = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, 108, 18)];
    [weekLbl setBackgroundColor:[UIColor clearColor]];
    NSDateFormatter *calFormat1 = [[NSDateFormatter alloc] init];
    [calFormat1 setDateFormat:@"EEEE"];
    [calFormat1 setLocale:locale];
    [weekLbl setText:[[calFormat1 stringFromDate:now] uppercaseString]];
    [weekLbl setFont:[UIFont fontWithName:@"Roboto-Regular" size:11.0f]];
    [weekLbl setTextColor:[UIColor whiteColor]];
    [weekLbl setShadowColor:[UIColor blackColor]];
    [weekLbl setShadowOffset:CGSizeMake(1, 0)];
    [calendarView addSubview:weekLbl];
    
    UILabel *monthLbl = [[UILabel alloc] initWithFrame:CGRectMake(35, 18, 108, 16)];
    [monthLbl setBackgroundColor:[UIColor clearColor]];
    NSDateFormatter *calFormat2 = [[NSDateFormatter alloc] init];
    [calFormat2 setDateFormat:@"MMMM dd, y"];
    [calFormat2 setLocale:locale];
    [monthLbl setText:[[calFormat2 stringFromDate:now] uppercaseString]];
    [monthLbl setFont:[UIFont fontWithName:@"Roboto-Regular" size:10.0f]];
    [monthLbl setTextColor:[UIColor colorWithRed:149/255.0f green:196/255.0f blue:101/255.0f alpha:1]];
    [monthLbl setShadowColor:[UIColor blackColor]];
    [monthLbl setShadowOffset:CGSizeMake(1, 0)];
    [calendarView addSubview:monthLbl];
    
    UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(0, 36, 144, 34)];
    [timeView setBackgroundColor:[UIColor clearColor]];
    [timeInfoView addSubview:timeView];
    
    NSString *str = @"AM 00:00:00";
    CGSize strSize = [str sizeWithFont:[UIFont fontWithName:@"Roboto-Regular" size:18.0f]];
    
    timeLbl = [[UILabel alloc] initWithFrame:CGRectMake(144 - strSize.width - 7, 17 - strSize.height/2, strSize.width, strSize.height)];
    [timeLbl setBackgroundColor:[UIColor clearColor]];
    [timeLbl setFont:[UIFont fontWithName:@"Roboto-Regular" size:18.0f]];
    [timeLbl setTextAlignment:NSTextAlignmentRight];
    [timeLbl setTextColor:[UIColor whiteColor]];
    [timeLbl setShadowColor:[UIColor blackColor]];
    [timeLbl setShadowOffset:CGSizeMake(1, 0)];
    [timeView addSubview:timeLbl];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"a hh:mm:ss"];
	[format setLocale:locale];
    
    [timeLbl setText:[format stringFromDate:now]];
    
    self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeViewTimer) userInfo:nil repeats:YES];
    
    UIButton *btn;
    UIImageView *icon;
    UILabel *btnLbl;
    for (int i = 0; i < [menuList count]; i++) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTag:i];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"IM_Main_Menu0%d", (i % 4) + 1]] forState:UIControlStateNormal];
        [btn setFrame:CGRectMake(0, i * 144 + (i * 4), 144, 144)];
        [btn addTarget:self action:@selector(enterMenu:) forControlEvents:UIControlEventTouchUpInside];
        [((UIScrollView *)[scrollArr objectAtIndex:1]) addSubview:btn];
        
        icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"IM_Main_Icon0%d", (i % 4) + 1]]];
        [icon setFrame:CGRectMake(144/2 - icon.image.size.width/2, 144/2 - icon.image.size.height, icon.image.size.width, icon.image.size.height)];
        [btn addSubview:icon];
        
        btnLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 104, 144, 22)];
        [btnLbl setBackgroundColor:[UIColor clearColor]];
        [btnLbl setTextColor:[UIColor whiteColor]];
        [btnLbl setText:[[menuList objectAtIndex:i] objectForKey:@"ctgryDc"]];
        [btnLbl setFont:[UIFont fontWithName:@"Roboto-Medium" size:18.0f]];
        [btnLbl setShadowColor:[UIColor blackColor]];
        [btnLbl setShadowOffset:CGSizeMake(1, 0)];
        [btnLbl setTextAlignment:NSTextAlignmentCenter];
        [btn addSubview:btnLbl];
    }
    
    NSArray *fixMenuList = [[NSArray alloc] initWithObjects:@"수선정보", @"매장정보", @"상품조회", @"멤버쉽 가입/조회", @"매장 STOP제", @"매장 CHECKLIST", nil];
    
    for (int i = [menuList count]; i < [menuList count] + [fixMenuList count]; i++) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTag:i];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"IM_Main_Menu0%d", (i % 4) + 1]] forState:UIControlStateNormal];
        [btn setFrame:CGRectMake(0, i * 144 + (i * 4), 144, 144)];
        [btn addTarget:self action:@selector(enterFixMenu:) forControlEvents:UIControlEventTouchUpInside];
        [((UIScrollView *)[scrollArr objectAtIndex:1]) addSubview:btn];
        
        icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"IM_Main_Icon0%d", (i % 4) + 1]]];
        [icon setFrame:CGRectMake(144/2 - icon.image.size.width/2, 144/2 - icon.image.size.height, icon.image.size.width, icon.image.size.height)];
        [btn addSubview:icon];
        
        btnLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 104, 144, 22)];
        [btnLbl setBackgroundColor:[UIColor clearColor]];
        [btnLbl setTextColor:[UIColor whiteColor]];
        [btnLbl setText:[fixMenuList objectAtIndex:i - [menuList count]]];
        [btnLbl setFont:[UIFont fontWithName:@"Roboto-Medium" size:18.0f]];
        [btnLbl setShadowColor:[UIColor blackColor]];
        [btnLbl setShadowOffset:CGSizeMake(1, 0)];
        [btnLbl setTextAlignment:NSTextAlignmentCenter];
        [btn addSubview:btnLbl];
    }
    
//    메인메뉴 컨텐츠 사이즈
    [((UIScrollView *)[scrollArr objectAtIndex:1]) setContentSize:CGSizeMake(144, 148 * ([menuList count] + [fixMenuList count]))];
    
    thumbnailBase = [[UIView alloc] initWithFrame:CGRectMake(0, 930, [UIScreen mainScreen].bounds.size.width, 70)];
    [thumbnailBase setBackgroundColor:[UIColor clearColor]];
    [baseView addSubview:thumbnailBase];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(152, 0, [UIScreen mainScreen].bounds.size.width - 152, 70)];//메인썸네일
    [_scrollView setTag:2];
    [_scrollView setDelegate:self];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollArr addObject:_scrollView];
    [thumbnailBase addSubview:_scrollView];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"IM_Main_MenuSV"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(3, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
    [btn addTarget:self action:@selector(callScreenSaver:) forControlEvents:UIControlEventTouchUpInside];
    [thumbnailBase addSubview:btn];
    
    naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 84)];
    [naviBar setBackgroundColor:[UIColor clearColor]];
    [baseView addSubview:naviBar];
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_large", [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]]]];
    [logoView setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - logoView.image.size.width/2, 44 - logoView.image.size.height/2, logoView.image.size.width, logoView.image.size.height)];
    [naviBar addSubview:logoView];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"IM_Main_Btn_Brand_N"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"IM_Main_Btn_Brand_O"] forState:UIControlStateSelected];
    [btn setFrame:CGRectMake(26, 22, btn.imageView.image.size.width, btn.imageView.image.size.height)];
    [btn addTarget:self action:@selector(brandSelect) forControlEvents:UIControlEventTouchUpInside];
    [naviBar addSubview:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"IM_Main_Btn-LogOut_N"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(698, 22, btn.imageView.image.size.width, btn.imageView.image.size.height)];
    [btn addTarget:self action:@selector(callLogin) forControlEvents:UIControlEventTouchUpInside];
    [naviBar addSubview:btn];
    
    brandSelectBase = [[UIView alloc] initWithFrame:CGRectMake(0, 88, [UIScreen mainScreen].bounds.size.width, 916)];
    [brandSelectBase setBackgroundColor:[UIColor clearColor]];
    [brandSelectBase setHidden:YES];
    [baseView addSubview:brandSelectBase];
    
    UIImageView *brandTitleBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Brand_BG"]];
    [brandTitleBg setUserInteractionEnabled:YES];
    [brandTitleBg setFrame:CGRectMake(0, 0, brandTitleBg.image.size.width, 916)];
    [brandSelectBase addSubview:brandTitleBg];
    
    UIImageView *brandTitleBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Brand_TitleBar01"]];
    [brandTitleBar setFrame:CGRectMake(0, -10, brandTitleBar.image.size.width, brandTitleBar.image.size.height)];
    [brandTitleBg addSubview:brandTitleBar];
    
    UIScrollView *brandList = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, 220, 876)];
    [brandList setDelegate:self];
    [brandList setBackgroundColor:[UIColor clearColor]];
    [brandList setShowsVerticalScrollIndicator:NO];
    [brandList setContentSize:CGSizeMake(220, 876)];
    [brandTitleBg addSubview:brandList];
    
    NSArray *brandArr = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"brandList"]];
    
    for (int i = 0; i < [brandArr count]; i++) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) {
            
        } else {
            
        }
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_small", [[brandArr objectAtIndex:i] objectForKey:@"brandCd"]]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"IM_Brand_NormalBG"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"IM_Brand_SelectBG"] forState:UIControlStateSelected];
        [btn setFrame:CGRectMake(0, (i * 42) + (i * 1), 220, 42)];
        [brandList addSubview:btn];
    }
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&accessToken=%@&timestamp=%0.f"
                     , KHOST
                     , GETMAININFO
                     , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                     , [temp hexadecimalString]
                     , timeInMiliseconds];
    
    httpRequest *_httpRequest = [[httpRequest alloc] init];
    [_httpRequest setDelegate:self selector:@selector(mainResult:)];
    [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    
    [app.loadingView showLoadingSet];
    [app.loadingView startLoading];
}

- (void)brandSelect {
    if (brandSelectBase.hidden) {
        [brandSelectBase setHidden:NO];
    } else {
        [brandSelectBase setHidden:YES];
    }
}

- (void)callLogin {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:@"로그아웃 하시겠습니까?" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
    [alertView setTag:0];
    [alertView show];
}

- (void)timeViewTimer {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"a hh:mm:ss"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[format setLocale:locale];
    
    NSDate *now = [[NSDate alloc] init];
    [timeLbl setText:[format stringFromDate:now]];
}

- (void)callScreenSaver:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    [self.timeTimer invalidate];
    self.timeTimer = nil;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    screenSaverCnt = 1;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *fileList = [[NSMutableArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:self.dirPath error:nil]];
    
    int j = 0;
    for (int i = 0; i < [fileList count]; i++) {
        if ([[fileList objectAtIndex:i - j] rangeOfString:@".zip"].location != NSNotFound || [[fileList objectAtIndex:i - j] rangeOfString:@"MACOSX"].location != NSNotFound) {
            [fileList removeObjectAtIndex:i - j];
            j++;
        }
    }
    
    screenSaverBase = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - HEIGHT)];
    [screenSaverBase setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:screenSaverBase];
    
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissScreenSaver:)];
    //    [screenSaverBase addGestureRecognizer:tap];
    
    [naviBar setFrame:CGRectMake(0, -88, naviBar.bounds.size.width, naviBar.bounds.size.height)];
    [menuListBase setFrame:CGRectMake(-152, 0, menuListBase.bounds.size.width, menuListBase.bounds.size.height)];
    [thumbnailBase setFrame:CGRectMake(152, 1008, thumbnailBase.bounds.size.width, thumbnailBase.bounds.size.height)];
    
    UIScrollView *screenSaverScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [screenSaverScroll setTag:3];
    [screenSaverScroll setUserInteractionEnabled:NO];
    [screenSaverScroll setDelegate:self];
    [screenSaverScroll setBackgroundColor:[UIColor clearColor]];
    [screenSaverScroll setContentSize:CGSizeMake(([fileList count] + 1) * [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - HEIGHT)];
    [screenSaverScroll setPagingEnabled:YES];
    [screenSaverScroll setShowsHorizontalScrollIndicator:NO];
    [scrollArr addObject:screenSaverScroll];
    [screenSaverBase addSubview:screenSaverScroll];
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] < 7) {//iOS 5, 6
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = 0; i < [fileList count] + 1; i++) {
                if (i == [fileList count]) {
                    UIImageView *mainImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", self.dirPath, [fileList objectAtIndex:0]]]];
                    [mainImg setFrame:CGRectMake(i * [UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [screenSaverScroll addSubview:mainImg];
                    });
                    
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissScreenSaver:)];
                    [screenSaverBase addGestureRecognizer:tap];
                } else {
                    UIImageView *mainImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", self.dirPath, [fileList objectAtIndex:i]]]];
                    [mainImg setFrame:CGRectMake(i * [UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [screenSaverScroll addSubview:mainImg];
                    });
                }
            }
            
        });
    } else {//iOS 7
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = 0; i < [fileList count] + 1; i++) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (i == [fileList count]) {
                        
                        UIImageView *mainImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", self.dirPath, [fileList objectAtIndex:0]]]];
                        [mainImg setFrame:CGRectMake(i * [UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
                        
                        [screenSaverScroll addSubview:mainImg];
                        
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissScreenSaver:)];
                        [screenSaverBase addGestureRecognizer:tap];
                    } else {
                        UIImageView *mainImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", self.dirPath, [fileList objectAtIndex:i]]]];
                        [mainImg setFrame:CGRectMake(i * [UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
                        
                        [screenSaverScroll addSubview:mainImg];
                    }
                });
            }
            
        });
    }
    
    self.screenSaverTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(imageMove) userInfo:nil repeats:YES];
}

- (void)dismissScreenSaver:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [scrollArr removeLastObject];
    [screenSaverBase removeFromSuperview];
    
    [self.screenSaverTimer invalidate];
    self.screenSaverTimer = nil;
    
    [naviBar setFrame:CGRectMake(0, 0, naviBar.bounds.size.width, naviBar.bounds.size.height)];
    [menuListBase setFrame:CGRectMake(0, 88, menuListBase.bounds.size.width, menuListBase.bounds.size.height)];
    [thumbnailBase setFrame:CGRectMake(0, 930, thumbnailBase.bounds.size.width, thumbnailBase.bounds.size.height)];
    
    self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeViewTimer) userInfo:nil repeats:YES];
}

- (void)imageMove {
    if (screenSaverCnt == [((UIScrollView *)[scrollArr objectAtIndex:3]).subviews count] - 1) {
        screenSaverCnt = 1;
        [((UIScrollView *)[scrollArr objectAtIndex:3]) setContentOffset:CGPointMake(0 * [UIScreen mainScreen].bounds.size.width, 0) animated:NO];
    }
    
    [((UIScrollView *)[scrollArr objectAtIndex:3]) setContentOffset:CGPointMake(screenSaverCnt * [UIScreen mainScreen].bounds.size.width, 0) animated:YES];
    
    screenSaverCnt++;
}

- (void)enterMenu:(id)sender {
    self.selectIndex = ((UIButton *)sender).tag;
    
    [[GlobalValue sharedSingleton] setMenuIndex:((UIButton *)sender).tag];
    
    if ([[[menuList objectAtIndex:self.selectIndex] objectForKey:@"ctgryTyCd"] isEqualToString:@"007002"]) {
        [[GlobalValue sharedSingleton] setValue:@"contents"];
        
        ContentsViewController *detailViewController = [[ContentsViewController alloc] init];
        [detailViewController setDelegate:self];
        [detailViewController setCurrentTopCtgry:[menuList objectAtIndex:self.selectIndex]];
        [detailViewController setCurrentMenuIndex:self.selectIndex];
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else if ([[[menuList objectAtIndex:self.selectIndex] objectForKey:@"ctgryTyCd"] isEqualToString:@"007003"]) {
        [[GlobalValue sharedSingleton] setValue:@"education"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[menuList objectAtIndex:self.selectIndex] forKey:@"edumenulist1"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        EduListViewController *detailViewController = [[EduListViewController alloc] init];
        [detailViewController setDelegate:self];
        [detailViewController setCurrentTopCtgry:[menuList objectAtIndex:self.selectIndex]];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (void)enterFixMenu:(id)sender {
    self.selectIndex = ((UIButton *)sender).tag;
    
    [[GlobalValue sharedSingleton] setMenuIndex:((UIButton *)sender).tag];
    
    if (_selectIndex - [menuList count] == 0) {
        RepairInfoViewController *detailViewController = [[RepairInfoViewController alloc] init];
        [detailViewController setDelegate:self];
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else if (_selectIndex - [menuList count] == 1) {
        ShopInfoViewController *detailViewController = [[ShopInfoViewController alloc] init];
        [detailViewController setDelegate:self];
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else if (_selectIndex - [menuList count] == 2) {
        StockInfoViewController *detailViewController = [[StockInfoViewController alloc] init];
        [detailViewController setDelegate:self];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (void)menuIndexConnect:(NSInteger)index {
    self.selectIndex = (int)index;
    
    if (_selectIndex < [menuList count]) {
        if ([[[menuList objectAtIndex:self.selectIndex] objectForKey:@"ctgryTyCd"] isEqualToString:@"007002"]) {
            [[GlobalValue sharedSingleton] setValue:@"contents"];
            
            ContentsViewController *detailViewController = [[ContentsViewController alloc] init];
            [detailViewController setDelegate:self];
            [detailViewController setCurrentTopCtgry:[menuList objectAtIndex:self.selectIndex]];
            [detailViewController setCurrentMenuIndex:self.selectIndex];
            [self.navigationController pushViewController:detailViewController animated:NO];
        } else if ([[[menuList objectAtIndex:self.selectIndex] objectForKey:@"ctgryTyCd"] isEqualToString:@"007003"]) {
            [[GlobalValue sharedSingleton] setValue:@"education"];
            
            [[NSUserDefaults standardUserDefaults] setObject:[menuList objectAtIndex:self.selectIndex] forKey:@"edumenulist1"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            EduListViewController *detailViewController = [[EduListViewController alloc] init];
            [detailViewController setDelegate:self];
            [detailViewController setCurrentTopCtgry:[menuList objectAtIndex:self.selectIndex]];
            [self.navigationController pushViewController:detailViewController animated:NO];
        }
    } else {        
        if (_selectIndex - [menuList count] == 0) {
            RepairInfoViewController *detailViewController = [[RepairInfoViewController alloc] init];
            [detailViewController setDelegate:self];
            [self.navigationController pushViewController:detailViewController animated:NO];
        } else if (_selectIndex - [menuList count] == 1) {
            ShopInfoViewController *detailViewController = [[ShopInfoViewController alloc] init];
            [detailViewController setDelegate:self];
            [self.navigationController pushViewController:detailViewController animated:NO];
        } else if (_selectIndex - [menuList count] == 2) {
            StockInfoViewController *detailViewController = [[StockInfoViewController alloc] init];
            [detailViewController setDelegate:self];
            [self.navigationController pushViewController:detailViewController animated:NO];
        }
    }
}

- (void)doNetworkErrorProcess {
    NSLog(@"error");
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView stopLoading];
}

- (void)mainResult:(NSString *)data {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"mainResult : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDirectory = [paths objectAtIndex:0];
            self.dirPath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/%@"
                                                                            , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                                                            , [[resultsDictionary objectForKey:@"result"] objectForKey:@"ctgryId"]]];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createDirectoryAtPath:self.dirPath withIntermediateDirectories:YES attributes:nil error:nil];
            
            NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/%@/%@"
                                                                                   , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                                                                   , [[resultsDictionary objectForKey:@"result"] objectForKey:@"ctgryId"]
                                                                                   , [[resultsDictionary objectForKey:@"result"] objectForKey:@"cntntsFileLc"]]];
            
            BOOL fileExistsAtPath = [fileManager fileExistsAtPath:cachePath];
            
            if (fileExistsAtPath) {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
                    [app.loadingView stopLoading];
                } else {
//                    [app.loadingView showCntntsSet];
//                    [app.loadingView.receivedDataLbl setText:@"메인 이미지를 구성중입니다."];
                }
                
                int j = 0;
                NSMutableArray *fileList = [[NSMutableArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:self.dirPath error:nil]];
                for (int i = 0; i < [fileList count]; i++) {
                    if ([[fileList objectAtIndex:i - j] rangeOfString:@".zip"].location != NSNotFound || [[fileList objectAtIndex:i - j] rangeOfString:@"MACOSX"].location != NSNotFound) {
                        [fileList removeObjectAtIndex:i - j];
                        j++;
                    }
                }
                
                UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(152, 88, [UIScreen mainScreen].bounds.size.width - 152, 838)];//메인이미지
                [scroll setDelegate:self];
                [scroll setBackgroundColor:[UIColor clearColor]];
                [scroll setPagingEnabled:YES];
                [scroll setShowsHorizontalScrollIndicator:NO];
                [scroll setContentSize:CGSizeMake(([UIScreen mainScreen].bounds.size.width - 152) * [fileList count], 838)];
                [[self.view.subviews objectAtIndex:0] addSubview:scroll];
                
                [scrollArr replaceObjectAtIndex:0 withObject:scroll];
                
                [[[[self.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] removeFromSuperview];
                
                [((UIScrollView *)[scrollArr objectAtIndex:0]) setContentOffset:CGPointZero];
                [((UIScrollView *)[scrollArr objectAtIndex:0]) setContentSize:CGSizeMake(([UIScreen mainScreen].bounds.size.width - 152) * [fileList count], 838 - HEIGHT)];
                [((UIScrollView *)[scrollArr objectAtIndex:2]) setContentSize:CGSizeMake(93 * ([fileList count] - 1) + 94, 70)];
                
                dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void) {
                    for (int i = 0; i < [fileList count]; i++) {
                        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
                            UIImageView *mainImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", self.dirPath, [fileList objectAtIndex:i]]]];
                            [mainImg setFrame:CGRectMake(i * ([UIScreen mainScreen].bounds.size.width - 152), 0, [UIScreen mainScreen].bounds.size.width - 152, 838)];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [((UIScrollView *)[scrollArr objectAtIndex:0]) addSubview:mainImg];
                            });
                            
                            UIImageView *thumbImg = [[UIImageView alloc] initWithImage:[self resizedImage:[self cropedImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", self.dirPath, [fileList objectAtIndex:i]]] inRect:CGRectMake(29, 0, 558, 420)] inRect:CGRectMake(0, 0, 91, 68)]];
                            [thumbImg setFrame:CGRectMake(1 + (i * 93), 1, thumbImg.image.size.width, thumbImg.image.size.height)];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [((UIScrollView *)[scrollArr objectAtIndex:2]) addSubview:thumbImg];
                            });
                            
                            UIButton *thumbBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                            [thumbBtn setTag:i];
                            if (i == 0) {
                                [thumbBtn setSelected:YES];
                            } else {
                                [thumbBtn setSelected:NO];
                            }
                            [thumbBtn setImage:[UIImage imageNamed:@"IM_Main_ThumbBG"] forState:UIControlStateNormal];
                            [thumbBtn setImage:[UIImage imageNamed:@"IM_Main_ThumbSelect"] forState:UIControlStateSelected];
                            [thumbBtn setFrame:CGRectMake(i * 93 - 1, 0, 95, 70)];
                            [thumbBtn addTarget:self action:@selector(currentMainImg:) forControlEvents:UIControlEventTouchUpInside];
                            [thumbArr addObject:thumbBtn];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [((UIScrollView *)[scrollArr objectAtIndex:2]) addSubview:thumbBtn];
                            });
                        } else {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                UIImageView *mainImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", self.dirPath, [fileList objectAtIndex:i]]]];
                                [mainImg setFrame:CGRectMake(i * ([UIScreen mainScreen].bounds.size.width - 152), 0, [UIScreen mainScreen].bounds.size.width - 152, 838)];
                                
                                
                                [((UIScrollView *)[scrollArr objectAtIndex:0]) addSubview:mainImg];
//                                [scroll addSubview:mainImg];
                            });

                            dispatch_sync(dispatch_get_main_queue(), ^{
                                UIImageView *thumbImg = [[UIImageView alloc] initWithImage:[self resizedImage:[self cropedImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", self.dirPath, [fileList objectAtIndex:i]]] inRect:CGRectMake(29, 0, 558, 420)] inRect:CGRectMake(0, 0, 91, 68)]];
                                [thumbImg setFrame:CGRectMake(1 + (i * 93), 1, thumbImg.image.size.width, thumbImg.image.size.height)];
                                
                                
                                [((UIScrollView *)[scrollArr objectAtIndex:2]) addSubview:thumbImg];
                                //                            });
                                //
                                //                            dispatch_sync(dispatch_get_main_queue(), ^{
                                UIButton *thumbBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                                [thumbBtn setTag:i];
                                if (i == 0) {
                                    [thumbBtn setSelected:YES];
                                } else {
                                    [thumbBtn setSelected:NO];
                                }
                                [thumbBtn setImage:[UIImage imageNamed:@"IM_Main_ThumbBG"] forState:UIControlStateNormal];
                                [thumbBtn setImage:[UIImage imageNamed:@"IM_Main_ThumbSelect"] forState:UIControlStateSelected];
                                [thumbBtn setFrame:CGRectMake(i * 93 - 1, 0, 95, 70)];
                                [thumbBtn addTarget:self action:@selector(currentMainImg:) forControlEvents:UIControlEventTouchUpInside];
                                [thumbArr addObject:thumbBtn];
                                
                                
                                [((UIScrollView *)[scrollArr objectAtIndex:2]) addSubview:thumbBtn];
                            });
                            
                            
                            if (i == [fileList count] - 1) {
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [app.loadingView stopLoading];
                                });
                            }
                        }
                    }
                });
            } else {
                NSError *error = nil;
                
                NSArray *contestsArr = [fileManager contentsOfDirectoryAtPath:self.dirPath error:&error];
                for (int i = 0; i < [contestsArr count]; i++) {
                    [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", self.dirPath, [contestsArr objectAtIndex:i]] error:&error];
                }
                
                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[resultsDictionary objectForKey:@"result"] objectForKey:@"dwldCntntsPath"]]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    
                    BOOL success = [data writeToFile:cachePath atomically:YES];
                    if (success) {
                        [self unzip:cachePath withPath:self.dirPath];
                    } else {
                        
                    }
                }];
            }
        } else if ([result isEqualToString:@"401.1"]) {//인증오류
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.100"]) {//인증오류_FA
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.101"]) {//단말 미등록
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.102"]) {//단말 미승인
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.103"]) {//단말 분실
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDirectory = [paths objectAtIndex:0];
            NSString *dir = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce"]];
            
            NSError *error = nil;
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:dir error:&error];
            
            [app logout:@"yes"];
        } else if ([result isEqualToString:@"401.104"]) {//비밀번호 5회이상 오류
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.105"]) {//요청시간 초과
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            
            [alertView show];
        }
    } else {
        [app.loadingView stopLoading];
//        [loadingView stopLoading];
    }
}

#pragma mark -  NSURLConnectionDelegate
//총 파일의 크기와 현재까지 업로드된 파일의 크기를 이 메소드를 통해서 알 수 있다. 적당히 계산해서 프로그레스바에 넣어준다.
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    //    NSLog(@"uploading %d    %d    %d",bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    //    float num = totalBytesWritten;
    //    float total = totalBytesExpectedToWrite;
    //    float percent = num/total;
    //    self.progressView.progress = percent;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSDictionary *allHeaders = [((NSHTTPURLResponse *)response) allHeaderFields];
	NSLog(@" %@", allHeaders);
    
    numberFileSize = [NSNumber numberWithLong: [response expectedContentLength] ];
    NSLog(@"Length Avaialble = %d", [numberFileSize intValue]);
    _fTot = 0;
}

//파일 업로드 완료 되었을 때
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    _fTot += (float)[data length];
    
    NSLog(@"didReceiveData == %d", [data length]);
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView.receivedDataLbl setText:[NSString stringWithFormat:@"메인 이미지를 다운로드 중입니다.\n %d / %d KB\n   ", (int)_fTot/1024, [numberFileSize intValue]/1024]];
//    [loadingView.receivedDataLbl setText:[NSString stringWithFormat:@"메인 이미지를 다운로드 중입니다.\n %d / %d KB\n   ", (int)_fTot/1024, [numberFileSize intValue]/1024]];
    
    [receivedData appendData:data];
}

//끝나면 프로그레스바가 있는 Alert을 닫아준다.
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"upload end");
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView.receivedDataLbl setText:@"메인 이미지를 구성중입니다."];
//    [loadingView.receivedDataLbl setText:@"메인 이미지를 구성중입니다."];
    
    BOOL success = [receivedData writeToFile:[[NSUserDefaults standardUserDefaults] objectForKey:@"cachePath"] atomically:YES];
    if (success) {
        [self unzip:[[NSUserDefaults standardUserDefaults] objectForKey:@"cachePath"] withPath:self.dirPath];
        receivedData = nil;
    } else {
        
    }
}

//파일 다운로드 중 실패하였을 경우
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"upload fail");
    //    [self.progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
    //                                                    message:@"파일 다운로드를 실패하였습니다."
    //                                                   delegate:self cancelButtonTitle:@"확인"
    //                                          otherButtonTitles:nil];
    //
    //    [alert show];
}

- (void)unzip:(id)zipFile withPath:(id)path {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"sender : %@", zipFile);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cachePath"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] < 7) {
        [app.loadingView stopLoading];
//        [loadingView stopLoading];
    }
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    if ([zip UnzipOpenFile:zipFile]) {
        BOOL ret = [zip UnzipFileTo:path overWrite:YES];
        if (ret) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSMutableArray *fileList = [[NSMutableArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:path error:nil]];
            int j = 0;
            for (int i = 0; i < [fileList count]; i++) {
                if ([[fileList objectAtIndex:i - j] rangeOfString:@".zip"].location != NSNotFound || [[fileList objectAtIndex:i - j] rangeOfString:@"MACOSX"].location != NSNotFound) {
                    [fileList removeObjectAtIndex:i - j];
                    j++;
                }
            }
            
            [((UIScrollView *)[scrollArr objectAtIndex:0]) setContentSize:CGSizeMake(([UIScreen mainScreen].bounds.size.width - 152) * [fileList count], 838)];
            [((UIScrollView *)[scrollArr objectAtIndex:2]) setContentSize:CGSizeMake(97 * ([fileList count] - 1) + 93, 70)];
            
            dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void) {
                
                for (int i = 0; i < [fileList count]; i++) {
                    if ([[[UIDevice currentDevice] systemVersion] intValue] < 7) {
                        UIImageView *mainImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", path, [fileList objectAtIndex:i]]]];
                        [mainImg setFrame:CGRectMake(i * ([UIScreen mainScreen].bounds.size.width - 152), 0, [UIScreen mainScreen].bounds.size.width - 152, 838)];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [((UIScrollView *)[scrollArr objectAtIndex:0]) addSubview:mainImg];
                        });
                        
                        
                        UIImageView *thumbImg = [[UIImageView alloc] initWithImage:[self resizedImage:[self cropedImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", path, [fileList objectAtIndex:i]]] inRect:CGRectMake(29, 0, 558, 420)] inRect:CGRectMake(0, 0, 91, 68)]];
                        [thumbImg setFrame:CGRectMake(2 + (i * 93), 1, thumbImg.image.size.width, thumbImg.image.size.height)];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [((UIScrollView *)[scrollArr objectAtIndex:2]) addSubview:thumbImg];
                        });
                        
                        
                        UIButton *thumbBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                        [thumbBtn setTag:i];
                        if (i == 0) {
                            [thumbBtn setSelected:YES];
                        } else {
                            [thumbBtn setSelected:NO];
                        }
                        [thumbBtn setImage:[UIImage imageNamed:@"IM_Main_ThumbBG"] forState:UIControlStateNormal];
                        [thumbBtn setImage:[UIImage imageNamed:@"IM_Main_ThumbSelect"] forState:UIControlStateSelected];
                        [thumbBtn setFrame:CGRectMake(i * 93, 0, 95, 70)];
                        [thumbBtn addTarget:self action:@selector(currentMainImg:) forControlEvents:UIControlEventTouchUpInside];
                        [thumbArr addObject:thumbBtn];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [((UIScrollView *)[scrollArr objectAtIndex:2]) addSubview:thumbBtn];
                        });
                    } else {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            UIImageView *mainImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", path, [fileList objectAtIndex:i]]]];
                            [mainImg setFrame:CGRectMake(i * ([UIScreen mainScreen].bounds.size.width - 152), 0, [UIScreen mainScreen].bounds.size.width - 152, 838)];
                            
                            
                            [((UIScrollView *)[scrollArr objectAtIndex:0]) addSubview:mainImg];
                        });
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            UIImageView *thumbImg = [[UIImageView alloc] initWithImage:[self resizedImage:[self cropedImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", path, [fileList objectAtIndex:i]]] inRect:CGRectMake(29, 0, 558, 420)] inRect:CGRectMake(0, 0, 91, 68)]];
                            [thumbImg setFrame:CGRectMake(2 + (i * 93), 1, thumbImg.image.size.width, thumbImg.image.size.height)];
                            
                            
                            [((UIScrollView *)[scrollArr objectAtIndex:2]) addSubview:thumbImg];
                            //                        });
                            //
                            //                        dispatch_sync(dispatch_get_main_queue(), ^{
                            UIButton *thumbBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                            [thumbBtn setTag:i];
                            if (i == 0) {
                                [thumbBtn setSelected:YES];
                            } else {
                                [thumbBtn setSelected:NO];
                            }
                            [thumbBtn setImage:[UIImage imageNamed:@"IM_Main_ThumbBG"] forState:UIControlStateNormal];
                            [thumbBtn setImage:[UIImage imageNamed:@"IM_Main_ThumbSelect"] forState:UIControlStateSelected];
                            [thumbBtn setFrame:CGRectMake(i * 93, 0, 95, 70)];
                            [thumbBtn addTarget:self action:@selector(currentMainImg:) forControlEvents:UIControlEventTouchUpInside];
                            [thumbArr addObject:thumbBtn];
                            
                            
                            [((UIScrollView *)[scrollArr objectAtIndex:2]) addSubview:thumbBtn];
                        });
                        
                        if (i == [fileList count] - 1) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [app.loadingView stopLoading];
//                                [loadingView stopLoading];
                            });
                        }
                    }
                }
            });
        } else {
            [app.loadingView stopLoading];
//            [loadingView stopLoading];
            //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:nil delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            //            [alertView show];
        }
    }
}

- (void)currentMainImg:(id)sender {
    for (int i = 0; i < [thumbArr count]; i++) {
        if (((UIButton *)sender).tag == i) {
            [((UIButton *)[thumbArr objectAtIndex:i]) setSelected:YES];
        } else {
            [((UIButton *)[thumbArr objectAtIndex:i]) setSelected:NO];
        }
    }
    
    [((UIScrollView *)[scrollArr objectAtIndex:0]) setContentOffset:CGPointMake(((UIButton *)sender).tag * ([UIScreen mainScreen].bounds.size.width - 152), 0) animated:YES];
}

- (UIImage *)resizedImage:(UIImage*)inImage  inRect:(CGRect)thumbRect {
    // Creates a bitmap-based graphics context and makes it the current context.
    UIGraphicsBeginImageContext(thumbRect.size);
    [inImage drawInRect:thumbRect];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (UIImage *)cropedImage:(UIImage*)inImage  inRect:(CGRect)cropRect {
    // Creates a bitmap-based graphics context and makes it the current context.
    CGImageRef imageRef = CGImageCreateWithImageInRect([inImage CGImage], cropRect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return img;
}

#pragma mark - Contents view controller delegate

- (void)viewChange:(id)sender {
    
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        if (buttonIndex != 0) {
            [self.timeTimer invalidate];
            self.timeTimer = nil;
            
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app logout:@"yes"];
        }
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 0) {
        CGFloat pageWidth = scrollView.frame.size.width;
        
        int currentPage = floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2;
        //        screenSaverCnt = currentPage;
        
        for (int i = 0; i < [thumbArr count]; i++) {
            if (currentPage - 1 == i) {
                [((UIButton *)[thumbArr objectAtIndex:i]) setSelected:YES];
            } else {
                [((UIButton *)[thumbArr objectAtIndex:i]) setSelected:NO];
            }
        }
        
        if ([thumbArr count] > 6) {
            if (([thumbArr count] - currentPage) < 6) {
                [((UIScrollView *)[scrollArr objectAtIndex:2]) setContentOffset:CGPointMake(((UIScrollView *)[scrollArr objectAtIndex:2]).contentSize.width - ((UIScrollView *)[scrollArr objectAtIndex:2]).bounds.size.width, 0) animated:YES];
            } else {
                [((UIScrollView *)[scrollArr objectAtIndex:2]) setContentOffset:CGPointMake((currentPage - 1) * 93, 0) animated:YES];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"asdf : %f", scrollView.contentOffset.y);
//    NSLog(@"asdf : %f", scrollView.contentSize.height);
//    
//    if (scrollView.tag == 0) {
//        CGFloat pageWidth = scrollView.frame.size.width;
//        
//        int currentPage = floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2;
//        //        screenSaverCnt = currentPage;
//        
//        for (int i = 0; i < [thumbArr count]; i++) {
//            if (currentPage - 1 == i) {
//                [((UIButton *)[thumbArr objectAtIndex:i]) setSelected:YES];
//            } else {
//                [((UIButton *)[thumbArr objectAtIndex:i]) setSelected:NO];
//            }
//        }
//        
//        if ([thumbArr count] > 6) {
//            if (([thumbArr count] - currentPage) < 6) {
//                [((UIScrollView *)[scrollArr objectAtIndex:2]) setContentOffset:CGPointMake(((UIScrollView *)[scrollArr objectAtIndex:2]).contentSize.width - ((UIScrollView *)[scrollArr objectAtIndex:2]).bounds.size.width, 0) animated:YES];
//            } else {
//                [((UIScrollView *)[scrollArr objectAtIndex:2]) setContentOffset:CGPointMake((currentPage - 1) * 93, 0) animated:YES];
//            }
//        }
//    }
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
