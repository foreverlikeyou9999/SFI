//
//  ViewType_010003.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 28..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "ViewType_010003.h"
//
#import "httpRequest.h"
#import "CommonUtil.h"
//
#import "ThumbnailView.h"
#import "ProductCell.h"
#import "ProductDetailView.h"
#import "UIImageView+WebCache.h"
#import "NSData+AESAdditions.h"

@implementation ViewType_010003
@synthesize target;
@synthesize selector;
@synthesize autoSelect = _autoSelect;
@synthesize dep1menuIndex = _dep1menuIndex;
@synthesize previewImgView;
//@synthesize videoView;
@synthesize listData;
@synthesize drawItemInfo = _drawItemInfo;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thumblist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
#if F_USE_DUMMY
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pdflst" ofType:@"json"];
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
        
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        NSLog(@"%@", jsonDict);
        
        self.listData = [jsonDict objectForKey:@"results"];
#else
        if ([NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"productslist"]] != [NSNull null]) {
            self.listData = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"productslist"]];
        }
#endif
        btnArr = [[NSMutableArray alloc] init];
        titleBtnArr = [[NSMutableArray alloc] init];
        menuList1 = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"menulist1"]];
        menuList2 = [[NSArray alloc] init];
        thumbArr = [[NSMutableArray alloc] init];
        
        pageCreate = [[NSMutableDictionary alloc] init];
        
        UIImageView *contentsTitleBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_ContentsTitleBar"]];
        [contentsTitleBar setTag:0];
        [contentsTitleBar setUserInteractionEnabled:YES];
        [contentsTitleBar setFrame:CGRectMake(-2, 0, contentsTitleBar.image.size.width, contentsTitleBar.image.size.height)];
        [self addSubview:contentsTitleBar];
        
        previewLblScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(15, 0, 466, contentsTitleBar.image.size.height)];
        [previewLblScroll setTag:0];
        [previewLblScroll setDelegate:self];
        [previewLblScroll setBackgroundColor:[UIColor clearColor]];
        [previewLblScroll setShowsHorizontalScrollIndicator:NO];
        [contentsTitleBar addSubview:previewLblScroll];
        
        previewLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 450, 18)];
        [previewLbl setBackgroundColor:[UIColor clearColor]];
        [previewLbl setTextColor:[UIColor whiteColor]];
        [previewLbl setTextAlignment:NSTextAlignmentLeft];
        [previewLbl setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [previewLblScroll addSubview:previewLbl];
        
        UIButton *btn;
        for (int i = 0; i < 2; i++) {
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTag:i];
            if (i == 0) {
                [btn setImage:[UIImage imageNamed:@"IM_Sub_Btn_Descript_N"] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"IM_Sub_Btn_Descript_O"] forState:UIControlStateSelected];
                [btn setSelected:NO];
            } else {
                [btn setImage:[UIImage imageNamed:@"IM_Sub_Btn_ProductList_N"] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"IM_Sub_Btn_ProductList_O"] forState:UIControlStateSelected];
                [btn setSelected:NO];
                
                productListCnt = [[UILabel alloc] initWithFrame:CGRectMake(100, btn.imageView.image.size.height/2 - btn.imageView.image.size.height/4, 39, btn.imageView.image.size.height/2)];
                [productListCnt setBackgroundColor:[UIColor clearColor]];
                [productListCnt setFont:[UIFont fontWithName:@"Roboto-Regular" size:10.0f]];
                [productListCnt setTextColor:[UIColor whiteColor]];
                [productListCnt setText:@"( 0 )"];
                [btn addSubview:productListCnt];
            }
            [btn addTarget:self action:@selector(showInfoView:) forControlEvents:UIControlEventTouchUpInside];
            [btn setFrame:CGRectMake(466 + (i * btn.imageView.image.size.width), 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
            [titleBtnArr addObject:btn];
            [contentsTitleBar addSubview:btn];
        }
        
        self.previewImgView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 32, self.bounds.size.width - 4, 420)];
        [self.previewImgView setHidden:YES];
        [self.previewImgView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.previewImgView];
        
        UIImageView *previewBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_ContentsBG"]];
        [previewBg setFrame:CGRectMake(-2, 32, previewBg.image.size.width, previewBg.image.size.height)];
        [self addSubview:previewBg];
        
//        self.videoView = [[UIWebView alloc] initWithFrame:CGRectMake(2, 32, self.bounds.size.width - 4, 420)];
//        [self.videoView setDelegate:self];
//        [self.videoView setHidden:YES];
//        [self.videoView.scrollView setScrollEnabled:NO];
//        [self.videoView.scrollView setBackgroundColor:[UIColor clearColor]];
//        [self.videoView setAllowsInlineMediaPlayback:YES];
//        [self.videoView setMediaPlaybackRequiresUserAction:NO];
//        [self addSubview:self.videoView];
        
        cntntsInfoBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_ContentsLayerBG"]];
        [cntntsInfoBox setHidden:YES];
        [cntntsInfoBox setUserInteractionEnabled:YES];
        [cntntsInfoBox setFrame:CGRectMake(464, 32, cntntsInfoBox.image.size.width, cntntsInfoBox.image.size.height)];
        [self addSubview:cntntsInfoBox];
        
        productListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 282, 420)];
        [productListView setTag:2];
        [productListView setHidden:YES];
        [productListView setDelegate:self];
        [productListView setDataSource:self];
        [productListView setRowHeight:90];
        [productListView setBackgroundColor:[UIColor clearColor]];
        [productListView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [cntntsInfoBox addSubview:productListView];
        
        cntntsInfoView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 282, 420)];
        [cntntsInfoView setBackgroundColor:[UIColor clearColor]];
        [cntntsInfoView setHidden:YES];
        [cntntsInfoView setUserInteractionEnabled:NO];
        [cntntsInfoView setTextColor:[UIColor whiteColor]];
        [cntntsInfoBox addSubview:cntntsInfoView];
        
        _scrollView = [[UIScrollView alloc] init];
        [_scrollView setFrame:CGRectMake(0, 543, self.bounds.size.width, self.bounds.size.height - 300)];
        [_scrollView setDelegate:self];
        [_scrollView setTag:1];
        [_scrollView setBackgroundColor:[UIColor clearColor]];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setPagingEnabled:YES];
        [self addSubview:_scrollView];
        
        pageSetup = YES;
        tabbarSetup = YES;
        
        self.autoSelect = NO;
    }
    return self;
}


- (void)showInfoView:(id)sender {
    if (((UIButton *)sender).tag == 0) {
        ((UIButton *)[titleBtnArr objectAtIndex:0]).selected = !((UIButton *)[titleBtnArr objectAtIndex:0]).selected;
        
        if (((UIButton *)[titleBtnArr objectAtIndex:0]).selected) {
            [cntntsInfoBox setHidden:NO];
            [((UIButton *)[titleBtnArr objectAtIndex:1]) setSelected:NO];
            [productListView setHidden:YES];
            [cntntsInfoView setHidden:NO];
        } else {
            [cntntsInfoBox setHidden:YES];
            [((UIButton *)[titleBtnArr objectAtIndex:1]) setSelected:NO];
            [productListView setHidden:YES];
            [cntntsInfoView setHidden:YES];
        }
    } else {
        ((UIButton *)[titleBtnArr objectAtIndex:1]).selected = !((UIButton *)[titleBtnArr objectAtIndex:1]).selected;
        
        if (((UIButton *)[titleBtnArr objectAtIndex:1]).selected) {
            [cntntsInfoBox setHidden:NO];
            [productListView setHidden:NO];
            [cntntsInfoView setHidden:YES];
            [((UIButton *)[titleBtnArr objectAtIndex:0]) setSelected:NO];
        } else {
            [cntntsInfoBox setHidden:YES];
            [productListView setHidden:YES];
            [cntntsInfoView setHidden:YES];
            [((UIButton *)[titleBtnArr objectAtIndex:0]) setSelected:NO];
        }
    }
}

- (void)setDelegate:(id)aTarget selector:(SEL)aSelector {
    self.target = aTarget;
    self.selector = aSelector;
}

- (void)firstimgrefresh {
    //    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/%@/%@/%@.%@"
                                                                           , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                                                           , [[[[NSUserDefaults standardUserDefaults] objectForKey:@"menulist1"] objectAtIndex:0] objectForKey:@"upCtgryId"]
                                                                           , [[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"cntntsId"]
                                                                           , [[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"cntntsFileLc"]
                                                                           , [[[[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]]objectForKey:@"list"] objectAtIndex:0] objectForKey:@"thumbFileNm"] componentsSeparatedByString:@"."] objectAtIndex:1]]];
    
//    [self.videoView loadHTMLString:nil baseURL:nil];
//    
//    [self.videoView setHidden:YES];
    [self webviewDelete];
    
    [self.previewImgView setHidden:NO];
    
    [self.previewImgView setImage:[UIImage imageWithContentsOfFile:cachePath]];
    
    CGSize stringSize = CGSizeZero;
    stringSize = [[[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"cntntsNm"] sizeWithFont:[UIFont systemFontOfSize:14.0f]];
    [previewLbl setFrame:CGRectMake(0, 7, stringSize.width, 18)];
    [previewLbl setText:[[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"cntntsNm"]];
    [previewLbl sizeToFit];
    
    [previewLblScroll setContentSize:CGSizeMake(stringSize.width + 15, 32)];
    
    [cntntsInfoView setText:[[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"cntntsCn"]];
    
    [productListView reloadData];
}

- (void)thumbListRequest:(int)currentIndex withTotalPage:(int)totalCnt withMenuIndex:(int)menuIndex withCtgry:(int)ctgryIndex {
    [target cntntsLoadingStart:nil];
    
    [pageCreate setObject:@"yes" forKey:[NSString stringWithFormat:@"페이지%d", currentIndex]];
    
    //    if (currentIndex > 1) {
    //        self.autoSelect = NO;
    //    }
    
    currentMenuIndex = menuIndex;
    
    if ([[[menuList1 objectAtIndex:menuIndex] objectForKey:@"cntntsTyCd"] isEqualToString:@"008001"]) {
        [self.previewImgView setHidden:NO];
//        [self.videoView setHidden:YES];
    } else if ([[[menuList1 objectAtIndex:menuIndex] objectForKey:@"cntntsTyCd"] isEqualToString:@"008002"]) {
        [self.previewImgView setHidden:YES];
//        [self.videoView setHidden:NO];
    } else {
        
    }
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (ctgryIndex == 1) {
        if ([[[menuList1 objectAtIndex:menuIndex] objectForKey:@"isLeaf"] intValue] == 1) {
            NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=%@&timestamp=%0.f"
                             , KHOST
                             , PAGEDLISTCNTNTSINFO
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                             , [[menuList1 objectAtIndex:menuIndex] objectForKey:@"ctgryId"]
                             , currentIndex
                             , totalCnt
                             , [temp hexadecimalString]
                             , timeInMiliseconds];
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(createComponents:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        } else {
            NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=%@&timestamp=%0.f"
                             , KHOST
                             , LISTCTGYINFODATA
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                             , [[menuList1 objectAtIndex:menuIndex] objectForKey:@"ctgryId"]
                             , currentIndex
                             , totalCnt
                             , [temp hexadecimalString]
                             , timeInMiliseconds];
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(createComponentsWithCtgry:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        }
    } else {
        if ([[[menuList1 objectAtIndex:menuIndex] objectForKey:@"isLeaf"] intValue] == 1) {
            NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=%@&timestamp=%0.f"
                             , KHOST
                             , PAGEDLISTCNTNTSINFO
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                             , [[menuList1 objectAtIndex:menuIndex] objectForKey:@"ctgryId"]
                             , currentIndex
                             , totalCnt
                             , [temp hexadecimalString]
                             , timeInMiliseconds];
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(createComponents:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        } else {
            NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=%@&timestamp=%0.f"
                             , KHOST
                             , PAGEDLISTALLCNTNTSINFO
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                             , [[[[NSUserDefaults standardUserDefaults] objectForKey:@"menulist2"] objectAtIndex:0] objectForKey:@"upCtgryId"]
                             , currentIndex
                             , totalCnt
                             , [temp hexadecimalString]
                             , timeInMiliseconds];
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(createComponents:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        }
    }
}

- (void)doNetworkErrorProcess {
    NSLog(@"010003 error");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"KOLON" message:@"네트워크가 불안정합니다.\n다시 시도하시겠습니까?" delegate:self cancelButtonTitle:@"메인" otherButtonTitles:@"다시 시도", nil];
    [alertView show];
}

- (void)createComponents:(NSString *)data {
    NSLog(@"010003 data : %@", data);
    
    ThumbnailView *thumbnailView;
    
    int thumbW = 0;
    int thumbH = 15;
    
    int thumbWidth = 187;
    int thumbHeight = 171;
    
    NSError *error = nil;
    
    NSMutableDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            [_scrollView setContentSize:CGSizeMake(self.bounds.size.width * [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"countPage"] intValue], self.bounds.size.height - 400)];
            
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
            
            NSArray *resultList = [resultsDictionary objectForKey:@"list"];
            NSDictionary *resultpageInfo = [resultsDictionary objectForKey:@"pagingProperty"];
            
            if (!thumbBgCheck) {
                UIImageView *baseView;
                for (int i = 0; i < [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"countItem"] intValue]; i++) {
                    baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_ThumbBG"]];
                    [baseView setTag:187];
                    [baseView setUserInteractionEnabled:YES];
                    [baseView setFrame:CGRectMake((((i / 4) * [UIScreen mainScreen].bounds.size.width) - (i / 4) * 20) + (i % 4) * thumbWidth + ((i % 4) * thumbW), 0, thumbWidth, thumbHeight)];

                    [_scrollView addSubview:baseView];
                }
                thumbBgCheck = YES;
            }
            
            if (tabbarSetup) {
                UIScrollView *menuBg = [[UIScrollView alloc] initWithFrame:CGRectMake(-2, 476, 752, 40)];
                [menuBg setTag:3];
                [menuBg setDelegate:self];
                [menuBg setBackgroundColor:[UIColor clearColor]];
                [menuBg setShowsVerticalScrollIndicator:NO];
                [menuBg setContentSize:CGSizeMake(752, 40)];
                [self addSubview:menuBg];
                
                UIButton *btn;
                UILabel *lbl;
                
                for (int i = 0; i < 1; i++) {
                    btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btn setTag:i];
                    [btn setImage:[UIImage imageNamed:@"IM_Sub_Tab_All_N"] forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:@"IM_Sub_Tab_All_O"] forState:UIControlStateSelected];
                    [btn setFrame:CGRectMake(4, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
                    if (i == 0) {
                        [btn setSelected:YES];
                    } else {
                        [btn setSelected:NO];
                    }
                    [btn setUserInteractionEnabled:NO];
                    [menuBg addSubview:btn];
                    
                    lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
                    [lbl setBackgroundColor:[UIColor clearColor]];
                    [lbl setText:@"All"];
                    [lbl setFont:[UIFont boldSystemFontOfSize:11]];
                    [lbl setTextColor:[UIColor whiteColor]];
                    [lbl setTextAlignment:NSTextAlignmentCenter];
                    [btn addSubview:lbl];
                }
                
                for (int i = 0; i < [resultList count]; i++) {
                    thumbnailView = [[ThumbnailView alloc] init];
                    thumbnailView.thumbnailDic = [resultList objectAtIndex:i];
                    
                    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                    dispatch_async(dispatchQueue, ^(void) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [thumbnailView dnThumbImg:[NSString stringWithFormat:@"%@/%@", [self.drawItemInfo objectForKey:@"upCtgryId"], [self.drawItemInfo objectForKey:@"ctgryId"]]];
                        });
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [thumbnailView dnCntImg:[NSString stringWithFormat:@"%@/%@", [self.drawItemInfo objectForKey:@"upCtgryId"], [self.drawItemInfo objectForKey:@"ctgryId"]]];
                        });
                    });
                    
                    [thumbnailView setFrame:CGRectMake(((([[resultpageInfo objectForKey:@"currentPage"] intValue] - 1) * [UIScreen mainScreen].bounds.size.width) - (([[resultpageInfo objectForKey:@"currentPage"] intValue] - 1) * 20)) + (i % 4) * thumbWidth + ((i % 4) * thumbW), (i / 4) * thumbHeight + ((i / 4) * thumbH), thumbWidth, thumbHeight)];
                    
                    [thumbnailView setCurrentScrinTyCd:[self.drawItemInfo objectForKey:@"scrinTyCd"]];
                    
                    if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010001"]) {
                        [thumbnailView setDelegate:self selector:nil];
                    } else if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010002"]) {
                        [thumbnailView setDelegate:self.target selector:nil];
                    } else if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010003"]) {
                        [thumbnailView setDelegate:self.target selector:nil];
                    } else if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010004"]) {
                        [thumbnailView setDelegate:self selector:nil];
                    } else {
                        
                    }
                    
                    if (self.autoSelect) {
                        if (i == 0) {
                            [thumbnailView typeSort];
                            self.autoSelect = NO;
                        }
                    }
                    [_scrollView addSubview:thumbnailView];
                    [thumbArr addObject:thumbnailView];
                }
                tabbarSetup = NO;
            } else {                
                for (int i = 0; i < [resultList count]; i++) {
                    thumbnailView = [[ThumbnailView alloc] init];
                    thumbnailView.thumbnailDic = [resultList objectAtIndex:i];
                    
                    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                    dispatch_async(dispatchQueue, ^(void) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [thumbnailView dnThumbImg:[NSString stringWithFormat:@"%@/%@", [self.drawItemInfo objectForKey:@"upCtgryId"], [self.drawItemInfo objectForKey:@"ctgryId"]]];
                        });
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [thumbnailView dnCntImg:[NSString stringWithFormat:@"%@/%@", [self.drawItemInfo objectForKey:@"upCtgryId"], [self.drawItemInfo objectForKey:@"ctgryId"]]];
                        });
                    });
                    
                    [thumbnailView setFrame:CGRectMake(((([[resultpageInfo objectForKey:@"currentPage"] intValue] - 1) * [UIScreen mainScreen].bounds.size.width) - (([[resultpageInfo objectForKey:@"currentPage"] intValue] - 1) * 20)) + (i % 4) * thumbWidth + ((i % 4) * thumbW), (i / 4) * thumbHeight + ((i / 4) * thumbH), thumbWidth, thumbHeight)];
                    
                    [thumbnailView setCurrentScrinTyCd:[self.drawItemInfo objectForKey:@"scrinTyCd"]];
                    
                    if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010001"]) {
                        [thumbnailView setDelegate:self selector:nil];
                    } else if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010002"]) {
                        [thumbnailView setDelegate:self.target selector:nil];
                    } else if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010003"]) {
                        [thumbnailView setDelegate:self.target selector:nil];
                    } else if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010004"]) {
                        [thumbnailView setDelegate:self selector:nil];
                    } else {
                        
                    }
                    
                    if (self.autoSelect) {
                        if (i == 0) {
                            [thumbnailView typeSort];
                            self.autoSelect = NO;
                        }
                    }
                    [_scrollView addSubview:thumbnailView];
                    [thumbArr addObject:thumbnailView];
                }
            }
            
            if (pageSetup) {
                for (UIView *view in self.subviews) {
                    if ([view isKindOfClass:[UIPageControl class]]) {
                        [view removeFromSuperview];
                    }
                }
                
                int thumbCount = [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"countItem"] intValue];
                int page = [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"maxResults"] intValue];
                
                _pageC = [[UIPageControl alloc] init];
                [_pageC setFrame:CGRectMake(self.bounds.size.width/2 - _pageC.bounds.size.width/2, self.bounds.size.height - 10, _pageC.bounds.size.width, _pageC.bounds.size.height)];
                [_pageC setCurrentPage:0];
                [self addSubview:_pageC];
                
                if (thumbCount > page) {
                    if (thumbCount%page == 0) {
                        if (_pageC.numberOfPages != thumbCount/page) {
                            [_pageC setNumberOfPages:thumbCount/page];
                        }
                    } else {
                        if (_pageC.numberOfPages != thumbCount/page + 1) {
                            [_pageC setNumberOfPages:thumbCount/page + 1];
                        }
                    }
                } else {
                    [_pageC setNumberOfPages:1];
                }
                
                if ([[[UIDevice currentDevice] systemVersion] intValue] < 7) {
                    if ([_pageC.subviews count] == 1) {
                        ((UIImageView *)[[_pageC subviews] objectAtIndex:0]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_O"];
                        [((UIImageView *)[[_pageC subviews] objectAtIndex:0]) setFrame:CGRectMake(((UIImageView *)[[_pageC subviews] objectAtIndex:0]).bounds.origin.x, ((UIImageView *)[[_pageC subviews] objectAtIndex:0]).bounds.origin.y, 11, 11)];
                    } else {
                        for (int i = 1; i < [_pageC.subviews count]; i++) {
                            ((UIImageView *)[[_pageC subviews] objectAtIndex:i]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_N"];
                            [((UIImageView *)[[_pageC subviews] objectAtIndex:i]) setFrame:CGRectMake(((UIImageView *)[[_pageC subviews] objectAtIndex:0]).bounds.origin.x, ((UIImageView *)[[_pageC subviews] objectAtIndex:0]).bounds.origin.y, 11, 11)];
                        }
                        ((UIImageView *)[[_pageC subviews] objectAtIndex:0]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_O"];
                        [((UIImageView *)[[_pageC subviews] objectAtIndex:0]) setFrame:CGRectMake(((UIImageView *)[[_pageC subviews] objectAtIndex:0]).bounds.origin.x, ((UIImageView *)[[_pageC subviews] objectAtIndex:0]).bounds.origin.y, 11, 11)];
                    }
                }
                pageSetup = NO;
            }
            [target cntntsLoadingStop];
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
        [target cntntsLoadingStop];
    }
}

- (void)createComponentsWithCtgry:(NSString *)data {
    NSLog(@"010003 ctgry data : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            
            [[NSUserDefaults standardUserDefaults] setObject:[resultsDictionary objectForKey:@"results"] forKey:@"menulist2"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            menuList2 = [resultsDictionary objectForKey:@"results"];
            
            UIScrollView *menuBg = [[UIScrollView alloc] initWithFrame:CGRectMake(-2, 476, 752, 40)];
            [menuBg setTag:3];
            [menuBg setDelegate:self];
            [menuBg setBackgroundColor:[UIColor clearColor]];
            [menuBg setShowsVerticalScrollIndicator:NO];
            [menuBg setContentSize:CGSizeMake(752, 40)];
            [self addSubview:menuBg];
            
            UIButton *btn;
            UILabel *lbl;
            
            for (int i = 0; i < [menuList2 count] + 1; i++) {
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setTag:i];
                if (i == 0) {
                    [btn setImage:[UIImage imageNamed:@"IM_Sub_Tab_All_N"] forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:@"IM_Sub_Tab_All_O"] forState:UIControlStateSelected];
                    
                    [btn setSelected:YES];
                    [btn setUserInteractionEnabled:NO];
                    
                    [btn setFrame:CGRectMake(4, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
                    [btn addTarget:self action:@selector(thumbnailSort:) forControlEvents:UIControlEventTouchUpInside];
                    [menuBg addSubview:btn];
                } else {
                    [btn setImage:[CommonUtil resizedImage:[UIImage imageNamed:@"IM_Sub_TabBG_N"] inRect:CGRectMake(0, 0, 100, 40)] forState:UIControlStateNormal];
                    [btn setImage:[CommonUtil resizedImage:[UIImage imageNamed:@"IM_Sub_TabBG_O"] inRect:CGRectMake(0, 0, 100, 40)] forState:UIControlStateSelected];
                    [btn setSelected:NO];
                    [btn setUserInteractionEnabled:YES];
                    [btn setFrame:CGRectMake(((i * 78) + 4) + ((i - 1) * 22) + i, 0, 100, btn.imageView.image.size.height)];
                }
                [btn addTarget:self action:@selector(thumbnailSort:) forControlEvents:UIControlEventTouchUpInside];
                [menuBg addSubview:btn];
                
                lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
                [lbl setBackgroundColor:[UIColor clearColor]];
                if (i == 0) {
                    [lbl setText:@"All"];
                } else {
                    [lbl setText:[[menuList2 objectAtIndex:i - 1] objectForKey:@"ctgryNm"]];
                }
                [lbl setFont:[UIFont boldSystemFontOfSize:11]];
                [lbl setTextColor:[UIColor whiteColor]];
                [lbl setTextAlignment:NSTextAlignmentCenter];
                [btn addSubview:lbl];
                
                [btnArr addObject:btn];
                
            }
            tabbarSetup = NO;
            
            [self thumbListRequest:1 withTotalPage:4 withMenuIndex:currentMenuIndex withCtgry:2];
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

- (void)returnValue:(NSString *)data withThumbInfo:(NSDictionary *)infoDic {
    NSLog(@"010003 - data : %@, title : %@", data, infoDic);
    //    [target cntntsLoadingStart:@"cntnts"];
//    [self.videoView loadHTMLString:nil baseURL:nil];
    
    if ([[infoDic objectForKey:@"cntntsTyCd"] isEqualToString:@"008001"]) {
//        [self.videoView setHidden:YES];
        [self webviewDelete];
        
        [self.previewImgView setHidden:NO];
        
        [self.previewImgView setImageWithURL:[NSURL URLWithString:[infoDic objectForKey:@"dwldCntntsPath"]]];
        
    } else if ([[infoDic objectForKey:@"cntntsTyCd"] isEqualToString:@"008002"]) {
//        [self.videoView setHidden:NO];
        [self.previewImgView setHidden:YES];
        
        [self webviewDelete];
        
        UIWebView *mediaWebView = [[UIWebView alloc] initWithFrame:CGRectMake(2, 32, self.bounds.size.width - 4, 420)];
        [mediaWebView setDelegate:self];
        [mediaWebView.scrollView setScrollEnabled:NO];
        [mediaWebView.scrollView setBackgroundColor:[UIColor clearColor]];
        [mediaWebView setAllowsInlineMediaPlayback:YES];
        [mediaWebView setMediaPlaybackRequiresUserAction:NO];
        [self addSubview:mediaWebView];
        
        [self bringSubviewToFront:cntntsInfoBox];
        
//        CGRect frame = self.videoView.frame;
        CGRect frame = mediaWebView.frame;
        
//        NSString *embedHTML = [NSString stringWithFormat:@"\
//                               <html>\
//                               <head>\
//                               <style type=\"text/css\">\
//                               </style>\
//                               </head>\
//                               <body style=\"margin:0\"/>\
//                               <iframe id=\"ytplayer\" type=\"text/html\" width=\"%0.0f\" height=\"%0.0f\" src=\"%@?showinfo=0\" frameborder=\"0\"/>\
//                               </html>" , frame.size.width, frame.size.height, [infoDic objectForKey:@"linkUrl"]];
        
        NSRange mp4Search = [[infoDic objectForKey:@"linkUrl"] rangeOfString:@".mp4"];
        
        if (mp4Search.location != NSNotFound) {
            NSString *embedHTML = [NSString stringWithFormat:@"\
                    <html>\
                    <head>\
                    </head>\
                    <body style=\"margin:0\">\
                    <video controls autoplay loop width=\"%0.0f\" height=\"%0.0f\" src=\"%@\"/>\
                    </body>\
                    </html>", frame.size.width, frame.size.height, [infoDic objectForKey:@"linkUrl"]];
            
//            [self.videoView loadHTMLString:embedHTML baseURL:nil];
            [mediaWebView loadHTMLString:embedHTML baseURL:nil];
        } else {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDirectory = [paths objectAtIndex:0];
            NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/YT_Player.html"
                                                                                   , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]]];
//            [self.videoView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:cachePath]]];
            [mediaWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:cachePath]]];
        }
    }
    
    if ([NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"productslist"]] != [NSNull null]) {
        self.listData = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"productslist"]];
    } else {
        [self.listData removeAllObjects];
    }
    
    if ([[infoDic objectForKey:@"hasPrduct"] intValue] == 0) {
        [self.listData removeAllObjects];
        [productListCnt setText:[NSString stringWithFormat:@"( 0 )"]];
    } else {
        if ([NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"productslist"]] != [NSNull null]) {
            self.listData = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"productslist"]];
        } else {
            [self.listData removeAllObjects];
        }
        [productListCnt setText:[NSString stringWithFormat:@"( %d )", [self.listData count]]];
    }
    
    CGSize stringSize = CGSizeZero;
    //    stringSize = [[infoDic objectForKey:@"cntntsNm"] sizeWithFont:[UIFont systemFontOfSize:14.0f]];
    stringSize = [[infoDic objectForKey:@"cntntsNm"] sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(9999, 18) lineBreakMode:NSLineBreakByCharWrapping];
    [previewLbl setFrame:CGRectMake(0, 7, stringSize.width, 18)];
    [previewLbl setText:[infoDic objectForKey:@"cntntsNm"]];
    [previewLbl sizeToFit];
    
    [previewLblScroll setContentSize:CGSizeMake(stringSize.width + 15, 32)];
    
    [cntntsInfoView setText:[infoDic objectForKey:@"cntntsCn"]];
    
    [productListView reloadData];
    
    
    [self thumbnailTouchOnOff:@"on"];
}

- (void)thumbnailSort:(id)sender {
    NSLog(@"sort : %@", sender);
    
    [pageCreate removeAllObjects];
    for (UIView *view in _scrollView.subviews) {
        if ([view isKindOfClass:[ThumbnailView class]]) {
            [view removeFromSuperview];
        }
    }
    
    self.autoSelect = NO;
    
    menuList2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"menulist2"];
    
    for (int i = 0; i < [menuList2 count] + 1; i++) {
        if (((UIButton *)sender).tag == i) {
            [(UIButton *)[btnArr objectAtIndex:i] setSelected:YES];
            [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:NO];
        } else {
            [(UIButton *)[btnArr objectAtIndex:i] setSelected:NO];
            [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:YES];
        }
    }
    
    pageSetup = YES;
    
    if (((UIButton *)sender).tag == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thumblist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self thumbListRequest:1 withTotalPage:4 withMenuIndex:((UIButton *)sender).tag withCtgry:2];
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thumblist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self thumbListRealignRequest:1 withTotalPage:4 withMenuIndex:((UIButton *)sender).tag];
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)thumbListRealignRequest:(int)currentIndex withTotalPage:(int)totalCnt withMenuIndex:(int)menuIndex {
    //                      withCtgry:(int)ctgryIndex {
    //    [pageCreate setObject:@"yes" forKey:[NSString stringWithFormat:@"페이지%d", currentIndex]];
    
    [target cntntsLoadingStart:nil];
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=%@&timestamp=%0.f"
                     , KHOST
                     , PAGEDLISTCNTNTSINFO
                     , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                     , [[[[NSUserDefaults standardUserDefaults] objectForKey:@"menulist2"] objectAtIndex:menuIndex - 1] objectForKey:@"ctgryId"]
                     , currentIndex
                     , totalCnt
                     , [temp hexadecimalString]
                     , timeInMiliseconds];
    
    httpRequest *_httpRequest = [[httpRequest alloc] init];
    [_httpRequest setDelegate:self selector:@selector(createComponents:)];
    [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
}

- (void)thumbnailTouchOnOff:(NSString *)onoff {
    NSLog(@"onoff : %@", onoff);
    
    if ([onoff isEqualToString:@"off"]) {
        [target cntntsLoadingStart:nil];
    } else {
        [target cntntsLoadingStop];
    }
}

- (void)webviewDelete {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIWebView class]]) {
            [((UIWebView *)view) loadHTMLString:nil baseURL:nil];
            [((UIWebView *)view) setDelegate:nil];
            [view removeFromSuperview];
        }
    }
}

#pragma mark -

- (void)clickedThumbnail:(ThumbnailView*)view {
    
}

#pragma mark Web view delegate


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [listData count];
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
    
    NSDictionary *item = [self.listData objectAtIndex:indexPath.row];
    
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
    NSString *prductCd = [[listData objectAtIndex:indexPath.row] objectForKey:@"prductCd"];
    
    [target performSelector:@selector(detailProduct:) withObject:prductCd];
}

//- (void)detailProduct:(id)sender {
//    [target performSelector:@selector(detailProduct:) withObject:sender];
//}

#pragma mark - Scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1) {
        CGFloat pageWidth = scrollView.frame.size.width;
        [_pageC setCurrentPage:floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1];
        
        if ([[[UIDevice currentDevice] systemVersion] intValue] < 7) {
            for (int i = 0; i < [_pageC.subviews count]; i++) {
                if (floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1 == i) {
                    ((UIImageView *)[[_pageC subviews] objectAtIndex:i]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_O"];
                } else {
                    ((UIImageView *)[[_pageC subviews] objectAtIndex:i]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_N"];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"did end decelerating");
    if (scrollView.tag == 1) {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSLog(@"current page : %f", floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2);
        
        int temp = floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2;
        
        int btnIndex = 0;
        
        for (int i = 0; i < [btnArr count]; i++) {
            if (((UIButton *)[btnArr objectAtIndex:i]).selected) {
                btnIndex = i;
            }
        }
        
        if ([[pageCreate objectForKey:[NSString stringWithFormat:@"페이지%d", temp]] isEqualToString:@"yes"]) {
            
        } else {
            if (btnIndex == 0) {
                [self thumbListRequest:floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2
                         withTotalPage:[[[[NSKeyedUnarchiver unarchiveObjectWithData:[[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] objectForKey:@"page1"]] objectForKey:@"pagingProperty"] objectForKey:@"maxResults"] intValue]
                         withMenuIndex:currentMenuIndex
                             withCtgry:[[[menuList1 objectAtIndex:currentMenuIndex] objectForKey:@"isLeaf"] intValue]];
            } else {
                [self thumbListRealignRequest:floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2
                                withTotalPage:[[[[NSKeyedUnarchiver unarchiveObjectWithData:[[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] objectForKey:@"page1"]] objectForKey:@"pagingProperty"] objectForKey:@"maxResults"] intValue]
                                withMenuIndex:btnIndex];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"did end dragging");
    if (scrollView.tag == 1) {
        if (scrollView.contentOffset.x < 0) {
            thumbBgCheck = NO;
            
            for (UIView *view in _scrollView.subviews) {
                if (view.tag == 187 || view.tag == 148 || view.tag == 361) {
                    [view removeFromSuperview];
                }
            }

            [pageCreate removeAllObjects];
            for (UIView *view in _scrollView.subviews) {
                if ([view isKindOfClass:[ThumbnailView class]]) {
                    [view removeFromSuperview];
                }
            }
        }
    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [target performSelector:@selector(goHome)];
    } else {
        [self thumbListRequest:1 withTotalPage:4 withMenuIndex:currentMenuIndex withCtgry:1];
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
