//
//  ViewType_010000.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 28..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "ViewType_010000.h"
//
#import "httpRequest.h"
#import "ThumbnailView.h"
//
#import "ContentManager.h"
#import "CommonUtil.h"
#import "NSData+AESAdditions.h"

#define PDF_DOWN_YN_ALERT_TAG   100     //PDF 다운로드여부 팝업

@implementation ViewType_010000
@synthesize target;
@synthesize selector;
@synthesize selectedItemInfo;
@synthesize contentManager;
@synthesize drawItemInfo = _drawItemInfo;
@synthesize colums = _colums;
@synthesize row = _row;
@synthesize thumbH = _thumbH;
@synthesize thumbW = _thumbW;
@synthesize thumbWidth = _thumbWidth;
@synthesize thumbHeight = _thumbHeight;

//@synthesize btnIdx = _btnIdx;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        btnArr = [[NSMutableArray alloc] init];
        titleBtnArr = [[NSMutableArray alloc] init];
        
        if ([[[GlobalValue sharedSingleton] value] isEqualToString:@"contents"]) {
            menuList1 = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"menulist1"]];
        } else {
            menuList1 = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"edumenulist2"]];
        }
        
        menuList2 = [[NSMutableArray alloc] init];
        
        thumbArr = [[NSMutableArray alloc] init];
        
        _scrollView = [[UIScrollView alloc] init];
        [_scrollView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 20)];
        [_scrollView setDelegate:self];
        [_scrollView setTag:1];
        [_scrollView setBackgroundColor:[UIColor clearColor]];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setPagingEnabled:YES];
        [self addSubview:_scrollView];
        
        _pageC = [[UIPageControl alloc] init];
        [_pageC setFrame:CGRectMake(self.bounds.size.width/2 - _pageC.bounds.size.width/2, self.bounds.size.height, _pageC.bounds.size.width, _pageC.bounds.size.height)];
        [_pageC setCurrentPage:0];
        [self addSubview:_pageC];
        
        pageSetup = YES;
        tabbarSetup = YES;
        
        pageCreate = [[NSMutableDictionary alloc] init];
        
        currentMenuIndex = 0;
        
        NSString *thumbKind = @"";
        if ([[[GlobalValue sharedSingleton] value] isEqualToString:@"contents"]) {
            thumbKind = @"thumblist";
        } else {
            thumbKind = @"eduthumblist";
        }
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:thumbKind];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return self;
}

- (void)thumbListRequest:(int)currentIndex withTotalPage:(int)totalCnt withMenuIndex:(int)menuIndex withCtgry:(int)ctgryIndex {
    [target cntntsLoadingStart:nil];
    
    [pageCreate setObject:@"yes" forKey:[NSString stringWithFormat:@"페이지%d", currentIndex]];
    //    if (ctgryIndex == 1) {
    //        currentMenuIndex = menuIndex + 1;
    //    } else {
    //        currentMenuIndex = menuIndex;
    //    }
    
    currentMenuIndex = menuIndex;
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (ctgryIndex == 1) {
        if (menuIndex == 0) {
            if ([[self.drawItemInfo objectForKey:@"isLeaf"] intValue] == 1) {
                NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=%@&timestamp=%0.f"
                                 , KHOST
                                 , PAGEDLISTALLCNTNTSINFO
                                 , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                 , [[menuList1 objectAtIndex:0] objectForKey:@"ctgryId"]
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
                                 , [[menuList1 objectAtIndex:0] objectForKey:@"upCtgryId"]
                                 , currentIndex
                                 , totalCnt
                                 , [temp hexadecimalString]
                                 , timeInMiliseconds];
                
                httpRequest *_httpRequest = [[httpRequest alloc] init];
                [_httpRequest setDelegate:self selector:@selector(createComponents:)];
                [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
            }
        } else {
            if ([[[menuList1 objectAtIndex:menuIndex - 1] objectForKey:@"isLeaf"] intValue] == 1) {
                NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=%@&timestamp=%0.f"
                                 , KHOST
                                 , PAGEDLISTCNTNTSINFO
                                 , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                 , [[menuList1 objectAtIndex:menuIndex - 1] objectForKey:@"ctgryId"]
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
                                 , [[menuList1 objectAtIndex:menuIndex - 1] objectForKey:@"ctgryId"]
                                 , currentIndex
                                 , totalCnt
                                 , [temp hexadecimalString]
                                 , timeInMiliseconds];
                
                httpRequest *_httpRequest = [[httpRequest alloc] init];
                [_httpRequest setDelegate:self selector:@selector(createComponentsWithCtgry:)];
                [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
            }
            
        }
    } else {
        if (menuIndex == 0) {
            if ([[self.drawItemInfo objectForKey:@"isLeaf"] intValue] == 1) {
                NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=%@&timestamp=%0.f"
                                 , KHOST
                                 , PAGEDLISTALLCNTNTSINFO
                                 , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                 , [[menuList1 objectAtIndex:0] objectForKey:@"ctgryId"]
                                 , currentIndex
                                 , totalCnt
                                 , [temp hexadecimalString]
                                 , timeInMiliseconds];
                
                httpRequest *_httpRequest = [[httpRequest alloc] init];
                [_httpRequest setDelegate:self selector:@selector(createComponents:)];
                [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
            } else {
                NSString *url = @"";
                if ([menuList2 count] != 0) {
                    url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=%@&timestamp=%0.f"
                           , KHOST
                           , PAGEDLISTALLCNTNTSINFO
                           , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                           , [[menuList2 objectAtIndex:0] objectForKey:@"upCtgryId"]
                           , currentIndex
                           , totalCnt
                           , [temp hexadecimalString]
                           , timeInMiliseconds];
                } else {
                    url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=%@&timestamp=%0.f"
                           , KHOST
                           , PAGEDLISTALLCNTNTSINFO
                           , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                           , [[menuList1 objectAtIndex:0] objectForKey:@"upCtgryId"]
                           , currentIndex
                           , totalCnt
                           , [temp hexadecimalString]
                           , timeInMiliseconds];
                }
                
                httpRequest *_httpRequest = [[httpRequest alloc] init];
                [_httpRequest setDelegate:self selector:@selector(createComponents:)];
                [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
            }
        } else {
            if ([[[menuList1 objectAtIndex:menuIndex - 1] objectForKey:@"isLeaf"] intValue] == 1) {
                NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=%@&timestamp=%0.f"
                                 , KHOST
                                 , PAGEDLISTCNTNTSINFO
                                 , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                 , [[menuList1 objectAtIndex:menuIndex - 1] objectForKey:@"ctgryId"]
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
                                 , [[menuList2 objectAtIndex:0] objectForKey:@"upCtgryId"]
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
}

- (void)doNetworkErrorProcess {
    NSLog(@"010000 error");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"KOLON" message:@"네트워크가 불안정합니다.\n다시 시도하시겠습니까?" delegate:self cancelButtonTitle:@"메인" otherButtonTitles:@"다시 시도", nil];
    [alertView show];
}

- (void)createComponents:(NSString *)data {
    NSLog(@"010000 data : %@", data);
    
    //    int thumbW = 0;
    //    int thumbH = 24;
    
    //    int thumbWidth = 187;
    //    int thumbHeight = 171;
    
    //    int thumbWidth = 144;
    //    int thumbHeight = 144;
    
    //    self.colums = 4;
    //    self.row = 4;
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            NSString *thumbKind = @"";
            if ([[[GlobalValue sharedSingleton] value] isEqualToString:@"contents"]) {
                thumbKind = @"thumblist";
            } else {
                thumbKind = @"eduthumblist";
            }
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:thumbKind] != nil) {
                BOOL samePage = NO;
                
                for (id key in [[[NSUserDefaults standardUserDefaults] objectForKey:thumbKind] allKeys]) {
                    if ([key isEqualToString:[NSString stringWithFormat:@"page%d", [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"currentPage"] intValue]]]) {
                        NSLog(@"같은게 있음");
                        samePage = YES;
                    }
                }
                
                if (samePage == NO) {
                    NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:thumbKind]];
                    
                    [temp setObject:[NSKeyedArchiver archivedDataWithRootObject:resultsDictionary] forKey:[NSString stringWithFormat:@"page%d", [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"currentPage"] intValue]]];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:temp forKey:thumbKind];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            } else {
                NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSKeyedArchiver archivedDataWithRootObject:resultsDictionary], [NSString stringWithFormat:@"page%d", [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"currentPage"] intValue]], nil];
                
                [[NSUserDefaults standardUserDefaults] setObject:temp forKey:thumbKind];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            NSArray *resultList = [resultsDictionary objectForKey:@"list"];
            NSDictionary *resultpageInfo = [resultsDictionary objectForKey:@"pagingProperty"];
            ThumbnailView *thumbnailView;
            
            if (currentMenuIndex == 0) {    //all
                tabbarSetup = NO;
            } else {
                tabbarSetup = YES;
            }
            
            if (!thumbBgCheck) {
                UIImageView *baseView;
                for (int i = 0; i < [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"countItem"] intValue]; i++) {
                    if (_thumbWidth == 187) {
                        baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_ThumbBG"]];
                        [baseView setTag:187];
                        [baseView setUserInteractionEnabled:YES];
                        [baseView setFrame:CGRectMake((((i / (_colums * _row)) * [UIScreen mainScreen].bounds.size.width) - ((i / (_colums * _row)) * 20)) + (i % _colums) * _thumbWidth + ((i % _colums) * _thumbW)
                                                      , ((i % (_colums * _row)) / _colums) * _thumbHeight + (((i % (_colums * _row)) / _colums) * _thumbH)
                                                      , baseView.image.size.width
                                                      , baseView.image.size.height)];
                    } else if (_thumbWidth == 148) {
                        baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LBK_ThumbBG"]];
                        [baseView setUserInteractionEnabled:YES];
                        [baseView setTag:148];
                    } else if (_thumbWidth == 361) {
                        baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_PR_ThumbBG"]];
                        [baseView setUserInteractionEnabled:YES];
                        [baseView setTag:361];
                        [self addSubview:baseView];
                    }
                    [baseView setFrame:CGRectMake((((i / (_colums * _row)) * [UIScreen mainScreen].bounds.size.width) - ((i / (_colums * _row)) * 20)) + (i % _colums) * _thumbWidth + ((i % _colums) * _thumbW)
                                                  , ((i % (_colums * _row)) / _colums) * _thumbHeight + (((i % (_colums * _row)) / _colums) * _thumbH)
                                                  , baseView.image.size.width
                                                  , baseView.image.size.height)];
                    [_scrollView addSubview:baseView];
                }
                thumbBgCheck = YES;
            }
            
            if (tabbarSetup) {
                [_scrollView setFrame:CGRectMake(0, 52, self.bounds.size.width, self.bounds.size.height - 52)];
                [_scrollView setContentSize:CGSizeMake(self.bounds.size.width * [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"countPage"] intValue], self.bounds.size.height - 52)];
                
                menuBg = [[UIScrollView alloc] initWithFrame:CGRectMake(-2, 0, 752, 40)];
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
                    [thumbnailView setThumbTag:((_colums * _row) * ([[resultpageInfo objectForKey:@"currentPage"] intValue] - 1)) + i + 1];
                    
                    [thumbnailView setFrame:CGRectMake(((([[resultpageInfo objectForKey:@"currentPage"] intValue] - 1) * [UIScreen mainScreen].bounds.size.width) - (([[resultpageInfo objectForKey:@"currentPage"] intValue] - 1) * 20)) + (i % _colums) * _thumbWidth + ((i % _colums) * _thumbW)
                                                       , (i / _colums) * _thumbHeight + ((i / _colums) * _thumbH)
                                                       , _thumbWidth, _thumbHeight)];
                    
                    [thumbnailView dnThumbImg:[NSString stringWithFormat:@"%@/%@", [self.drawItemInfo objectForKey:@"upCtgryId"], [self.drawItemInfo objectForKey:@"ctgryId"]]];
                    [thumbnailView setCurrentScrinTyCd:[self.drawItemInfo objectForKey:@"scrinTyCd"]];
                    
                    if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010001"]) {
                        [thumbnailView setDelegate:self selector:nil];
                    } else if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010002"]) {
                        [thumbnailView setDelegate:self selector:nil];
                    } else if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010003"]) {
                        [thumbnailView setDelegate:self selector:nil];
                    } else if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010004"]) {
                        [thumbnailView setDelegate:self selector:nil];
                    } else {
                        
                    }
                    
                    [_scrollView addSubview:thumbnailView];
                    [thumbArr addObject:thumbnailView];
                }
                
                tabbarSetup = NO;
            } else {
                if (menuList2) {
                    [_scrollView setContentSize:CGSizeMake(self.bounds.size.width * [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"countPage"] intValue], self.bounds.size.height - 52)];
                } else {
                    [_scrollView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 20)];
                    [_scrollView setContentSize:CGSizeMake(self.bounds.size.width * [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"countPage"] intValue], self.bounds.size.height - 20)];
                }
                
                for (int i = 0; i < [resultList count]; i++) {
                    thumbnailView = [[ThumbnailView alloc] init];
                    thumbnailView.thumbnailDic = [resultList objectAtIndex:i];
                    [thumbnailView setThumbTag:((_colums * _row) * ([[resultpageInfo objectForKey:@"currentPage"] intValue] - 1)) + i + 1];
                    
                    [thumbnailView setFrame:CGRectMake(((([[resultpageInfo objectForKey:@"currentPage"] intValue] - 1) * [UIScreen mainScreen].bounds.size.width) - (([[resultpageInfo objectForKey:@"currentPage"] intValue] - 1) * 20)) + (i % _colums) * _thumbWidth + ((i % _colums) * _thumbW)
                                                       , (i / _colums) * _thumbHeight + ((i / _colums) * _thumbH)
                                                       , _thumbWidth
                                                       , _thumbHeight)];
                    
                    [thumbnailView setCurrentScrinTyCd:[self.drawItemInfo objectForKey:@"scrinTyCd"]];
                    
                    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                    dispatch_async(dispatchQueue, ^(void) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [thumbnailView dnThumbImg:[NSString stringWithFormat:@"%@/%@", [self.drawItemInfo objectForKey:@"upCtgryId"], [self.drawItemInfo objectForKey:@"ctgryId"]]];
                        });
                        
                        if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010001"]) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [thumbnailView dnCntImg:[NSString stringWithFormat:@"%@/%@", [self.drawItemInfo objectForKey:@"upCtgryId"], [self.drawItemInfo objectForKey:@"ctgryId"]]];
                            });
                            [thumbnailView setDelegate:self selector:nil];
                        } else if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010002"]) {
                            [thumbnailView setDelegate:self selector:nil];
                        } else if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010003"]) {
                            [thumbnailView setDelegate:self selector:nil];
                        } else if ([[self.drawItemInfo objectForKey:@"scrinTyCd"] isEqualToString:@"010004"]) {
                            [thumbnailView setDelegate:self selector:nil];
                        } else {
                            
                        }
                    });
                    
                    [_scrollView addSubview:thumbnailView];
                    [thumbArr addObject:thumbnailView];
                }
            }
            
            if (pageSetup) {
                int thumbCount = [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"countItem"] intValue];
                int page = [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"maxResults"] intValue];
                
                NSLog(@"%d, %d", thumbCount, page);
                
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
    NSLog(@"010000 ctgry data : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            if ([[[GlobalValue sharedSingleton] value] isEqualToString:@"contetns"]) {
                [[NSUserDefaults standardUserDefaults] setObject:[resultsDictionary objectForKey:@"results"] forKey:@"menulist2"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:[resultsDictionary objectForKey:@"results"] forKey:@"edumenulist3"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }

            menuList2 = [resultsDictionary objectForKey:@"results"];
            
            if (currentMenuIndex != 0) {
                [_scrollView setBackgroundColor:[UIColor clearColor]];
                [_scrollView setFrame:CGRectMake(0, 52, self.bounds.size.width, self.bounds.size.height - 52)];
                
                menuBg = [[UIScrollView alloc] initWithFrame:CGRectMake(-2, 0, 752, 40)];
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
            }
            [self thumbListRequest:1 withTotalPage:_row * _colums withMenuIndex:0 withCtgry:2];
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

- (void)thumbnailSort:(id)sender {
    NSLog(@"sort : %@", sender);
    
    [pageCreate removeAllObjects];
    for (UIView *view in _scrollView.subviews) {
        if ([view isKindOfClass:[ThumbnailView class]]) {
            [view removeFromSuperview];
        }
    }
    
    NSString *thumbKind = @"";
    if ([[[GlobalValue sharedSingleton] value] isEqualToString:@"contents"]) {
        thumbKind = @"thumblist";
        menuList2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"menulist2"];
    } else {
        thumbKind = @"eduthumblist";
        menuList2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"edumenulist3"];
    }
    
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
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:thumbKind];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self thumbListRequest:1 withTotalPage:_row * _colums withMenuIndex:((UIButton *)sender).tag withCtgry:2];
        
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:thumbKind];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self thumbListRealignRequest:1 withTotalPage:_row * _colums withMenuIndex:((UIButton *)sender).tag];
        
        
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)thumbListRealignRequest:(int)currentIndex withTotalPage:(int)totalCnt withMenuIndex:(int)menuIndex {
    //                      withCtgry:(int)ctgryIndex {
    [pageCreate setObject:@"yes" forKey:[NSString stringWithFormat:@"페이지%d", currentIndex]];
    
    [target cntntsLoadingStart:nil];
    
    NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=DAA88002E4C06D2EEF7C01690A17C9E4BE721825455A973B59A006C695298A12&timestamp=1377221715487"
                     , KHOST
                     , PAGEDLISTCNTNTSINFO
                     , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                     , [[menuList2 objectAtIndex:menuIndex - 1] objectForKey:@"ctgryId"]
                     , currentIndex
                     , totalCnt];
    
    httpRequest *_httpRequest = [[httpRequest alloc] init];
    [_httpRequest setDelegate:self selector:@selector(createComponents:)];
    [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
}

- (void)setDelegate:(id)aTarget selector:(SEL)aSelector {
    self.target = aTarget;
    self.selector = aSelector;
}

//- (void)thumbnailTouch:(id)sender {
//    NSLog(@"sender ; %@", sender);
//
//    if ([((NSNotification *)sender).object isEqualToString:@"no"]) {
//        for (UIView *view in thumbArr) {
//            [view setUserInteractionEnabled:NO];
//        }
//    }
//}

#pragma mark - Scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    if (scrollView.tag == 1) {
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"did end decelerating");
    //    if (scrollView.tag == 1) {
    CGFloat pageWidth = scrollView.frame.size.width;
    
    int temp = floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2;
    
    int btnIndex = 0;
    
    for (int i = 0; i < [btnArr count]; i++) {
        if (((UIButton *)[btnArr objectAtIndex:i]).selected) {
            btnIndex = i;
        }
    }
    
    if (btnIndex == 0) {
        
    } else {
        
    }
    
    if ([[pageCreate objectForKey:[NSString stringWithFormat:@"페이지%d", temp]] isEqualToString:@"yes"]) {
        
    } else {
        if (btnIndex == 0) {    //하위 카테고리가 없는 리스트 갱신 (all)
            [self thumbListRequest:floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2
             //                     withTotalPage:[[[[NSKeyedUnarchiver unarchiveObjectWithData:[[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] objectForKey:@"page1"]] objectForKey:@"pagingProperty"] objectForKey:@"maxResults"] intValue]
                     withTotalPage:_row * _colums
                     withMenuIndex:currentMenuIndex
                         withCtgry:[[self.drawItemInfo objectForKey:@"isLeaf"] intValue]];
            //                         withCtgry:[[[menuList1 objectAtIndex:currentMenuIndex] objectForKey:@"isLeaf"] intValue]];
            
        } else {    //하위 카테고리가 있는 리스트 갱신
            [self thumbListRealignRequest:floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2
             //                            withTotalPage:[[[[NSKeyedUnarchiver unarchiveObjectWithData:[[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] objectForKey:@"page1"]] objectForKey:@"pagingProperty"] objectForKey:@"maxResults"] intValue]
                            withTotalPage:_row * _colums
                            withMenuIndex:btnIndex];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"did end dragging");
    if (scrollView.contentOffset.x < 0) {
        [target cntntsLoadingStart:nil];
        tabbarSetup = NO;
        pageSetup = YES;
        thumbBgCheck = NO;
        
        for (UIView *view in _scrollView.subviews) {
            if (view.tag == 187 || view.tag == 148 || view.tag == 361) {
                [view removeFromSuperview];
            }
        }
        
        [_pageC removeFromSuperview];
        
        _pageC = [[UIPageControl alloc] init];
        [_pageC setFrame:CGRectMake(self.bounds.size.width/2 - _pageC.bounds.size.width/2, self.bounds.size.height - 10, _pageC.bounds.size.width, _pageC.bounds.size.height)];
        [_pageC setCurrentPage:0];
        [self addSubview:_pageC];
        
        [pageCreate removeAllObjects];
        for (UIView *view in _scrollView.subviews) {
            if ([view isKindOfClass:[ThumbnailView class]]) {
                [view removeFromSuperview];
            }
        }
    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == PDF_DOWN_YN_ALERT_TAG) {   //PDF 다운로드여부 팝업
        if (buttonIndex == 0) {
            return;
        }else {
            
            NSString *downURL = [self.selectedItemInfo objectForKey:@"dwldCntntsPath"];
            if (downURL != nil) {
                //1. 다운로드
                self.contentManager = [[ContentManager alloc] init];
                contentManager.delegate = self;
                [contentManager DownloadServerFile:downURL];
            }
        }
        
    } else {
        if (buttonIndex == 0) {
            [target performSelector:@selector(goHome)];
        } else {
            tabbarSetup = YES;
            
            [self thumbListRequest:1 withTotalPage:_row * _colums withMenuIndex:0 withCtgry:1];
        }
    }
}


#pragma mark - Thumbnanil view delegate

- (void)clickedThumbnail:(ThumbnailView*)view {
    NSLog(@"thumbnail delegate");
    if (view == nil) {
        return;
    }
    self.selectedItemInfo = view.thumbnailDic;
    
    NSString *contentsType = [selectedItemInfo objectForKey:@"cntntsTyNm"];
    if ([contentsType isEqualToString:@"PDF"]) {
        //1)선택한 pdf파일이 로컬경로에 존재하면 로드한다.
        //NSString *ctgryNm = [list objectForKey:@"ctgryNm"];
        NSString *fileDownURL = [selectedItemInfo objectForKey:@"dwldCntntsPath"];
        NSString *fileName = [[fileDownURL componentsSeparatedByString:@"/"] lastObject];
        
        NSLog(@"fileDownURL : %@",fileDownURL);
        
        //2)선택한 pdf파일이 존재하지 않는다면 서버로부터 pdf파일을 다운로드 받은후 로드한다.
        BOOL bExistFile = [ContentManager isExistLocalFile:fileName TARGET:SAVE_PDF];
        if (YES == bExistFile) {
            NSLog(@"file exist");
            // 사보 화면 호출
            [target performSelectorOnMainThread:@selector(loadLocalPdfView:) withObject:selectedItemInfo waitUntilDone:NO];
        } else {
            NSLog(@"file Not exist");
            
            //네트워크 상태
            BOOL bState = [CommonUtil getNetworkState];
            
            NSString* statusString= @"";
            
            if (bState ==0 ) {
                statusString = @"네트웍이 연결 되지 않았습니다.";
                
                UIAlertView    *alertView = [[UIAlertView alloc]
                                             initWithTitle: @"Network Message"
                                             message: statusString
                                             delegate: nil
                                             cancelButtonTitle: @"확인" otherButtonTitles: nil];
                [alertView show];
                
            }
            else if (bState == 1) {
                
                statusString= @"3G 상태에서는 데이터 요금이\r부가됩니다.\r 다운로드 하시 겠습니까?";
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림!" message:statusString delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인",nil];
                [alert setTag:PDF_DOWN_YN_ALERT_TAG];
                [alert show];
            }
            else if (bState == 2) {
                statusString= @"다운로드 하시 겠습니까?";
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림!" message:statusString delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인",nil];
                [alert setTag:PDF_DOWN_YN_ALERT_TAG];
                [alert show];
                
            }
            
        }
    } else if ([contentsType isEqualToString:@"이미지"]) {
        [target performSelector:@selector(loadImageView:withDir:) withObject:selectedItemInfo withObject:view.subDir];
    } else if ([contentsType isEqualToString:@"이미지+링크"]) {
        [target performSelector:@selector(loadImageWithLinkView:) withObject:selectedItemInfo];
    } else if ([contentsType isEqualToString:@"동영상"]) {
        [target performSelector:@selector(loadVideoView:) withObject:selectedItemInfo];
    } else {
        
    }
}

- (void)thumbnailTouchOnOff:(NSString *)onoff {
    NSLog(@"viewtype 010000 - onoff : %@", onoff);
    
    [target cntntsLoadingStart:nil];
    //    if ([onoff isEqualToString:@"off"]) {
    //        for (UIView *view in thumbArr) {
    //            [view setUserInteractionEnabled:NO];
    //        }
    //    } else {
    //        for (UIView *view in thumbArr) {
    //            [view setUserInteractionEnabled:YES];
    //        }
    //    }
}

#pragma mark - ContentManagerDelegate
- (void)contentManager:(ContentManager*)contentMgr didFinish:(NSString*) fileName
{
    // 사보 화면 호출
    [target performSelectorOnMainThread:@selector(loadLocalPdfView:) withObject:selectedItemInfo waitUntilDone:NO];
}

- (void)downloadImgChange {
    for (UIView *view in _scrollView.subviews) {
        if ([view isKindOfClass:[ThumbnailView class]]) {
//            NSLog(@"view ; %@, %d, %d", view, ((ThumbnailView *)view).thumbTag, ((ThumbnailView *)view).selectedTag);
            if (((ThumbnailView *)view).selectedTag != 0) {
                [((ThumbnailView *)view).pdfDownloadImg setHighlighted:YES];
            }
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
