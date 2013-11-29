//
//  ShopInfoViewController.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 10..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "ShopInfoViewController.h"
//
#import "NSData+AESAdditions.h"
#import "NSString+UrlEncoding.h"

#define HEIGHT            [CommonUtil osVersion]

static int cellNum = 15;

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

@interface ShopInfoViewController ()

@end

@implementation ShopInfoViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"shoplist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        btnArr = [[NSMutableArray alloc] init];
        textFieldArr = [[NSMutableArray alloc] init];
        shopListDic = [[NSMutableDictionary alloc] init];
        shopListDic = nil;
        spinnerArr = [[NSMutableArray alloc] init];
        
        searchTxt = @"";
        searchCheck = NO;
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
    [lbl setText:@"매장정보"];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setFont:[UIFont boldSystemFontOfSize:36]];
    [cntBgView addSubview:lbl];
    
    UIImageView *titleUnderBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Img_TitleUnderBar"]];
    [titleUnderBarView setFrame:CGRectMake(20, 86, titleUnderBarView.image.size.width, titleUnderBarView.image.size.height)];
    [cntBgView addSubview:titleUnderBarView];
    
    UIImageView *searchBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_Search_BG02"]];
    [searchBg setUserInteractionEnabled:YES];
    [searchBg setFrame:CGRectMake(9, 275, searchBg.image.size.width, searchBg.image.size.height)];
    [cntBgView addSubview:searchBg];
    
    areaBtnBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_SF_STORE_BtnBG"]];
    [areaBtnBg setFrame:CGRectMake(12, 119, areaBtnBg.image.size.width, areaBtnBg.image.size.height)];
    [areaBtnBg setUserInteractionEnabled:YES];
    [cntBgView addSubview:areaBtnBg];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setFrame:CGRectMake(areaBtnBg.frame.size.width/2 - spinner.bounds.size.width/2, areaBtnBg.frame.size.height/2 - spinner.bounds.size.height/2, spinner.bounds.size.width, spinner.bounds.size.height)];
    [spinner setTag:0];
    [spinnerArr addObject:spinner];
    [areaBtnBg addSubview:spinner];
    
    UIImageView *searchBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_Search_TextBox02"]];
    [searchBox setUserInteractionEnabled:YES];
    [searchBox setFrame:CGRectMake(138, 24, searchBox.image.size.width, searchBox.image.size.height)];
    [searchBg addSubview:searchBox];
    
    UITextField *shopNmField = [[UITextField alloc] initWithFrame:CGRectMake(17, 0, searchBox.image.size.width - 17, searchBox.image.size.height)];
    [shopNmField setDelegate:self];
    [shopNmField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [shopNmField setBackgroundColor:[UIColor clearColor]];
    [shopNmField setPlaceholder:@"매장명 입력"];
    [shopNmField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [shopNmField setReturnKeyType:UIReturnKeyDone];
    [shopNmField setFont:[UIFont systemFontOfSize:18.0f]];
    [shopNmField setTextColor:[UIColor whiteColor]];
    [shopNmField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textFieldArr addObject:shopNmField];
    [searchBox addSubview:shopNmField];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTag:1];
    [btn setImage:[UIImage imageNamed:@"IM_Sub_Search_Btn02"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(510, 24, btn.imageView.image.size.width, btn.imageView.image.size.height)];
    [btn addTarget:self action:@selector(shopSearch) forControlEvents:UIControlEventTouchUpInside];
    [searchBg addSubview:btn];
    
    UIImageView *listTopBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_SF_STORE_GridTop"]];
    [listTopBg setFrame:CGRectMake(10, 379, listTopBg.image.size.width, listTopBg.image.size.height)];
    [cntBgView addSubview:listTopBg];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 51, 36)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setText:@"구분"];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [listTopBg addSubview:lbl];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(53, 0, 50, 36)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setText:@"지역"];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [listTopBg addSubview:lbl];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(105, 0, 158, 36)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setText:@"매장명"];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [listTopBg addSubview:lbl];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(265, 0, 365, 36)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setText:@"주소"];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [listTopBg addSubview:lbl];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(632, 0, 112, 36)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setText:@"전화번호"];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [listTopBg addSubview:lbl];
    
    shopList = [[UITableView alloc] initWithFrame:CGRectMake(10, 417, 748, 464)];
    [shopList setDelegate:self];
    [shopList setDataSource:self];
    [shopList setRowHeight:29.0f];
    [shopList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [shopList setShowsVerticalScrollIndicator:NO];
    [shopList setBackgroundColor:[UIColor clearColor]];
    [cntBgView addSubview:shopList];
    
    tempBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, shopList.frame.size.width, shopList.frame.size.height)];
    [tempBg setBackgroundColor:[UIColor blackColor]];
    [tempBg setAlpha:0.5f];
    [tempBg setHidden:YES];
    [shopList addSubview:tempBg];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setFrame:CGRectMake(shopList.frame.size.width/2 - spinner.bounds.size.width/2, shopList.frame.size.height/2 - spinner.bounds.size.height/2, spinner.bounds.size.width, spinner.bounds.size.height)];
    [spinner setTag:1];
    [spinnerArr addObject:spinner];
    [shopList addSubview:spinner];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [shopList addSubview:refreshControl];
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@?accessToken=%@&timestamp=%0.f"
                     , KHOST, LISTAREA
                     , [temp hexadecimalString]
                     , timeInMiliseconds];
    
    httpRequest *_httpRequest = [[httpRequest alloc] init];
    [_httpRequest setDelegate:self selector:@selector(result:)];
    [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    
    [(UIActivityIndicatorView *)[spinnerArr objectAtIndex:0] startAnimating];
}

- (void)result:(NSString *)data {
    NSLog(@"listarea result : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            UIButton *btn;
            for (int i = 0; i < [[resultsDictionary objectForKey:@"results"] count] + 1; i++) {
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                if (i == 0) {
                    [btn setTag:i];
                    [btn setTitle:@"전체" forState:UIControlStateNormal];
                } else {
                    [btn setTag:[[[[resultsDictionary objectForKey:@"results"] objectAtIndex:i - 1] objectForKey:@"areaCd"] intValue]];
                    [btn setTitle:[[[resultsDictionary objectForKey:@"results"] objectAtIndex:i - 1] objectForKey:@"areaNm"] forState:UIControlStateNormal];
                }
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"IM_SF_STORE_BtnBG_N"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"IM_SF_STORE_BtnBG_O"] forState:UIControlStateSelected];
                [btn addTarget:self action:@selector(areaBtnCheck:) forControlEvents:UIControlEventTouchUpInside];
                [btn setFrame:CGRectMake(8 + ((i % 6) * 122), (i / 6) * 36 + 8 + ((i / 6) * 4), 118, 36)];
                [btnArr addObject:btn];
                [areaBtnBg addSubview:btn];
            }
            [(UIActivityIndicatorView *)[spinnerArr objectAtIndex:0] stopAnimating];
            [(UIActivityIndicatorView *)[spinnerArr objectAtIndex:0] setHidden:YES];
            
            [self areaBtnCheck:0];
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
        
    }
}

- (void)areaBtnCheck:(id)sender {
    [tempBg setHidden:NO];
    
    [(UIActivityIndicatorView *)[spinnerArr objectAtIndex:1] setHidden:NO];
    [(UIActivityIndicatorView *)[spinnerArr objectAtIndex:1] startAnimating];
    
    searchTxt = @"";
    [((UITextField *)[textFieldArr objectAtIndex:0]) setText:@""];
    
    [self areaListRequest:sender];
}

- (void)areaListRequest:(id)sender {
    shopListDic = nil;
    
    int tag = 0;
    if ([sender isKindOfClass:[UIButton class]]) {
        tag = ((UIButton *)sender).tag;
        
        for (int i = 0; i < [btnArr count]; i++) {
            if (((UIButton *)sender) == ((UIButton *)[btnArr objectAtIndex:i])) {
                [((UIButton *)[btnArr objectAtIndex:i]) setSelected:YES];
                [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:NO];
            } else {
                [((UIButton *)[btnArr objectAtIndex:i]) setSelected:NO];
                [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:YES];
            }
        }
    } else {
        tag = [sender intValue];
        
        for (int i = 0; i < [btnArr count]; i++) {
            if (i == 0) {
                [((UIButton *)[btnArr objectAtIndex:i]) setSelected:YES];
                [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:NO];
            } else {
                [((UIButton *)[btnArr objectAtIndex:i]) setSelected:NO];
                [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:YES];
            }
        }
    }
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *url = @"";
    if (tag == 0) {
        url = [NSString stringWithFormat:@"%@%@?currentPage=%@&maxResults=%d&maxLinks=%d&searchNm=%@&areaCd=%@&accessToken=%@&timestamp=%0.f"
               , KHOST, PAGEDLISTSHOPINFO
               , @"1"
               , cellNum
               , cellNum
               , [searchTxt urlEncodeUsingEncoding:NSUTF8StringEncoding]
               , @""
               , [temp hexadecimalString]
               , timeInMiliseconds];

    } else {
        url = [NSString stringWithFormat:@"%@%@?currentPage=%@&maxResults=%d&maxLinks=%d&searchNm=%@&areaCd=%d&accessToken=%@&timestamp=%0.f"
               , KHOST, PAGEDLISTSHOPINFO
               , @"1"
               , cellNum
               , cellNum
               , [searchTxt urlEncodeUsingEncoding:NSUTF8StringEncoding]
               , tag
               , [temp hexadecimalString]
               , timeInMiliseconds];
    }
    
    httpRequest *_httpRequest = [[httpRequest alloc] init];
    [_httpRequest setDelegate:self selector:@selector(areaListResult:)];
    [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
}

- (void)areaListResult:(NSString *)data {
    [tempBg setHidden:YES];
    
    [(UIActivityIndicatorView *)[spinnerArr objectAtIndex:1] setHidden:YES];
    [(UIActivityIndicatorView *)[spinnerArr objectAtIndex:1] stopAnimating];
    
    NSLog(@"arealistresult : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            [(UIActivityIndicatorView *)[spinnerArr lastObject] setHidden:YES];
            [(UIActivityIndicatorView *)[spinnerArr lastObject] stopAnimating];
            
            if (shopListDic != nil) {
                BOOL samePage = NO;
                
                for (id key in [shopListDic allKeys]) {
                    if ([key isEqualToString:[NSString stringWithFormat:@"page%d", [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"currentPage"] intValue]]]) {
                        NSLog(@"같은게 있음");
                        samePage = YES;
                    }
                }
                
                if (samePage == NO) {                    
                    [shopListDic setObject:resultsDictionary forKey:[NSString stringWithFormat:@"page%d", [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"currentPage"] intValue]]];
                    cellCnt = 1;
                    [shopList reloadData];
                }
            } else {
                shopListDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:resultsDictionary, [NSString stringWithFormat:@"page%d", [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"currentPage"] intValue]], nil];
                cellCnt = 1;
                [shopList reloadData];
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
    } else {
        
    }
}

- (void)shopSearch {
    searchCheck = YES;
    
    searchTxt = ((UITextField *)[textFieldArr objectAtIndex:0]).text;
    [((UITextField *)[textFieldArr objectAtIndex:0]) resignFirstResponder];
    
    for (int i = 0; i < [btnArr count]; i++) {
        if (((UIButton *)[btnArr objectAtIndex:i]).selected) {
            shopListDic = nil;
            cellCnt = 1;
            [self areaListRequest:((UIButton *)[btnArr objectAtIndex:i])];
        }
    }
}

- (void)refresh:(UIRefreshControl *)refresh {
    for (int i = 0; i < [btnArr count]; i++) {
        if (((UIButton *)[btnArr objectAtIndex:i]).selected) {
            cellCnt = 1;
            [self areaListRequest:((UIButton *)[btnArr objectAtIndex:i])];
        }
    }
    [refresh endRefreshing];
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndDecelerating %f", scrollView.contentOffset.y);
    
    if (pageLoadCheck) {
        if (begin == scrollView.contentOffset.y) {
            if ((int)scrollView.contentOffset.y % 435 == 0) {
                [(UIActivityIndicatorView *)[spinnerArr lastObject] setHidden:NO];
                [(UIActivityIndicatorView *)[spinnerArr lastObject] startAnimating];
                
                for (UIButton *btn in btnArr) {
                    if (btn.selected) {
                        NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
                        NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
                        NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
                        
                        NSString *url = @"";
                        int currentPage = 1;
                        if (begin == 0) {
                            currentPage = 2;
                        } else {
                            currentPage = (int)scrollView.contentOffset.y/435 + 2;
                        }
                        
                        if (btn.tag == 0) {
                            url = [NSString stringWithFormat:@"%@%@?currentPage=%d&maxResults=%d&maxLinks=%d&searchNm=%@&areaCd=%@&accessToken=%@&timestamp=%0.f"
                                   , KHOST, PAGEDLISTSHOPINFO
                                   , currentPage
                                   , cellNum
                                   , cellNum
                                   , [searchTxt urlEncodeUsingEncoding:NSUTF8StringEncoding]
                                   , @""
                                   , [temp hexadecimalString]
                                   , timeInMiliseconds];
                        } else {
                            url = [NSString stringWithFormat:@"%@%@?currentPage=%d&maxResults=%d&maxLinks=%d&searchNm=%@&areaCd=%d&accessToken=%@&timestamp=%0.f"
                                   , KHOST, PAGEDLISTSHOPINFO
                                   , currentPage
                                   , cellNum
                                   , cellNum
                                   , [searchTxt urlEncodeUsingEncoding:NSUTF8StringEncoding]
                                   , btn.tag
                                   , [temp hexadecimalString]
                                   , timeInMiliseconds];
                        }
                        
                        httpRequest *_httpRequest = [[httpRequest alloc] init];
                        [_httpRequest setDelegate:self selector:@selector(areaListResult:)];
                        [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
                    }
                }
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDragging %f", scrollView.contentOffset.y);
    
    begin = (int)scrollView.contentOffset.y;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"scrollViewWillEndDragging %f, %f", scrollView.contentOffset.y, velocity.y);
    
    if (velocity.y < 0) {
        pageLoadCheck = NO;
    } else {
        if (cellCnt - 1 == [[[[shopListDic objectForKey:@"page1"] objectForKey:@"pagingProperty"] objectForKey:@"countItem"] intValue]) {
            pageLoadCheck = NO;
        } else {
            pageLoadCheck = YES;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    for (int i = 0; i < [[[NSUserDefaults standardUserDefaults] objectForKey:@"shoplist"] count]; i++) {
//        cellCnt = cellCnt + [[[[[NSUserDefaults standardUserDefaults] objectForKey:@"shoplist"] objectForKey:[NSString stringWithFormat:@"page%d", i + 1]] objectForKey:@"list"] count];
//    }
    
    for (int i = 0; i < [shopListDic count]; i++) {
        cellCnt = cellCnt + [[[shopListDic objectForKey:[NSString stringWithFormat:@"page%d", i + 1]] objectForKey:@"list"] count];
    }
    
    return cellCnt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ([shopListDic count] == 1) {
        if (indexPath.row == [[[shopListDic objectForKey:@"page1"] objectForKey:@"list"] count]) {
            static NSString *CellIdentifier = @"moreCell";
            //        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            // Configure the cell...
            [cell setBackgroundColor:[UIColor clearColor]];
            
            UIImageView *moreBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_SF_STORE_BTNMore"]];
            [moreBg setFrame:CGRectMake(0, 0, moreBg.image.size.width, moreBg.image.size.height)];
            [moreBg setUserInteractionEnabled:YES];
            
            [cell setBackgroundView:moreBg];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            
            if ([spinnerArr count] > 2) {
                [spinnerArr removeLastObject];
            }
            
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [spinner setTag:2];
            [spinner setFrame:CGRectMake(cell.frame.size.width/2 - 14, 0, 28, 28)];
            [spinner setHidden:YES];
            [spinnerArr addObject:spinner];
            [cell.contentView addSubview:spinner];
            
            [cell.textLabel setText:[NSString stringWithFormat:@"more %d", [[[[shopListDic objectForKey:@"page1"] objectForKey:@"pagingProperty"] objectForKey:@"countItem"] intValue] - cellNum]];
            [cell.textLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
        } else {
            static NSString *CellIdentifier = @"postCell";
            //        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            // Configure the cell...
            [cell setBackgroundColor:[UIColor clearColor]];
            
            if (indexPath.row % 2 == 0) {
                [cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_SF_STORE_GridEven"]]];
            } else {
                [cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_SF_STORE_GridOdd"]]];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UILabel *lbl;
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 51, 28)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setText:[[[[shopListDic objectForKey:@"page1"] objectForKey:@"list"] objectAtIndex:indexPath.row] objectForKey:@"shopTy"]];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setFont:[UIFont systemFontOfSize:12.0f]];
            [lbl setTextColor:[UIColor whiteColor]];
            [cell.contentView addSubview:lbl];
            
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(53, 0, 50, 28)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setText:[[[[shopListDic objectForKey:@"page1"] objectForKey:@"list"] objectAtIndex:indexPath.row] objectForKey:@"areaNm"]];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setFont:[UIFont systemFontOfSize:12.0f]];
            [lbl setTextColor:[UIColor whiteColor]];
            [cell.contentView addSubview:lbl];
            
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(105 + 10, 0, 158 - 10, 28)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setText:[[[[shopListDic objectForKey:@"page1"] objectForKey:@"list"] objectAtIndex:indexPath.row] objectForKey:@"shopNm"]];
            [lbl setTextAlignment:NSTextAlignmentLeft];
            [lbl setFont:[UIFont systemFontOfSize:12.0f]];
            [lbl setTextColor:[UIColor whiteColor]];
            [cell.contentView addSubview:lbl];
            
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(265 + 10, 0, 365 - 10, 28)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setText:[[[[shopListDic objectForKey:@"page1"] objectForKey:@"list"] objectAtIndex:indexPath.row] objectForKey:@"addr"]];
            [lbl setTextAlignment:NSTextAlignmentLeft];
            [lbl setFont:[UIFont systemFontOfSize:12.0f]];
            [lbl setTextColor:[UIColor whiteColor]];
            [cell.contentView addSubview:lbl];
            
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(632, 0, 112, 28)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setText:[[[[shopListDic objectForKey:@"page1"] objectForKey:@"list"] objectAtIndex:indexPath.row] objectForKey:@"telno"]];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setFont:[UIFont systemFontOfSize:12.0f]];
            [lbl setTextColor:[UIColor whiteColor]];
            [cell.contentView addSubview:lbl];
        }
    } else {
        if (indexPath.row == cellCnt - 1) {
            static NSString *CellIdentifier = @"moreCell";
            //        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            // Configure the cell...
            [cell setBackgroundColor:[UIColor clearColor]];
            
            UIImageView *moreBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_SF_STORE_BTNMore"]];
            [moreBg setFrame:CGRectMake(0, 0, moreBg.image.size.width, moreBg.image.size.height)];
            [moreBg setUserInteractionEnabled:YES];
            
            [cell setBackgroundView:moreBg];
            
            if ([spinnerArr count] > 2) {
                [spinnerArr removeLastObject];
            }
            
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [spinner setTag:2];
            [spinner setFrame:CGRectMake(cell.contentView.frame.size.width/2 - 14, 0, 28, 28)];
            [spinner setHidden:YES];
            [spinnerArr addObject:spinner];
            [cell.contentView addSubview:spinner];
            
            if (cellCnt - 1 == [[[[shopListDic objectForKey:@"page1"] objectForKey:@"pagingProperty"] objectForKey:@"countItem"] intValue]) {
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                [cell.textLabel setText:@"End"];
            } else {
                [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
                [cell.textLabel setText:[NSString stringWithFormat:@"more %d", [[[[shopListDic objectForKey:@"page1"] objectForKey:@"pagingProperty"] objectForKey:@"countItem"] intValue] - (cellCnt - 1)]];
            }
            [cell.textLabel setFont:[UIFont systemFontOfSize:12.0f]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
        } else {
            static NSString *CellIdentifier = @"postCell";
            //        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            // Configure the cell...
            [cell setBackgroundColor:[UIColor clearColor]];
            
            if (indexPath.row % 2 == 0) {
                [cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_SF_STORE_GridEven"]]];
            } else {
                [cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_SF_STORE_GridOdd"]]];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UILabel *lbl;
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 51, 28)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setText:[[[[shopListDic objectForKey:[NSString stringWithFormat:@"page%d", (indexPath.row / cellNum) + 1]] objectForKey:@"list"] objectAtIndex:indexPath.row%cellNum] objectForKey:@"shopTy"]];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setFont:[UIFont systemFontOfSize:12.0f]];
            [lbl setTextColor:[UIColor whiteColor]];
            [cell.contentView addSubview:lbl];
            
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(53, 0, 50, 28)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setText:[[[[shopListDic objectForKey:[NSString stringWithFormat:@"page%d", (indexPath.row / cellNum) + 1]] objectForKey:@"list"] objectAtIndex:indexPath.row%cellNum] objectForKey:@"areaNm"]];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setFont:[UIFont systemFontOfSize:12.0f]];
            [lbl setTextColor:[UIColor whiteColor]];
            [cell.contentView addSubview:lbl];
            
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(105 + 10, 0, 158 - 10, 28)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setText:[[[[shopListDic objectForKey:[NSString stringWithFormat:@"page%d", (indexPath.row / cellNum) + 1]] objectForKey:@"list"] objectAtIndex:indexPath.row%cellNum] objectForKey:@"shopNm"]];
            [lbl setTextAlignment:NSTextAlignmentLeft];
            [lbl setFont:[UIFont systemFontOfSize:12.0f]];
            [lbl setTextColor:[UIColor whiteColor]];
            [cell.contentView addSubview:lbl];
            
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(265 + 10, 0, 365 - 10, 28)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setText:[[[[shopListDic objectForKey:[NSString stringWithFormat:@"page%d", (indexPath.row / cellNum) + 1]] objectForKey:@"list"] objectAtIndex:indexPath.row%cellNum] objectForKey:@"addr"]];
            [lbl setTextAlignment:NSTextAlignmentLeft];
            [lbl setFont:[UIFont systemFontOfSize:12.0f]];
            [lbl setTextColor:[UIColor whiteColor]];
            [cell.contentView addSubview:lbl];
            
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(632, 0, 112, 28)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setText:[[[[shopListDic objectForKey:[NSString stringWithFormat:@"page%d", (indexPath.row / cellNum) + 1]] objectForKey:@"list"] objectAtIndex:indexPath.row%cellNum] objectForKey:@"telno"]];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setFont:[UIFont systemFontOfSize:12.0f]];
            [lbl setTextColor:[UIColor whiteColor]];
            [cell.contentView addSubview:lbl];
        }
    }

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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (![cell selectionStyle] == UITableViewCellSeparatorStyleNone) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        for (UIButton *btn in btnArr) {
            if (btn.selected) {
                NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
                NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
                NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
                
                NSString *url = @"";
                if (btn.tag == 0) {
                    url = [NSString stringWithFormat:@"%@%@?currentPage=%d&maxResults=%d&maxLinks=%d&searchNm=%@&areaCd=%@&accessToken=%@&timestamp=%0.f"
                           , KHOST, PAGEDLISTSHOPINFO
                           , (indexPath.row/cellNum)+1
                           , cellNum
                           , cellNum
                           , [searchTxt urlEncodeUsingEncoding:NSUTF8StringEncoding]
                           , @""
                           , [temp hexadecimalString]
                           , timeInMiliseconds];
                } else {
                    url = [NSString stringWithFormat:@"%@%@?currentPage=%d&maxResults=%d&maxLinks=%d&searchNm=%@&areaCd=%d&accessToken=%@&timestamp=%0.f"
                           , KHOST, PAGEDLISTSHOPINFO
                           , (indexPath.row/cellNum)+1
                           , cellNum
                           , cellNum
                           , [searchTxt urlEncodeUsingEncoding:NSUTF8StringEncoding]
                           , btn.tag
                           , [temp hexadecimalString]
                           , timeInMiliseconds];
                }
                
                httpRequest *_httpRequest = [[httpRequest alloc] init];
                [_httpRequest setDelegate:self selector:@selector(areaListResult:)];
                [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
            }
        }
    }
}

#pragma mark - Text field view delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {    
    [self shopSearch];
    
    return YES;
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
