//
//  EduListViewController.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 4..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "EduListViewController.h"
//
#import "EduSubViewController.h"
//
#import "ViewType_010000.h"
#import "ViewType_010001.h"
#import "ViewType_010002.h"
#import "ViewType_010003.h"
//
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

@interface EduListViewController ()

@end

@implementation EduListViewController
@synthesize delegate;
@synthesize currentTopCtgry = _currentTopCtgry;
@synthesize currentMenuIndex = _currentMenuIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        menuList1 = [[NSMutableArray alloc] init];
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
    
    BOOL pwCheck = NO;
    for (UIView *view in self.view.subviews) {
        if (view == app.pwView) {
            pwCheck = YES;
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
    
    if (!pwCheck) {
        [app.pwView setDelegate:self];
        [app.pwView setAlpha:1.0f];
        [self.view addSubview:app.pwView];
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
    eduBgView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20)];
    [eduBgView setUserInteractionEnabled:YES];
    [eduBgView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:eduBgView];
    
    cntBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_CommonBG_01.jpg"]];
    [cntBgView setFrame:CGRectMake(0, 44, cntBgView.image.size.width, cntBgView.image.size.height)];
    [cntBgView setUserInteractionEnabled:YES];
    [eduBgView addSubview:cntBgView];
    
    menuScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 56, 1, 12)];
    [menuScroll setDelegate:self];
    [menuScroll setBackgroundColor:[UIColor clearColor]];
    [menuScroll setShowsVerticalScrollIndicator:NO];
    [menuScroll setContentSize:CGSizeZero];
    [cntBgView addSubview:menuScroll];
    
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
}

- (void)result:(NSString *)data {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"LISTEDCMENU result : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[resultsDictionary objectForKey:@"results"] forKey:@"edumenulist2"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            menuList1 = [resultsDictionary objectForKey:@"results"];
            
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
            
            [app.loadingView stopLoading];
            
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
        
    }
}

- (void)viewChange:(id)sender {
    NSLog(@"viewChange");
    
    NSString *thumbKind = @"";
    if ([[[GlobalValue sharedSingleton] value] isEqualToString:@"contents"]) {
        thumbKind = @"thumblist";
    } else {
        thumbKind = @"eduthumblist";
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:thumbKind];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
            [view setRow:4];
            [view setColums:4];
            [view setThumbW:0];
            [view setThumbH:24];
            [view setThumbWidth:187];
            [view setThumbHeight:171];
            [view setDrawItemInfo:self.currentTopCtgry];
            [view thumbListRequest:1 withTotalPage:16 withMenuIndex:0 withCtgry:2];
            [cntBgView addSubview:view];
        } else {//all 이외 모든 버튼
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
            [view setRow:4];
            [view setColums:4];
            [view setThumbW:0];
            [view setThumbH:24];
            [view setThumbWidth:187];
            [view setThumbHeight:171];
            [view setDrawItemInfo:self.currentTopCtgry];
            [view thumbListRequest:1 withTotalPage:16 withMenuIndex:((UIButton *)sender).tag withCtgry:1];
            [cntBgView addSubview:view];
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
//        NSString *thumbKind = @"";
//        if ([[[GlobalValue sharedSingleton] value] isEqualToString:@"contents"]) {
//            thumbKind = @"thumblist";
//        } else {
//            thumbKind = @"eduthumblist";
//        }
//        
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:thumbKind];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (sender == 0) {
            for (UIView *view in cntBgView.subviews) {
                if ([view isKindOfClass:[ViewType_010000 class]] || [view isKindOfClass:[ViewType_010002 class]] || [view isKindOfClass:[ViewType_010003 class]]) {
                    [view removeFromSuperview];
                }
                else if ([view isKindOfClass:[ViewType_010001 class]]) {
                    [[(ViewType_010001 *)[[cntBgView subviews] lastObject] videoView] loadHTMLString:nil baseURL:nil];
                    [view removeFromSuperview];
                }
            }
            
            ViewType_010000 *view = [[ViewType_010000 alloc] initWithFrame:CGRectMake(10, 120, 748, 820)];
            [view setDelegate:self selector:@selector(returnValue:withInfoArr:)];
            [view setRow:4];
            [view setColums:4];
            [view setThumbW:0];
            [view setThumbH:24];
            [view setThumbWidth:187];
            [view setThumbHeight:171];
            [view setDrawItemInfo:self.currentTopCtgry];
            [view thumbListRequest:1 withTotalPage:16 withMenuIndex:0 withCtgry:2];
            [cntBgView addSubview:view];
        } else {
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
            [view setRow:4];
            [view setColums:4];
            [view setThumbW:0];
            [view setThumbH:24];
            [view setThumbWidth:187];
            [view setThumbHeight:171];
            [view setDrawItemInfo:self.currentTopCtgry];
            [view thumbListRequest:1 withTotalPage:16 withMenuIndex:[sender intValue] withCtgry:1];
            [cntBgView addSubview:view];
        }
    }
}

- (void)cntntsLoadingStart:(NSString *)onoff {
    
}

- (void)cntntsLoadingStop {
    
}

#pragma mark - Password view delegate

- (void)pwCheckResult:(BOOL)result {
    if (result) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.loadingView startLoading];
        
        if ([[self.currentTopCtgry objectForKey:@"isLeaf"] intValue] == 1) {//하위 카테고리가 없으면
            [menuList1 addObject:self.currentTopCtgry];
            //        currentCtgry = self.currentTopCtgry;
            
            [[NSUserDefaults standardUserDefaults] setObject:menuList1 forKey:@"edumenulist1"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self viewChange:0];
        } else {
            NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
            NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
            NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&accessToken=%@&timestamp=%0.f"
                             , KHOST, LISTCTGYINFODATA
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                             , [[[NSUserDefaults standardUserDefaults] objectForKey:@"edumenulist1"] objectForKey:@"ctgryId"]
                             , [temp hexadecimalString]
                             , timeInMiliseconds];
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(result:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        }
    }
}

- (void)pwCheckClose:(BOOL)goPrev {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    for (UIView *view in self.view.subviews) {
        if (view == app.pwView) {
            if (goPrev) {
                [view removeFromSuperview];
//                [self.navigationController popViewControllerAnimated:YES];
                [self.navigationController popToRootViewControllerAnimated:YES];
            } else {
                [view setAlpha:0];
            }
        }
    }
}

- (void)clickedButtonAtIndex:(NSInteger)buttonIndex {
    [delegate menuIndexConnect:buttonIndex];
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

#pragma mark - (image)

- (void)loadImageView:(NSDictionary *)data withDir:(NSString *)dir {

}

#pragma mark - (image + link)

- (void)loadImageWithLinkView:(NSDictionary *)data {

}

#pragma mark - Video

- (void)loadVideoView:(NSDictionary *)data {
    eduSubViewController = [[EduSubViewController alloc] init];
    [eduSubViewController setDelegate:self];
    [eduSubViewController setThumbnailInfo:data];
    [eduSubViewController setCurrentCtgryMenuIndex:self.currentMenuIndex];
    [self.navigationController pushViewController:eduSubViewController animated:NO];
}

#pragma mark - PDF
// NSDictionary*)data
//@"filePath"
//@"title"
-(void)loadLocalPdfView:(NSDictionary*)data
{
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
