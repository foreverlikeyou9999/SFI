//
//  ContentsViewController.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 28..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "ContentsViewController.h"
//
#import "Define.h"
//
#import "AppDelegate.h"
//
#import "NavigationBar.h"
#import "ThumbnailView.h"
#import "ProductDetailView.h"
#import "ProductCell.h"
#import "httpRequest.h"
#import "CommonUtil.h"
#import "NSData+AESAdditions.h"
//
#import "ViewType_010000.h"
#import "ViewType_010001.h"
#import "ViewType_010002.h"
#import "ViewType_010003.h"
//
#import "ReaderViewController.h"
#import "ContentsSubViewController.h"

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

@interface ContentsViewController ()

@end

@implementation ContentsViewController
//@synthesize ctgryName = _ctgryName;
@synthesize currentTopCtgry = _currentTopCtgry;
@synthesize currentMenuIndex = _currentMenuIndex;
@synthesize delegate;
@synthesize loadingView = _loadingView;

#pragma mark - life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        thumbnailListArr = [[NSMutableArray alloc] init];
        btnArr = [[NSMutableArray alloc] init];
        requestArr = [[NSMutableArray alloc] init];
        //        self.currentTopCtgry = [[[NSDictionary alloc] init] autorelease];
        _currentTopCtgry = [[NSDictionary alloc] init] ;
        menuList1 = [[NSMutableArray alloc] init];
        currentCtgry = [[NSDictionary alloc] init];
        
        
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
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callLogin) name:UIApplicationDidEnterBackgroundNotification object:nil];
    adGalBgView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20)];
    [adGalBgView setUserInteractionEnabled:YES];
    [adGalBgView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:adGalBgView];
    
    cntBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_CommonBG_01.jpg"]];
    [cntBgView setFrame:CGRectMake(0, 44, cntBgView.image.size.width, cntBgView.image.size.height)];
    [cntBgView setUserInteractionEnabled:YES];
    [adGalBgView addSubview:cntBgView];
    
    menuScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 56, 1, 12)];
    [menuScroll setDelegate:self];
    [menuScroll setBackgroundColor:[UIColor clearColor]];
    [menuScroll setShowsVerticalScrollIndicator:NO];
    [menuScroll setContentSize:CGSizeZero];
    [cntBgView addSubview:menuScroll];
    
    UILabel *lbl;
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 34, 500, 40)];
    [lbl setText:[self.currentTopCtgry objectForKey:@"ctgryNm"]];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setFont:[UIFont boldSystemFontOfSize:36]];
    [cntBgView addSubview:lbl];
    
    UIImageView *titleUnderBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Img_TitleUnderBar"]];
    [titleUnderBarView setFrame:CGRectMake(20, 86, titleUnderBarView.image.size.width, titleUnderBarView.image.size.height)];
    [cntBgView addSubview:titleUnderBarView];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView showLoadingSet];
    [app.loadingView startLoading];
//    [naviBar.loadingView startLoading];
    
    _currentMenuIndex = 0;
    
    if ([[self.currentTopCtgry objectForKey:@"isLeaf"] intValue] == 1) {//하위 카테고리가 없으면
        [menuList1 addObject:self.currentTopCtgry];
        currentCtgry = self.currentTopCtgry;
        
        [[NSUserDefaults standardUserDefaults] setObject:menuList1 forKey:@"menulist1"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self viewChange:0];
    } else {
        NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
        NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
        NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&accessToken=%@&timestamp=%0.f"
                         , KHOST, LISTCTGYINFODATA
                         , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                         , [self.currentTopCtgry objectForKey:@"ctgryId"]
                         , [temp hexadecimalString]
                         , timeInMiliseconds];
        
        httpRequest *_httpRequest = [[httpRequest alloc] init];
        [_httpRequest setDelegate:self selector:@selector(result:)];
        [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    }
}


#pragma mark - private method

- (void)doNetworkErrorProcess {
    NSLog(@"error");
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView stopLoading];
//    [naviBar.loadingView stopLoading];
}

- (void)result:(NSString *)data {
    NSLog(@"data : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[resultsDictionary objectForKey:@"results"] forKey:@"menulist1"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            menuList1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"menulist1"];
            
            UIButton *btn;
            
            for (int i = 0; i < [menuList1 count] + 1; i++) {
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setTag:i];
                [btn setAdjustsImageWhenHighlighted:NO];
                
                if (i == 0) {
                    [btn setImage:[CommonUtil createNormalBtn:@"전체"] forState:UIControlStateNormal];
                    [btn setImage:[CommonUtil createHighlightBtn:@"전체"] forState:UIControlStateSelected];
                    
                    [btn setSelected:YES];
                    [btn setUserInteractionEnabled:NO];
                    [btn setFrame:CGRectMake(0, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
                } else {
                    [btn setImage:[CommonUtil createNormalBtn:[[menuList1 objectAtIndex:i - 1] objectForKey:@"ctgryNm"]] forState:UIControlStateNormal];
                    [btn setImage:[CommonUtil createHighlightBtn:[[menuList1 objectAtIndex:i - 1] objectForKey:@"ctgryNm"]] forState:UIControlStateSelected];
                    
                    [btn setSelected:NO];
                    [btn setUserInteractionEnabled:YES];
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
            
            [self viewChange:@"0"];
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
            
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.loadingView stopLoading];
//        [naviBar.loadingView stopLoading];
    }
}

//- (UIImage *)createNormalBtn:(NSString *)btnNm {
//    CGSize stringSize = CGSizeZero;
//    stringSize = [btnNm sizeWithFont:[UIFont fontWithName:@"Roboto-Bold" size:13.0f]];
//
//    UILabel *normalLbl = [[UILabel alloc] init];
//    [normalLbl setText:btnNm];
//    [normalLbl setBackgroundColor:[UIColor clearColor]];
//    [normalLbl setFont:[UIFont fontWithName:@"Roboto-Bold" size:13.0f]];
//    [normalLbl setTextColor:[UIColor whiteColor]];
//    [normalLbl setFrame:CGRectMake(13, 0, stringSize.width, stringSize.height)];
//
//    UIImageView *bulletImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_TabBullet_N"] highlightedImage:[UIImage imageNamed:@"IM_Sub_TabBullet_O"]];
//    [bulletImg setFrame:CGRectMake(0, 5, bulletImg.image.size.width, bulletImg.image.size.width)];
//    [bulletImg setHighlighted:NO];
//
//    UIView *normal = [[UIView alloc] initWithFrame:CGRectMake(0, 0, stringSize.width + 13, stringSize.height*2)];
//    [normal setBackgroundColor:[UIColor clearColor]];
//    [normal addSubview:bulletImg];
//    [normal addSubview:normalLbl];
//
//    return [CommonUtil imageWithView:normal];
//}
//
//- (UIImage *)createHighlightBtn:(NSString *)btnNm {
//    CGSize stringSize = CGSizeZero;
//    stringSize = [btnNm sizeWithFont:[UIFont fontWithName:@"Roboto-Bold" size:13.0f]];
//
//    UILabel *highlightLbl = [[UILabel alloc] init];
//    [highlightLbl setText:btnNm];
//    [highlightLbl setBackgroundColor:[UIColor clearColor]];
//    [highlightLbl setFont:[UIFont fontWithName:@"Roboto-Bold" size:13.0f]];
//    [highlightLbl setTextColor:[UIColor colorWithRed:244/255.0f green:89/255.0f blue:71/255.0f alpha:1]];
//    [highlightLbl setFrame:CGRectMake(13, 0, stringSize.width, stringSize.height)];
//
//    UIImageView *bulletImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_TabBullet_N"] highlightedImage:[UIImage imageNamed:@"IM_Sub_TabBullet_O"]];
//    [bulletImg setFrame:CGRectMake(0, 5, bulletImg.image.size.width, bulletImg.image.size.width)];
//    [bulletImg setHighlighted:YES];
//
//    UIView *highlight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, stringSize.width + 13, stringSize.height*2)];
//    [highlight setBackgroundColor:[UIColor clearColor]];
//    [highlight addSubview:bulletImg];
//    [highlight addSubview:highlightLbl];
//
//    return [CommonUtil imageWithView:highlight];
//}

- (void)returnValue:(NSString *)data withTitle:(NSString *)title {
    NSLog(@"return value : %@, %@", data, title);
}

- (void)returnValue:(NSString *)ctgryCd withInfoArr:(NSDictionary *)infoArr {
    NSLog(@"return value crgrycd&infoarr : %@, %@", ctgryCd, infoArr);
    
    for (int i = 0; i < [menuList1 count] + 1; i++) {
        if (i == self.currentMenuIndex) {
            [(UIButton *)[btnArr objectAtIndex:i] setSelected:YES];
            [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:NO];
        } else {
            [(UIButton *)[btnArr objectAtIndex:i] setSelected:NO];
            [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:YES];
        }
    }
    
    if ([[[cntBgView subviews] lastObject] isKindOfClass:[ViewType_010001 class]]) {
        [[(ViewType_010001 *)[[cntBgView subviews] lastObject] videoView] loadHTMLString:nil baseURL:nil];
        [[[cntBgView subviews] lastObject] removeFromSuperview];
    } else {
        [[[cntBgView subviews] lastObject] removeFromSuperview];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thumblist"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    ViewType_010003 *view = [[ViewType_010003 alloc] initWithFrame:CGRectMake(10, 120, 748, 820)];
    [view setAutoSelect:NO];
    [view setDelegate:self selector:@selector(detailProductDismiss)];
    [view setDrawItemInfo:self.currentTopCtgry];
    for (int i = 0; i < [menuList1 count]; i++) {
        if ([[[menuList1 objectAtIndex:i] objectForKey:@"ctgryNm"] isEqualToString:[infoArr objectForKey:@"ctgryNm"]]) {
            [view setDep1menuIndex:i];
            
            [(UIButton *)[btnArr objectAtIndex:i + 1] setSelected:YES];
            [(UIButton *)[btnArr objectAtIndex:i + 1] setUserInteractionEnabled:NO];
            
            [view thumbListRequest:1 withTotalPage:4 withMenuIndex:i withCtgry:1];
            
            for (int j = 0; j < [menuList1 count] + 1; j++) {
                if (j != i + 1) {
                    [(UIButton *)[btnArr objectAtIndex:j] setSelected:NO];
                    [(UIButton *)[btnArr objectAtIndex:j] setUserInteractionEnabled:YES];
                }
            }
        }
    }
    
    [cntBgView addSubview:view];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [view returnValue:ctgryCd withThumbInfo:infoArr];
    });
}

- (void)viewChange:(id)sender {
    NSLog(@"viewChange");
    
    if ([sender isKindOfClass:[UIButton class]]) {
        self.currentMenuIndex = ((UIButton *)sender).tag;
        
        for (int i = 0; i < [menuList1 count] + 1; i++) {
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
                if ([view isKindOfClass:[ViewType_010000 class]] || [view isKindOfClass:[ViewType_010002 class]] || [view isKindOfClass:[ViewType_010003 class]]) {
                    [view removeFromSuperview];
                } else if ([view isKindOfClass:[ViewType_010001 class]]) {
                    [[(ViewType_010001 *)[[cntBgView subviews] lastObject] videoView] loadHTMLString:nil baseURL:nil];
                    [view removeFromSuperview];
                }
            }
            
            
            ViewType_010000 *view = [[ViewType_010000 alloc] initWithFrame:CGRectMake(10, 120, 748, 820)];
            [view setDelegate:self selector:@selector(returnValue:withInfoArr:)];
            
            if ([[self.currentTopCtgry objectForKey:@"scrinTyCd"] isEqualToString:@"010001"]) {
                [view setRow:5];
                [view setColums:5];
                [view setThumbW:2];
                [view setThumbH:2];
                [view setThumbWidth:148];
                [view setThumbHeight:148];
                [view setDrawItemInfo:self.currentTopCtgry];
                [view thumbListRequest:1 withTotalPage:25 withMenuIndex:0 withCtgry:2];
            } else if ([[self.currentTopCtgry objectForKey:@"scrinTyCd"] isEqualToString:@"010002"]) {
                [view setRow:4];
                [view setColums:4];
                [view setThumbW:0];
                [view setThumbH:24];
                [view setThumbWidth:187];
                [view setThumbHeight:171];
                [view setDrawItemInfo:self.currentTopCtgry];
                [view thumbListRequest:1 withTotalPage:16 withMenuIndex:0 withCtgry:2];
            } else if ([[self.currentTopCtgry objectForKey:@"scrinTyCd"] isEqualToString:@"010003"]) {
                [view setRow:4];
                [view setColums:4];
                [view setThumbW:0];
                [view setThumbH:24];
                [view setThumbWidth:187];
                [view setThumbHeight:171];
                [view setDrawItemInfo:self.currentTopCtgry];
                [view thumbListRequest:1 withTotalPage:16 withMenuIndex:0 withCtgry:2];
            } else if ([[self.currentTopCtgry objectForKey:@"scrinTyCd"] isEqualToString:@"010004"]) {
                [view setRow:3];
                [view setColums:2];
                [view setThumbW:22];
                [view setThumbH:36];
                [view setThumbWidth:361];
                [view setThumbHeight:205];
                [view setDrawItemInfo:self.currentTopCtgry];
                [view thumbListRequest:1 withTotalPage:6 withMenuIndex:0 withCtgry:2];
            } else {
                
            }
            [cntBgView addSubview:view];
        } else {//all 이외 모든 버튼
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thumblist"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            for (UIView *view in cntBgView.subviews) {
                if ([view isKindOfClass:[ViewType_010000 class]] || [view isKindOfClass:[ViewType_010002 class]] || [view isKindOfClass:[ViewType_010003 class]]) {
                    [view removeFromSuperview];
                } else if ([view isKindOfClass:[ViewType_010001 class]]) {
                    [[(ViewType_010001 *)[[cntBgView subviews] lastObject] videoView] loadHTMLString:nil baseURL:nil];
                    [view removeFromSuperview];
                }
            }
            
            if ([[[menuList1 objectAtIndex:((UIButton *)sender).tag - 1] objectForKey:@"scrinTyCd"] isEqualToString:@"010001"]) {
                ViewType_010000 *view = [[ViewType_010000 alloc] initWithFrame:CGRectMake(10, 120, 748, 820)];
                [view setDelegate:self selector:@selector(returnValue:withInfoArr:)];
                [view setRow:5];
                [view setColums:5];
                [view setThumbW:2];
                [view setThumbH:2];
                [view setThumbWidth:148];
                [view setThumbHeight:148];
                [view setDrawItemInfo:self.currentTopCtgry];
                [view thumbListRequest:1 withTotalPage:25 withMenuIndex:((UIButton *)sender).tag withCtgry:1];
                [cntBgView addSubview:view];
            } else if ([[[menuList1 objectAtIndex:((UIButton *)sender).tag - 1] objectForKey:@"scrinTyCd"] isEqualToString:@"010002"]) {
                ViewType_010000 *view = [[ViewType_010000 alloc] initWithFrame:CGRectMake(10, 120, 748, 820)];
                [view setDelegate:self selector:@selector(returnValue:withInfoArr:)];
                [view setRow:4];
                [view setColums:4];
                [view setThumbW:0];
                [view setThumbH:24];
                [view setThumbWidth:187];
                [view setThumbHeight:171];
                [view setDrawItemInfo:self.currentTopCtgry];
                [view thumbListRequest:1 withTotalPage:16 withMenuIndex:((UIButton *)sender).tag withCtgry:1];
                [cntBgView addSubview:view];
            } else if ([[[menuList1 objectAtIndex:((UIButton *)sender).tag - 1] objectForKey:@"scrinTyCd"] isEqualToString:@"010003"]) {
                ViewType_010000 *view = [[ViewType_010000 alloc] initWithFrame:CGRectMake(10, 120, 748, 820)];
                [view setDelegate:self selector:@selector(returnValue:withInfoArr:)];
                [view setRow:4];
                [view setColums:4];
                [view setThumbW:0];
                [view setThumbH:24];
                [view setThumbWidth:187];
                [view setThumbHeight:171];
                [view setDrawItemInfo:[menuList1 objectAtIndex:((UIButton *)sender).tag - 1]];
                [view thumbListRequest:1 withTotalPage:16 withMenuIndex:((UIButton *)sender).tag withCtgry:1];
                [cntBgView addSubview:view];
            } else if ([[[menuList1 objectAtIndex:((UIButton *)sender).tag - 1] objectForKey:@"scrinTyCd"] isEqualToString:@"010004"]) {
                ViewType_010000 *view = [[ViewType_010000 alloc] initWithFrame:CGRectMake(10, 120, 748, 820)];
                [view setDelegate:self selector:@selector(returnValue:withInfoArr:)];
                [view setRow:3];
                [view setColums:2];
                [view setThumbW:22];
                [view setThumbH:36];
                [view setThumbWidth:361];
                [view setThumbHeight:205];
                [view setDrawItemInfo:self.currentTopCtgry];
                [view thumbListRequest:1 withTotalPage:6 withMenuIndex:((UIButton *)sender).tag withCtgry:1];
                [cntBgView addSubview:view];
            } else {
                
            }
        }
    } else {
        if ([menuList1 count] != 1) {
            for (int i = 0; i < [menuList1 count] + 1; i++) {
                if (i == 0) {
                    [(UIButton *)[btnArr objectAtIndex:i] setSelected:YES];
                    [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:NO];
                } else {
                    [(UIButton *)[btnArr objectAtIndex:i] setSelected:NO];
                    [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:YES];
                }
            }
        }
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thumblist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        for (UIView *view in cntBgView.subviews) {
            if ([view isKindOfClass:[ViewType_010000 class]] || [view isKindOfClass:[ViewType_010002 class]] || [view isKindOfClass:[ViewType_010003 class]]) {
                [view removeFromSuperview];
            } else if ([view isKindOfClass:[ViewType_010001 class]]) {
                [[(ViewType_010001 *)[[cntBgView subviews] lastObject] videoView] loadHTMLString:nil baseURL:nil];
                [view removeFromSuperview];
            }
        }
        
        ViewType_010000 *view = [[ViewType_010000 alloc] initWithFrame:CGRectMake(10, 120, 748, 820)];
        [view setDelegate:self selector:@selector(returnValue:withInfoArr:)];
        
        if ([[self.currentTopCtgry objectForKey:@"scrinTyCd"] isEqualToString:@"010001"]) {
            [view setRow:5];
            [view setColums:5];
            [view setThumbW:2];
            [view setThumbH:2];
            [view setThumbWidth:148];
            [view setThumbHeight:148];
            [view setDrawItemInfo:self.currentTopCtgry];
            [view thumbListRequest:1 withTotalPage:25 withMenuIndex:0 withCtgry:2];
        } else if ([[self.currentTopCtgry objectForKey:@"scrinTyCd"] isEqualToString:@"010002"]) {
            [view setRow:4];
            [view setColums:4];
            [view setThumbW:0];
            [view setThumbH:24];
            [view setThumbWidth:187];
            [view setThumbHeight:171];
            [view setDrawItemInfo:self.currentTopCtgry];
            [view thumbListRequest:1 withTotalPage:16 withMenuIndex:0 withCtgry:2];
        } else if ([[self.currentTopCtgry objectForKey:@"scrinTyCd"] isEqualToString:@"010003"]) {
            [view setRow:4];
            [view setColums:4];
            [view setThumbW:0];
            [view setThumbH:24];
            [view setThumbWidth:187];
            [view setThumbHeight:171];
            [view setDrawItemInfo:self.currentTopCtgry];
            [view thumbListRequest:1 withTotalPage:16 withMenuIndex:0 withCtgry:2];
        } else if ([[self.currentTopCtgry objectForKey:@"scrinTyCd"] isEqualToString:@"010004"]) {
            [view setRow:3];
            [view setColums:2];
            [view setThumbW:22];
            [view setThumbH:36];
            [view setThumbWidth:361];
            [view setThumbHeight:205];
            [view setDrawItemInfo:self.currentTopCtgry];
            [view thumbListRequest:1 withTotalPage:6 withMenuIndex:0 withCtgry:2];
        } else {
            
        }
        [cntBgView addSubview:view];
    }
}

- (void)goHome {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)detailProduct:(id)sender {
    
    if(sender == nil)
        return;
    
    ProductDetailView *productDV = [[ProductDetailView alloc] initWithProductCd:sender];
    [productDV setDelegate:self selector:@selector(detailProductDismiss)];
    [self.view addSubview:productDV];
}

- (void)detailProductDismiss {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[ProductDetailView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)cntntsLoadingStart:(NSString *)sort {//로딩화면 생성 sort - network, cntnts 구분
//    [naviBar.loadingView startLoading];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView startLoading];
}

- (void)cntntsLoadingStop {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView stopLoading];
//    [naviBar.loadingView stopLoading];
}

- (void)callLogin {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    [app logout:@"no"];
    [readerViewController presentViewController:app.navigationC2 animated:NO completion:nil];
}

- (void)thumbnailTouchOnOff:(NSString *)onoff {
    NSLog(@"contentsviewcontroller - onoff : %@", onoff);
    if ([onoff isEqualToString:@"off"]) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.loadingView startLoading];
//        [naviBar.loadingView startLoading];
        [[cntBgView.subviews lastObject] setUserInteractionEnabled:NO];
    } else {
        
    }
}

- (void)clickedButtonAtIndex:(NSInteger)buttonIndex {
    [delegate menuIndexConnect:buttonIndex];
}

#pragma mark - NavigationBar view delegate

- (void)goPrev {
    //    [(httpRequest *)[requestArr objectAtIndex:0] requestCancel];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)goHome:(NavigationBar*) naviBar {
    [self goPrev];
}

- (void)clickedMobileMenuBtnAtIndex:(NSInteger)buttonIndex {
    [delegate menuIndexConnect:buttonIndex];
}

- (void)clickedFixedMenuBtnAtIndex:(NSInteger)buttonIndex {
    [delegate menuIndexConnect:buttonIndex];
}

- (void)requestSubCategry {
    
    
}

#pragma mark - Thumbnail view delegate

- (void)clickedThumbnail:(ThumbnailView*)view {
    
}

#pragma mark - Contents subview controller delegate

- (void)nextPageLoading:(int)currentPage {
    
}

#pragma mark - (image)

//- (void)loadLookBookView:(NSDictionary *)data withDir:(NSString *)dir {
- (void)loadImageView:(NSDictionary *)data withDir:(NSString *)dir {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView stopLoading];
//    [naviBar.loadingView stopLoading];
    
    cntntsSubViewController = [[ContentsSubViewController alloc] init];
    [cntntsSubViewController setDelegate:self];
    [cntntsSubViewController setCtgryInfo:_currentTopCtgry];
    [cntntsSubViewController setThumbnailInfo:data];
    [cntntsSubViewController setRootDir:dir];
    [cntntsSubViewController setFirstCtgryIndex:_currentMenuIndex];
    //    [self presentViewController:cntntsSubViewController animated:NO completion:nil];
    [self.navigationController pushViewController:cntntsSubViewController animated:NO];
}

#pragma mark - (image + link)

//- (void)loadPromotionView:(NSDictionary *)data {
- (void)loadImageWithLinkView:(NSDictionary *)data {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView stopLoading];
//    [naviBar.loadingView stopLoading];
    
    cntntsSubViewController = [[ContentsSubViewController alloc] init];
    [cntntsSubViewController setDelegate:self];
    [cntntsSubViewController setCtgryInfo:_currentTopCtgry];
    [cntntsSubViewController setThumbnailInfo:data];
    //    [self presentViewController:cntntsSubViewController animated:NO completion:nil];
    [self.navigationController pushViewController:cntntsSubViewController animated:NO];
}

#pragma mark - Video

- (void)loadVideoView:(NSDictionary *)data {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView stopLoading];
//    [naviBar.loadingView stopLoading];
    
    cntntsSubViewController = [[ContentsSubViewController alloc] init];
    [cntntsSubViewController setDelegate:self];
    //    [cntntsSubViewController setCtgryInfo:[menuList1 objectAtIndex:0]];
    [cntntsSubViewController setCtgryInfo:_currentTopCtgry];
    [cntntsSubViewController setThumbnailInfo:data];
    [cntntsSubViewController setFirstCtgryIndex:_currentMenuIndex];
    //    [self presentViewController:cntntsSubViewController animated:NO completion:nil];
    [self.navigationController pushViewController:cntntsSubViewController animated:NO];
}

#pragma mark - PDF
// NSDictionary*)data
//@"filePath"
//@"title"
-(void)loadLocalPdfView:(NSDictionary*)data
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView stopLoading];
//    [naviBar.loadingView stopLoading];
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    if (data == nil) {
        return;
    }
    
#if 0   // FOR TEST
    NSString *fileName = @"CPMAG_PDF132.pdf";
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileName lastPathComponent] ofType:nil inDirectory:[fileName stringByDeletingLastPathComponent]];
#endif
    
    NSString *filePath = [ContentManager getLocalFilePath:[data objectForKey:@"cntntsFileLc"] TARGET:SAVE_PDF];
    NSString *title = [data objectForKey:@"cntntsCn"];
    NSString *contentID = [data objectForKey:@"cntntsId"];
    BOOL isDel = [[data objectForKey:@"dwldYn"] isEqualToString:DOWNLOAD_FLAG_NO];
    
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    ReaderDocument *document = [[ReaderDocument alloc] initWithFilePath:filePath password:phrase];
    
	if (document != nil) // Must have a valid ReaderDocument object in order to proceed
	{
        //		ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        readerViewController.title = title;
        readerViewController.contentsID = contentID;
        readerViewController.isDelete = isDel;
		readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
        
		[self.navigationController pushViewController:readerViewController animated:YES];
        
        
#else // present in a modal view controller
        
        //        [[NSUserDefaults standardUserDefaults] setObject:@"pdfview" forKey:@"viewstatus"];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //		readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //		readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        //		[self presentModalViewController:readerViewController animated:YES];
        [self presentViewController:readerViewController animated:NO completion:nil];
        
#endif // DEMO_VIEW_CONTROLLER_PUSH
        
        
        // Release the ReaderViewController
	}
}

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
    
	[self.navigationController popViewControllerAnimated:YES];
    
#else // dismiss the modal view controller
    
    //   	[self dismissModalViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
    
#endif // DEMO_VIEW_CONTROLLER_PUSH
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
