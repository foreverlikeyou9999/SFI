//
//  ProductDetailView.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 22..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "ProductDetailView.h"
//
#import "httpRequest.h"
#import "CustomCell.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "NSData+AESAdditions.h"

@implementation ProductDetailView
@synthesize btnArr;
@synthesize infoLblArr;
@synthesize productColorArr;
@synthesize colorBtnArr;
@synthesize inventsArr;
@synthesize productCd;

@synthesize target;
@synthesize selector;

#define HEIGHT            [CommonUtil osVersion]

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithProductCd:(NSString*)productId
{
    self = [super initWithFrame:CGRectMake(0, HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - HEIGHT)];
    if (self) {
        // Initialization code
        self.productCd = productId;
        
        scrollArr = [[NSMutableArray alloc] init];
        
        btnArr = [[NSMutableArray alloc] init];
        infoLblArr = [[NSMutableArray alloc] init];
        productColorArr = [[NSMutableArray alloc] init];
        colorBtnArr = [[NSMutableArray alloc] init];
        inventsArr = [[NSMutableArray alloc] init];
        
        // view 생성
        [self createComponents];
        
        // 데이터 가져오기
        if (productCd != nil && productCd.length > 0) {
            [self productsInfoRequest:productCd];
        }
        
//        loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20)];
//        [self addSubview:loadingView];
//        [loadingView startLoading];
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self addSubview:app.loadingView];
        [app.loadingView startLoading];
    }
    return self;
    
}

- (void)createComponents {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [bgView setBackgroundColor:[UIColor blackColor]];
    [bgView setAlpha:0.5f];
    [self addSubview:bgView];
    
    UIImageView *bgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LayerPopUp_BG"]];
    [bgImg setUserInteractionEnabled:YES];
    [bgImg setFrame:CGRectMake(55, 67, bgImg.image.size.width, bgImg.image.size.height)];
    [self addSubview:bgImg];
    
    baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LayerPopUp_Box"]];
    [baseView setUserInteractionEnabled:YES];
    [baseView setFrame:CGRectMake(10, 2, baseView.image.size.width, baseView.image.size.height)];
    [bgImg addSubview:baseView];
    
    // 0. 타이틀
    UIView *titleBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 638, 36)];
    [titleBar setBackgroundColor:[UIColor clearColor]];
    [baseView addSubview:titleBar];
    
    titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 511, 36)];
    [titleLbl setBackgroundColor:[UIColor clearColor]];
    [titleLbl setTextAlignment:NSTextAlignmentLeft];
    [titleLbl setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [titleLbl setTextColor:[UIColor whiteColor]];
    [titleBar addSubview:titleLbl];
    
    // 1. 상단 컨텐츠
    productInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 56, 638, 256)];
    [productInfoView setBackgroundColor:[UIColor clearColor]];
    [baseView addSubview:productInfoView];
    
    productImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 240, 240)];
    [productInfoView addSubview:productImg];
    
    
    UIImageView *bulletImg;
    UIImageView *lblBg;
    UILabel *lbl;
    
    NSArray *infoTitleArr = [NSArray arrayWithObjects:@"상품코드", @"판매가", @"정상가", @"소재", @"제조사", @"원산지", @"Color", nil];
    
    for (int i = 0; i < 7; i++) {
        bulletImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LP_Bullet"]];
        [bulletImg setFrame:CGRectMake(264, 28 + (i * 5) + (i * 23), bulletImg.image.size.width, bulletImg.image.size.height)];
        [productInfoView addSubview:bulletImg];
        
        lblBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LP_TextBox"]];
        if (i != 6) {
            [lblBg setFrame:CGRectMake(357, 19 + (lblBg.image.size.height * i) + (i * 6), lblBg.image.size.width, lblBg.image.size.height)];
            
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, lblBg.image.size.width, lblBg.image.size.height)];
            [lbl setTag:i];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setFont:[UIFont systemFontOfSize:13.0f]];
            [lbl setTextColor:[UIColor colorWithRed:137/255.0f green:189/255.0f blue:80/255.0f alpha:1]];
            [lbl setTextAlignment:NSTextAlignmentLeft];
            [self.infoLblArr addObject:lbl];
            [lblBg addSubview:lbl];
            
            [productInfoView addSubview:lblBg];
            
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(281, 19 + (lblBg.image.size.height * i) + (i * 6), 74, lblBg.image.size.height)];
            [lbl setText:[infoTitleArr objectAtIndex:i]];
            [lbl setFont:[UIFont systemFontOfSize:13]];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setTextColor:[UIColor whiteColor]];
            [productInfoView addSubview:lbl];
        } else {
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(281, 19 + (lblBg.image.size.height * i) + (i * 6), 74, lblBg.image.size.height)];
            [lbl setText:[infoTitleArr objectAtIndex:i]];
            [lbl setFont:[UIFont systemFontOfSize:13]];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setTextColor:[UIColor whiteColor]];
            [productInfoView addSubview:lbl];
        }
    }
    
    UIButton *btn;
    for (int i = 0; i < 3; i++) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTag:i];
        if (i == 2) {
            [btn setImage:[UIImage imageNamed:@"IM_LP_Btn_Close_N"] forState:UIControlStateNormal];
            [btn setFrame:CGRectMake(389 + (i * 106), 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
            [btn addTarget:self action:@selector(dismissDV) forControlEvents:UIControlEventTouchUpInside];
        } else {
            if (i == 0) {
                [btn setImage:[UIImage imageNamed:@"IM_LP_Btn_Detail_N"] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"IM_LP_Btn_Detail_O"] forState:UIControlStateSelected];
                [btn setFrame:CGRectMake(389 + (i * 106), 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
                [btn addTarget:self action:@selector(pageMove:) forControlEvents:UIControlEventTouchUpInside];
                [btn setSelected:YES];
            } else {
                [btn setImage:[UIImage imageNamed:@"IM_LP_Btn_Inventory_N"] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"IM_LP_Btn_Inventory_O"] forState:UIControlStateSelected];
                [btn setFrame:CGRectMake(389 + (i * 106), 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
                [btn addTarget:self action:@selector(pageMove:) forControlEvents:UIControlEventTouchUpInside];
                [btn setSelected:NO];
            }
        }
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnArr addObject:btn];
        [titleBar addSubview:btn];
    }
    
    [baseView addSubview:productInfoView];
    
    // 2. 하단 컨텐츠
    _prdtDScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 312, 638, 558)];
    [_prdtDScroll setDelegate:self];
    [_prdtDScroll setTag:0];
    [_prdtDScroll setBackgroundColor:[UIColor clearColor]];
    [_prdtDScroll setPagingEnabled:YES];
    [_prdtDScroll setShowsHorizontalScrollIndicator:NO];
    [_prdtDScroll setContentSize:CGSizeMake(638*2, 558)];
    [baseView addSubview:_prdtDScroll];
    
    UILabel *stockLbl = [[UILabel alloc] initWithFrame:CGRectMake(646 + 624 - 100, 8, 100, 16)];
    [stockLbl setBackgroundColor:[UIColor clearColor]];
    [stockLbl setText:@"*이동수량제외"];
    [stockLbl setFont:[UIFont systemFontOfSize:14.0f]];
    [stockLbl setTextColor:[UIColor whiteColor]];
    [stockLbl setTextAlignment:NSTextAlignmentRight];
    [_prdtDScroll addSubview:stockLbl];
    
    productDesc = [[UIWebView alloc] initWithFrame:CGRectMake(8, 20 - 8, 618, 542 + 8)];
    [productDesc setBackgroundColor:[UIColor clearColor]];
    [productDesc setOpaque:NO];
    [productDesc sizeToFit];
    [_prdtDScroll addSubview:productDesc];
    
    UIImageView *tableTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LP_GridTop"]];
    [tableTitle setFrame:CGRectMake(646, 8 + 16 + 8, tableTitle.image.size.width, tableTitle.image.size.height)];
    [_prdtDScroll addSubview:tableTitle];
    
    for (int i = 0; i < 4; i++) {
        lbl = [[UILabel alloc] initWithFrame:CGRectMake((i * 2) + (i * 154), 0, 154, 36)];
        if (i == 0) {
            [lbl setText:@"사이즈"];
            [lbl setTextColor:[UIColor whiteColor]];
        } else if (i == 1) {
//            lbl = [[UILabel alloc] initWithFrame:CGRectMake((i * 2) + (i * 200), 0, 154, 36)];
            [lbl setText:@"매장재고"];
            [lbl setTextColor:[UIColor colorWithRed:137/255.0f green:189/255.0f blue:80/255.0f alpha:1]];
        } else if (i == 2) {
//            lbl = [[UILabel alloc] initWithFrame:CGRectMake((i * 2) + (i * 200), 0, 154, 36)];
            [lbl setText:@"전국재고"];
            [lbl setTextColor:[UIColor whiteColor]];
        } else {
//            lbl = [[UILabel alloc] initWithFrame:CGRectMake((i * 2) + (i * 200), 0, 154, 36)];
            [lbl setText:@"창고재고"];
            [lbl setTextColor:[UIColor whiteColor]];
        }
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [tableTitle addSubview:lbl];
    }
    
    table = [[UITableView alloc] initWithFrame:CGRectMake(646, 46 + 16 + 8, 624, 494 - 16 - 8)];
    [table setDelegate:self];
    [table setDataSource:self];
    [table setTag:1];
    [table setRowHeight:33];
    [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [table setBackgroundColor:[UIColor clearColor]];
    [table setShowsVerticalScrollIndicator:NO];
    [table setBounces:NO];
    [scrollArr addObject:table];
    [_prdtDScroll addSubview:table];
}

- (void)productsInfoRequest:(id)productId {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView startLoading];
//    [loadingView startLoading];
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    if ([productId isKindOfClass:[UIButton class]]) {
        NSString *proCd = [[self.productColorArr objectAtIndex:((UIButton *)productId).tag] objectForKey:@"prductCd"];
        
        NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&prductCd=%@&shopCd=%@&accessToken=%@&timestamp=%0.f"
                         , KHOST
                         , GETPRODUCT
                         , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                         , proCd
                         , [[NSUserDefaults standardUserDefaults] objectForKey:@"shopCd"]
                         , [temp hexadecimalString]
                         , timeInMiliseconds];
        
        httpRequest *_httpRequest = [[httpRequest alloc] init];
        [_httpRequest setDelegate:self selector:@selector(updateComponents:)];
        [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    } else {
        NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&prductCd=%@&shopCd=%@&accessToken=%@&timestamp=%0.f"
                         , KHOST
                         , GETPRODUCT
                         , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                         , productId
                         , [[NSUserDefaults standardUserDefaults] objectForKey:@"shopCd"]
                         , [temp hexadecimalString]
                         , timeInMiliseconds];
        
        httpRequest *_httpRequest = [[httpRequest alloc] init];
        [_httpRequest setDelegate:self selector:@selector(updateComponents:)];
        [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    }
}


- (void)doNetworkErrorProcess {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView stopLoading];
//    [loadingView stopLoading];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:@"통신이 원활하지 않습니다.\n다시 시도 하시겠습니까?" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"다시 시도", nil];
    [alertView setTag:0];
    [alertView show];
    
    NSLog(@"product list request error");
}

- (void)updateComponents:(NSString *)data {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView stopLoading];
//    [loadingView stopLoading];

    NSLog(@"product info data : %@", data);

    NSError *error = nil;

    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];

    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {

            if ([resultsDictionary objectForKey:@"result"] == [NSNull null]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"상품정보가 존재하지 않습니다."
                                                               delegate:nil cancelButtonTitle:@"확인"
                                                      otherButtonTitles:nil];
                
                [alert show];
                return;
            }

            NSDictionary *resultData = [resultsDictionary objectForKey:@"result"];

//            // 컬러버튼 삭제
            for (UIView *view in productInfoView.subviews) {
                if ([view isKindOfClass:[UIView class]]) {
                    if (view.backgroundColor == [UIColor whiteColor]) {
                        [view removeFromSuperview];
                    }
                }
            }

            
            if ([self.inventsArr count] != 0) {
                [self.inventsArr removeAllObjects];
            }
            
            if ([resultData objectForKey:@"invents"] != [NSNull null]) {
                self.inventsArr = [NSMutableArray arrayWithArray:[resultData objectForKey:@"invents"]];
            }
            
            [titleLbl setText:[resultData objectForKey:@"prductNm"]];

            NSArray *temp = [NSArray arrayWithObjects:@"prductCd", @"rspr", @"copr", @"matt", @"maker", @"origNm", nil];
            
            for (int i = 0; i < [infoLblArr count]; i++) {
                if (i==1 || i==2) { //가격정보는 ,표시
                    NSString *data = [CommonUtil makeComma:[resultData objectForKey:[temp objectAtIndex:i]]];
                    [((UILabel *)[infoLblArr objectAtIndex:i]) setText:[NSString stringWithFormat:@"%@원", data]];
                } else {
                    if ([resultData objectForKey:[temp objectAtIndex:i]] != [NSNull null]) {
                        NSString *data = [resultData objectForKey:[temp objectAtIndex:i]];
                        [((UILabel *)[infoLblArr objectAtIndex:i]) setText:data];
                    }
                }
            }

            UIView *noImageBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 240)];
            [noImageBg setBackgroundColor:[UIColor clearColor]];
            
            UIImageView *noImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_NoImage"]];
            [noImageView setFrame:CGRectMake(120 - noImageView.image.size.width/2, 120 - noImageView.image.size.height/2, noImageView.image.size.width, noImageView.image.size.height)];
            [noImageBg addSubview:noImageView];
            
            [productImg setImageWithURL:[NSURL URLWithString:[resultData objectForKey:@"prductUrl"]]  placeholderImage:[CommonUtil imageWithView:noImageBg]];
            
            if ([resultData objectForKey:@"colors"] != [NSNull null]) {
                self.productColorArr = [resultData objectForKey:@"colors"];
                
                UIButton *btn;
                UIView *colorBtnBg;
                UILabel *hypenLbl;

                for (int i = 0; i < [productColorArr count]; i++) {
                    colorBtnBg = [[UIView alloc] initWithFrame:CGRectMake(357 + ((i % 8) * 24) + ((i % 8) * 10), 189 + ((i / 8) * 34), 24, 24)];
                    [colorBtnBg setTag:i];
                    [colorBtnBg setBackgroundColor:[UIColor whiteColor]];
                    
                    hypenLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, 24, 22)];
                    [hypenLbl setBackgroundColor:[UIColor clearColor]];
                    [hypenLbl setFont:[UIFont systemFontOfSize:18.0f]];
                    [hypenLbl setText:@"-"];
                    [hypenLbl setTextAlignment:NSTextAlignmentCenter];
                    [hypenLbl setTextColor:[UIColor blackColor]];
                    [colorBtnBg addSubview:hypenLbl];
                    
                    btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btn setTag:i];
                    [btn setFrame:CGRectMake(1, 1, 22, 22)];
                    [btn setBackgroundColor:[UIColor clearColor]];
                    [btn addTarget:self action:@selector(productsInfoRequest:) forControlEvents:UIControlEventTouchUpInside];
                    [btn setImageWithURL:[[productColorArr objectAtIndex:i] objectForKey:@"colorUrl"] forState:UIControlStateNormal];
                    [colorBtnBg addSubview:btn];
                    
                    [productInfoView addSubview:colorBtnBg];
                }
            }
            
            if ([[resultData objectForKey:@"prductDesc"] isKindOfClass:[NSNull class]]) {
                [productDesc loadHTMLString:[NSString stringWithFormat:@"<html><body text=\"#FFFFFF\" size=\"13\"><p>상품 준비중입니다.</p></body></html>"] baseURL: nil];
            } else if ([[resultData objectForKey:@"prductDesc"] isEqualToString:@"null"]) {
                [productDesc loadHTMLString:[NSString stringWithFormat:@"<html><body text=\"#FFFFFF\" size=\"13\"><p>상품 준비중입니다.</p></body></html>"] baseURL: nil];
            } else {
                [productDesc loadHTMLString:[NSString stringWithFormat:@"<html><body text=\"#FFFFFF\" size=\"13\">%@</body></html>", [resultData objectForKey:@"prductDesc"]] baseURL: nil];
            }
            
            [table reloadData];
            
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
//        else {
//            [self dismissDV];
//        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SalesForce"
                                                        message:@"상품정보가 존재하지 않습니다."
                                                       delegate:nil cancelButtonTitle:@"확인"
                                              otherButtonTitles:nil];
        
        [alert show];
        return;
    }
}

- (void)pageMove:(id)sender {
    if (((UIButton *)sender).tag == 0) {
        [_prdtDScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        [_prdtDScroll setContentOffset:CGPointMake(638, 0) animated:YES];
    }
}

- (void)setDelegate:(id)aTarget selector:(SEL)aSelector {
    self.target = aTarget;
    self.selector = aSelector;
}

- (void)dismissDV {
    if(target) {
        [target performSelector:selector];
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 0) {
        CGFloat pageWidth = scrollView.frame.size.width;
        
        if (floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1 == 1) {
            [((UIButton *)[btnArr objectAtIndex:0]) setSelected:NO];
            [((UIButton *)[btnArr objectAtIndex:1]) setSelected:YES];
        } else {
            [((UIButton *)[btnArr objectAtIndex:0]) setSelected:YES];
            [((UIButton *)[btnArr objectAtIndex:1]) setSelected:NO];
        }
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
    return [self.inventsArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell = nil;

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if ([inventsArr count] == 0) {
        
    } else {
        UIImageView *cellBg;
        UILabel *lbl;
        if (indexPath.row % 2 == 0) {
            cellBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LP_GridEven"]];
            [cellBg setFrame:CGRectMake(0, 0, cellBg.image.size.width, cellBg.image.size.height)];
            [cell.contentView addSubview:cellBg];
        } else {
            cellBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LP_GridOdd"]];
            [cellBg setFrame:CGRectMake(0, 0, cellBg.image.size.width, cellBg.image.size.height)];
            [cell.contentView addSubview:cellBg];
        }
        
        for (int i = 0; i < 4; i++) {
            if (i == 0) {
                lbl = [[UILabel alloc] initWithFrame:CGRectMake((i * 2) + (i * 154), 0, 154, 36)];
                [lbl setText:[[self.inventsArr objectAtIndex:indexPath.row] objectForKey:@"sizeCd"]];
                [lbl setTextAlignment:NSTextAlignmentCenter];
                [lbl setTextColor:[UIColor whiteColor]];
            } else if (i == 1) {
                lbl = [[UILabel alloc] initWithFrame:CGRectMake((i * 2) + (i * 154), 0, 144, 36)];
                [lbl setText:[CommonUtil makeComma:[[self.inventsArr objectAtIndex:indexPath.row] objectForKey:@"jegoQty"]]];
                [lbl setTextAlignment:NSTextAlignmentRight];
                [lbl setTextColor:[UIColor colorWithRed:137/255.0f green:189/255.0f blue:80/255.0f alpha:1]];
            } else if (i == 2) {
                lbl = [[UILabel alloc] initWithFrame:CGRectMake((i * 2) + (i * 154), 0, 144, 36)];
                [lbl setText:[CommonUtil makeComma:[[self.inventsArr objectAtIndex:indexPath.row] objectForKey:@"otherQty"]]];
                [lbl setTextAlignment:NSTextAlignmentRight];
                [lbl setTextColor:[UIColor whiteColor]];
            } else {
                lbl = [[UILabel alloc] initWithFrame:CGRectMake((i * 2) + (i * 154), 0, 144, 36)];
                [lbl setText:[CommonUtil makeComma:[[self.inventsArr objectAtIndex:indexPath.row] objectForKey:@"whQty"]]];
                [lbl setTextAlignment:NSTextAlignmentRight];
                [lbl setTextColor:[UIColor whiteColor]];
            }
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setFont:[UIFont boldSystemFontOfSize:14.0f]];
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
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //    // Navigation logic may go here. Create and push another view controller.
    //    if (indexPath.row == 0) {
    //        ADGalleryViewController *detailViewController = [[ADGalleryViewController alloc] init];
    //        // ...
    //        // Pass the selected object to the new view controller.
    //        [self.navigationController pushViewController:detailViewController animated:YES];
    //        [detailViewController release];
    //    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        if (buttonIndex == 0) {
            [self dismissDV];
        } else {
            [self productsInfoRequest:productCd];
        }
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
