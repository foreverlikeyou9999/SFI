//
//  ContentsSubViewController.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 9. 11..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "ContentsSubViewController.h"
//
#import "ProductDetailView.h"
#import "ProductCell.h"
#import "ViewType_010003.h"
#import "ThumbnailView.h"
//
#import "UIImageView+WebCache.h"
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

@interface ContentsSubViewController ()

@end

@implementation ContentsSubViewController
@synthesize delegate;
@synthesize ctgryInfo = _ctgryInfo;
@synthesize thumbnailInfo = _thumbnailInfo;
@synthesize rootDir = _rootDir;
@synthesize listData = _listData;
@synthesize firstCtgryIndex = _firstCtgryIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        thumbDic = [[NSDictionary alloc] init];
        btnArr = [[NSMutableArray alloc] init];
        menuList1 = [[NSMutableArray alloc] init];
        
        productRequest = [[httpRequest alloc] init];
        
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
    
    if (!videoFullScreen) {
//        [view010003.videoView loadHTMLString:nil baseURL:nil];
        [view010003 webviewDelete];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    cntBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_CommonBG_01.jpg"]];
    [cntBgView setFrame:CGRectMake(0, 44 + HEIGHT, cntBgView.image.size.width, cntBgView.image.size.height)];
    [cntBgView setUserInteractionEnabled:YES];
    [self.view addSubview:cntBgView];
    
    //    NSLog(@"list : %@", [NSKeyedUnarchiver unarchiveObjectWithData:[[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] objectForKey:@"page1"]]);
    //    NSLog(@"thumbnanil info : %@", self.thumbnailInfo);
    thumbDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"];
    
    if ([[_ctgryInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010001"]) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.naviBar createSubCntntsComponent];
        
        self.listData = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"productslist"]];
        //        aScrollview : look book 컨텐츠 스크롤
        aScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, cntBgView.image.size.width, cntBgView.image.size.height)];
        [aScrollView setTag:10001];
        [aScrollView setDelegate:self];
        [aScrollView setBackgroundColor:[UIColor clearColor]];
        [aScrollView setShowsVerticalScrollIndicator:NO];
        [aScrollView setPagingEnabled:YES];
        [aScrollView setContentSize:CGSizeMake(cntBgView.image.size.width * [[[[NSKeyedUnarchiver unarchiveObjectWithData:[thumbDic objectForKey:@"page1"]] objectForKey:@"pagingProperty"] objectForKey:@"countItem"] intValue], cntBgView.image.size.height)];
        [cntBgView addSubview:aScrollView];
        
        //        productBg : 제품 리스트 호출 버튼 & 제품 리스트 뷰의 백그라운드
        productBg = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 36, 0, 318, cntBgView.image.size.height)];
        [productBg setBackgroundColor:[UIColor clearColor]];
        [cntBgView addSubview:productBg];
        
        headerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [headerBtn setImage:[UIImage imageNamed:@"PDF_ProductListTitle"] forState:UIControlStateNormal];
        [headerBtn setImage:[UIImage imageNamed:@"PDF_ProductListTitle02"] forState:UIControlStateSelected];
        [headerBtn setSelected:NO];
        [headerBtn setFrame:CGRectMake(0, 0, headerBtn.imageView.image.size.width, headerBtn.imageView.image.size.height)];
        [headerBtn addTarget:self action:@selector(clickIndex:) forControlEvents:UIControlEventTouchUpInside];
        [productBg addSubview:headerBtn];
        
        UIImageView *productListBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PDF_ProductListBG"]];
        [productListBg setUserInteractionEnabled:YES];
        [productListBg setFrame:CGRectMake(36, 0, productListBg.image.size.width, cntBgView.image.size.height)];
        [productBg addSubview:productListBg];
        
        productListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, productListBg.image.size.width, cntBgView.image.size.height)];
        [productListView setBackgroundColor:[UIColor clearColor]];
        [productListView setDelegate:self];
        [productListView setDataSource:self];
        [productListView setRowHeight:90.0f];
        [productListView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [productListBg addSubview:productListView];
        
        if ([thumbDic count] == 1) {
            NSDictionary *lbkDic = [NSDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:[[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] objectForKey:@"page1"]]];
            
            
            for (int j = 0; j < [[lbkDic objectForKey:@"list"] count]; j++) {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *cachesDirectory = [paths objectAtIndex:0];
                NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/%@/%@/%@"
                                                                                       , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                                                                       , _rootDir
                                                                                       , [[[lbkDic objectForKey:@"list"] objectAtIndex:j] objectForKey:@"cntntsId"]
                                                                                       , [[[lbkDic objectForKey:@"list"] objectAtIndex:j] objectForKey:@"cntntsFileLc"]]];
                
                UIImageView *lookbookCntnts = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:cachePath]];
                [lookbookCntnts setFrame:CGRectMake((cntBgView.image.size.width * j) + (cntBgView.image.size.width/2 - lookbookCntnts.image.size.width/2), cntBgView.image.size.height/2 - lookbookCntnts.image.size.height/2, lookbookCntnts.image.size.width, lookbookCntnts.image.size.height)];
                [aScrollView addSubview:lookbookCntnts];
                
                if ([[[[lbkDic objectForKey:@"list"] objectAtIndex:j] objectForKey:@"cntntsId"] isEqualToString:[_thumbnailInfo objectForKey:@"cntntsId"]]) {
                    [aScrollView setContentOffset:CGPointMake(cntBgView.image.size.width * j, 0)];
                }
            }
            
        } else {
            for (int i = 0; i < [thumbDic count]; i++) {
                id key = [NSString stringWithFormat:@"page%d", i + 1];
                
                NSDictionary *lbkDic = [NSDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:[[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] objectForKey:key]]];
                
                
                
                for (int j = 0; j < [[lbkDic objectForKey:@"list"] count]; j++) {
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSString *cachesDirectory = [paths objectAtIndex:0];
                    NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/%@/%@/%@"
                                                                                           , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                                                                           , _rootDir
                                                                                           , [[[lbkDic objectForKey:@"list"] objectAtIndex:j] objectForKey:@"cntntsId"]
                                                                                           , [[[lbkDic objectForKey:@"list"] objectAtIndex:j] objectForKey:@"cntntsFileLc"]]];
                    
                    UIImageView *lookbookCntnts = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:cachePath]];
                    [lookbookCntnts setFrame:CGRectMake((i * (25 * cntBgView.image.size.width)) + (cntBgView.image.size.width * j) + (cntBgView.image.size.width/2 - lookbookCntnts.image.size.width/2), cntBgView.image.size.height/2 - lookbookCntnts.image.size.height/2, lookbookCntnts.image.size.width, lookbookCntnts.image.size.height)];
                    [aScrollView addSubview:lookbookCntnts];
                    
                    if ([[[[lbkDic objectForKey:@"list"] objectAtIndex:j] objectForKey:@"cntntsId"] isEqualToString:[_thumbnailInfo objectForKey:@"cntntsId"]]) {
                        [aScrollView setContentOffset:CGPointMake(cntBgView.image.size.width * (j + (i * 25)), 0)];
                    }
                }
            }
        }
        
//        loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, productListBg.image.size.width, cntBgView.image.size.height)];
//        [productListBg addSubview:loadingView];
    } else if ([[_ctgryInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010002"]) {
        
    } else if ([[_ctgryInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010003"]) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.naviBar createComponents];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreen:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreen:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
        
        UILabel *lbl;
        
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 34, 500, 40)];
        [lbl setText:[_ctgryInfo objectForKey:@"ctgryNm"]];
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
        
        menuList1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"menulist1"];
        
        UIButton *btn;
        
        for (int i = 0; i < [menuList1 count] + 1; i++) {
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
                [btn setImage:[CommonUtil createNormalBtn:[[menuList1 objectAtIndex:i - 1] objectForKey:@"ctgryNm"]] forState:UIControlStateNormal];
                [btn setImage:[CommonUtil createHighlightBtn:[[menuList1 objectAtIndex:i - 1] objectForKey:@"ctgryNm"]] forState:UIControlStateSelected];
                
                if (_firstCtgryIndex == 0) {
                    if ([[_thumbnailInfo objectForKey:@"ctgryNm"] isEqualToString:[NSString stringWithFormat:@"%@", [[menuList1 objectAtIndex:i - 1] objectForKey:@"ctgryNm"]]]) {
                        [btn setSelected:YES];
                        [btn setUserInteractionEnabled:NO];
                        
                        view010003 = [[ViewType_010003 alloc] initWithFrame:CGRectMake(10, 120, 748, 820)];
                        [view010003 setDep1menuIndex:i - 1];
                        [view010003 setDelegate:self selector:@selector(detailProductDismiss)];
                        [view010003 thumbListRequest:1 withTotalPage:4 withMenuIndex:i - 1 withCtgry:1];
                        [view010003 setDrawItemInfo:[menuList1 objectAtIndex:i - 1]];
                        [view010003 returnValue:nil withThumbInfo:_thumbnailInfo];
                        [cntBgView addSubview:view010003];
                    } else {
                        [btn setSelected:NO];
                        [btn setUserInteractionEnabled:YES];
                    }
                } else {
                    if (_firstCtgryIndex == i) {
                        [btn setSelected:YES];
                        [btn setUserInteractionEnabled:NO];
                        
                        view010003 = [[ViewType_010003 alloc] initWithFrame:CGRectMake(10, 120, 748, 820)];
                        [view010003 setDep1menuIndex:_firstCtgryIndex - 1];
                        [view010003 setDelegate:self selector:@selector(detailProductDismiss)];
                        [view010003 thumbListRequest:1 withTotalPage:4 withMenuIndex:_firstCtgryIndex - 1 withCtgry:1];
                        [view010003 setDrawItemInfo:[menuList1 objectAtIndex:_firstCtgryIndex - 1]];
                        [view010003 returnValue:nil withThumbInfo:_thumbnailInfo];
                        [cntBgView addSubview:view010003];
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
        
        if ([[_thumbnailInfo objectForKey:@"cntntsTyCd"] isEqualToString:@"008001"]) {
            
        } else if ([[_thumbnailInfo objectForKey:@"cntntsTyCd"] isEqualToString:@"008002"]) {
            
        } else {
            
        }
    } else if ([[_ctgryInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010004"]) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.naviBar createSubCntntsComponent];
        
//        loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, cntBgView.image.size.width, cntBgView.image.size.height)];
//        [cntBgView addSubview:loadingView];
//        [loadingView startLoading];
        
        [app.loadingView showLoadingSet];
        [app.loadingView startLoading];
        
        aScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, cntBgView.image.size.width, cntBgView.image.size.height)];
        [aScrollView setTag:10004];
        [aScrollView setDelegate:self];
        [aScrollView setBackgroundColor:[UIColor clearColor]];
        [aScrollView setShowsVerticalScrollIndicator:NO];
        [cntBgView addSubview:aScrollView];
        
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_thumbnailInfo objectForKey:@"dwldCntntsPath"]]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
            if ([_thumbnailInfo objectForKey:@"linkUrl"] == [NSNull null]) {
                [btn setAdjustsImageWhenHighlighted:NO];
            }
            [btn setFrame:CGRectMake(cntBgView.image.size.width/2 - btn.imageView.image.size.width/2, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
            [btn addTarget:self action:@selector(goWeb) forControlEvents:UIControlEventTouchUpInside];
            [aScrollView addSubview:btn];
            
            [aScrollView setContentSize:CGSizeMake(cntBgView.image.size.width, btn.imageView.image.size.height + 100)];
            
//            [loadingView stopLoading];
            [app.loadingView stopLoading];
        }];
    } else {
        
    }
}

- (void)goWeb {
    if ([_thumbnailInfo objectForKey:@"linkUrl"] != [NSNull null]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:@"링크페이지가 존재합니다.\n이동하시겠습니까?" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
        [alertView setTag:8005];
        [alertView show];
    }
}

- (void)clickIndex:(id)sender {
    ((UIButton *)sender).selected = !((UIButton *)sender).selected;
    
    if (((UIButton *)sender).selected) {
        [UIView animateWithDuration:0.5f animations:^{
            [productBg setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - productBg.frame.size.width, 0, 318, cntBgView.image.size.height)];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [UIView animateWithDuration:0.5f animations:^{
            [productBg setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 36, 0, 318, cntBgView.image.size.height)];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)viewChange:(id)sender {
    for (int i = 0; i < [menuList1 count] + 1; i++) {
        if (((UIButton *)sender).tag == i) {
            [(UIButton *)[btnArr objectAtIndex:i] setSelected:YES];
            [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:NO];
        } else {
            [(UIButton *)[btnArr objectAtIndex:i] setSelected:NO];
            [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:YES];
        }
    }
    
    [[self.navigationController.viewControllers objectAtIndex:1] viewChange:sender];
    [self goPrev];
}

- (void)cntntsLoadingStart:(NSString *)sort {//로딩화면 생성 sort - network, cntnts 구분
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView startLoading];
//    [naviBar.loadingView startLoading];
}

- (void)cntntsLoadingStop {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView stopLoading];
//    [naviBar.loadingView stopLoading];
}

- (void)detailProduct:(id)sender {
    
    if(sender == nil)
        return;
    
    ProductDetailView *productDV = [[ProductDetailView alloc] initWithProductCd:sender];
    [productDV setDelegate:self selector:@selector(detailProductDismiss)];
    [self.view addSubview:productDV];
}

- (void)thumbnailTouchOnOff:(NSString *)onoff {
    NSLog(@"contentsviewcontroller - onoff : %@", onoff);
    if ([onoff isEqualToString:@"off"]) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.loadingView startLoading];
//        [naviBar.loadingView startLoading];
//        [[cntBgView.subviews lastObject] setUserInteractionEnabled:NO];
    } else {
        
    }
}

#pragma mark - Thumbnail view delegate

- (void)clickedThumbnail:(ThumbnailView*)view {
    NSLog(@"cntnts sub view thumb");
    if (view == nil) {
        return;
    }
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView stopLoading];
//    [naviBar.loadingView stopLoading];
    
//    view010003.autoSelect = NO;
    [view010003 returnValue:nil withThumbInfo:view.thumbnailDic];
}

#pragma mark - Navigation bar delegate

- (void)clickedMobileMenuBtnAtIndex:(NSInteger)buttonIndex {
    [delegate clickedButtonAtIndex:buttonIndex];
}

- (void)clickedFixedMenuBtnAtIndex:(NSInteger)buttonIndex {
    [delegate clickedButtonAtIndex:buttonIndex];
}

- (void)goHome:(NavigationBar *)naviBar {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.naviBar setNaviTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"brandNm"]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)goPrev {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.naviBar setNaviTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"brandNm"]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 10001) {
        CGFloat pageWidth = scrollView.frame.size.width;
        //        NSLog(@"current page : %f", floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2);
        int page = floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2;
        
        if (page%25 == 1) {
            if (aScrollView.userInteractionEnabled == YES) {
                if (![thumbDic objectForKey:[NSString stringWithFormat:@"page%d", page/25 + 1]]) {
                    [aScrollView setUserInteractionEnabled:NO];
                }
            }
        } else {
            [aScrollView setUserInteractionEnabled:YES];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (scrollView.tag == 10001) {
        CGFloat pageWidth = scrollView.frame.size.width;
        //        NSLog(@"current page : %f", floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2);
        int page = floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2;
        
//        self.listData = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"productslist"]];
        
//        NSLog(@"ㅁㄴㅇㄹ : %@", [[[NSKeyedUnarchiver unarchiveObjectWithData:[thumbDic objectForKey:[NSString stringWithFormat:@"page%d", page/25 + 1]]] objectForKey:@"list"] objectAtIndex:((page - (page/25 * 25) - 1))]);
        
        NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
        NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
        NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
        
//        NSLog(@"ㅁㄴㅇㄹ : %@", [thumbDic objectForKey:[NSString stringWithFormat:@"page%d", page/25 + 1]]);
        
        if ([[[[[NSKeyedUnarchiver unarchiveObjectWithData:[thumbDic objectForKey:[NSString stringWithFormat:@"page%d", page/25 + 1]]] objectForKey:@"list"] objectAtIndex:((page - (page/25 * 25)) - 1)] objectForKey:@"hasPrduct"] intValue] == 1) {
            [loadingView startLoading];
            
            NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&cntntsId=%@&shopCd=%@&accessToken=%@&timestamp=%0.f"
                             , KHOST
                             , LISTPRODUCT
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                             , [[[[NSKeyedUnarchiver unarchiveObjectWithData:[thumbDic objectForKey:[NSString stringWithFormat:@"page%d", page/25 + 1]]] objectForKey:@"list"] objectAtIndex:((page - (page/25 * 25)) -1)] objectForKey:@"cntntsId"]
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"shopCd"]
                             , [temp hexadecimalString]
                             , timeInMiliseconds];
            
            
            [productRequest setDelegate:self selector:@selector(productListResult:)];
            [productRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        } else {
//            [loadingView stopLoading];
            [app.loadingView stopLoading];
            
            [productRequest requestCancel];
            
            self.listData = nil;
            
            [productListView reloadData];
        }
        
        if (page%25 == 1) {//25개마다 체크 : 총 이미지가 25개 이상인지 확인
            if (page != 1) {
                if ([thumbDic objectForKey:[NSString stringWithFormat:@"page%d", page/25 + 1]]) {
                    [aScrollView setUserInteractionEnabled:YES];
                } else {
                    [app.loadingView startLoading];
//                    [naviBar.loadingView startLoading];
                    
                    NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=%@&timestamp=%0.f"
                                     , KHOST
                                     , PAGEDLISTALLCNTNTSINFO
                                     , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                     , [_thumbnailInfo objectForKey:@"ctgryId"]
                                     , (page/25)+1
                                     , 25
                                     , [temp hexadecimalString]
                                     , timeInMiliseconds];
                    
                    httpRequest *_httpRequest = [[httpRequest alloc] init];
                    [_httpRequest setDelegate:self selector:@selector(addThumbList:)];
                    [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
                }
            }
        }
    }
}

- (void)productListResult:(NSString *)data {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"product list data : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([[[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"] isEqualToString:@"200"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[resultsDictionary objectForKey:@"results"]] forKey:@"productslist"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self.listData = [resultsDictionary objectForKey:@"results"];
            
            [productListView reloadData];
            
//            [loadingView stopLoading];
            [app.loadingView stopLoading];
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
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"productslist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.listData = nil;
        
        [productListView reloadData];
        
//        [loadingView stopLoading];
        [app.loadingView stopLoading];
    }
}

- (void)addThumbList:(NSString *)data {
    NSLog(@"add thumb list : %@", data);
    
    [aScrollView setUserInteractionEnabled:YES];
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([[[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"] isEqualToString:@"200"]) {
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] != nil) {
                BOOL samePage = NO;
                
                for (id key in [[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] allKeys]) {
                    if ([key isEqualToString:[NSString stringWithFormat:@"page%d", [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"currentPage"] intValue]]]) {
                        NSLog(@"같은게 있음");
                        samePage = YES;
                    }
                }
                
                if (samePage == NO) {
                    NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]];
                    
                    [temp setObject:[NSKeyedArchiver archivedDataWithRootObject:resultsDictionary] forKey:[NSString stringWithFormat:@"page%d", [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"currentPage"] intValue]]];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"thumblist"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            } else {
                NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSKeyedArchiver archivedDataWithRootObject:resultsDictionary], [NSString stringWithFormat:@"page%d", [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"currentPage"] intValue]], nil];
                [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"thumblist"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            thumbDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"];
            
            for (int i = 0; i < [[resultsDictionary objectForKey:@"list"] count]; i++) {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *cachesDirectory = [paths objectAtIndex:0];
                NSString *dirPath = [NSString stringWithFormat:@"%@/salesforce/%@/%@/%@"
                                     , cachesDirectory
                                     , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                     , _rootDir
                                     , [[[resultsDictionary objectForKey:@"list"] objectAtIndex:i] objectForKey:@"cntntsId"]];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
                
                NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/%@/%@/%@"
                                                                                       , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                                                                       , _rootDir
                                                                                       , [[[resultsDictionary objectForKey:@"list"] objectAtIndex:i] objectForKey:@"cntntsId"]
                                                                                       , [[[resultsDictionary objectForKey:@"list"] objectAtIndex:i] objectForKey:@"cntntsFileLc"]]];
                
                BOOL fileExistsAtPath = [fileManager fileExistsAtPath:cachePath];
                if (fileExistsAtPath) {
                    UIImageView *lookbookCntnts = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:cachePath]];
                    [lookbookCntnts setFrame:
                     CGRectMake((1 * (25 * cntBgView.image.size.width)) + (cntBgView.image.size.width * i) + (cntBgView.image.size.width/2 - lookbookCntnts.image.size.width/2)
                                , cntBgView.image.size.height/2 - lookbookCntnts.image.size.height/2
                                , lookbookCntnts.image.size.width
                                , lookbookCntnts.image.size.height)];
                    [aScrollView addSubview:lookbookCntnts];
                } else {
                    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[[resultsDictionary objectForKey:@"list"] objectAtIndex:i] objectForKey:@"dwldCntntsPath"]]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                        
                        NSData *temp = [NSData dataWithData:UIImagePNGRepresentation([UIImage imageWithData:data])];
                        
                        UIImageView *lookbookCntnts = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
                        [lookbookCntnts setFrame:
                         CGRectMake((1 * (25 * cntBgView.image.size.width)) + (cntBgView.image.size.width * i) + (cntBgView.image.size.width/2 - lookbookCntnts.image.size.width/2)
                                    , cntBgView.image.size.height/2 - lookbookCntnts.image.size.height/2
                                    , lookbookCntnts.image.size.width
                                    , lookbookCntnts.image.size.height)];
                        [aScrollView addSubview:lookbookCntnts];
                        
                        [temp writeToFile:cachePath atomically:YES];
                    }];
                }
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
        
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.loadingView stopLoading];
//        [naviBar.loadingView stopLoading];
    } else {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.loadingView stopLoading];
//        [naviBar.loadingView stopLoading];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
//    ProductCell *cell = (ProductCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    ProductCell *cell = nil;
    if (cell == nil) {
        cell = [[ProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    [cell setBackgroundColor:[UIColor clearColor]];
    
    NSDictionary *item = [_listData objectAtIndex:indexPath.row];
    
    if (item) {
        NSString *imgURL = [item objectForKey:@"thumbUrl"];
        NSString *productName = [item objectForKey:@"prductNm"];
        NSString *productCd = [item objectForKey:@"prductCd"];
        NSString *price = [CommonUtil makeComma:[item objectForKey:@"copr"]];
        NSString *amount = [CommonUtil makeComma:[item objectForKey:@"jegoTotqy"]];
        NSString *amountLbl = [NSString stringWithFormat:@"%@원 / 수량 %@", price, amount];
        
        UIView *noImageBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        [noImageBg setBackgroundColor:[UIColor clearColor]];
        UIImageView *noImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_NoImage"]];
        [noImageView setFrame:CGRectMake(40 - noImageView.image.size.width/2, 40 - noImageView.image.size.height/2, noImageView.image.size.width, noImageView.image.size.height)];
        [noImageBg addSubview:noImageView];
        
        [cell.thumbnnailView setImageWithURL:[NSURL URLWithString:imgURL]
                            placeholderImage:[CommonUtil imageWithView:noImageBg]];
        
        [cell.productNameLbl setText:productName];
        [cell.productCdLbl setText:productCd];
        [cell.amountLbl setText:amountLbl];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductDetailView *productDV = [[ProductDetailView alloc] initWithProductCd:[[_listData objectAtIndex:indexPath.row] objectForKey:@"prductCd"]];
    [productDV setDelegate:self selector:@selector(detailProductDismiss)];
    [self.view addSubview:productDV];
}

- (void)detailProductDismiss {
    for (UIView *view in [self.view subviews]) {
        if ([view isKindOfClass:[ProductDetailView class]]) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 8005) {
        if (buttonIndex != 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [_thumbnailInfo objectForKey:@"linkUrl"]]]];
        }
    }
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
