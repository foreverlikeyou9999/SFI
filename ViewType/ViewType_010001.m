//
//  ViewType_010001.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 28..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "ViewType_010001.h"
//
#import "httpRequest.h"
//
#import "ThumbnailView.h"

@implementation ViewType_010001
@synthesize target;
@synthesize selector;
@synthesize videoView = _videoView;
@synthesize autoSelect = _autoSelect;
@synthesize dep1menuIndex = _dep1menuIndex;

#pragma mark - Life cycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - public method

#pragma mark - private method
- (void)setDelegate:(id)aTarget selector:(SEL)aSelector {
    self.target = aTarget;
    self.selector = aSelector;
}

- (void)thumbListRequest:(int)currentIndex withTotalPage:(int)totalCnt withMenuIndex:(int)menuIndex withCtgry:(int)ctgryIndex {
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (ctgryIndex == 1) {
        if ([[[menuList1 objectAtIndex:menuIndex] objectForKey:@"isLeaf"] intValue] == 1) {
            NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=DAA88002E4C06D2EEF7C01690A17C9E4BE721825455A973B59A006C695298A12&timestamp=1377221715487"
                             , KHOST
                             , PAGEDLISTCNTNTSINFO
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                             , [[[[NSUserDefaults standardUserDefaults] objectForKey:@"menulist1"] objectAtIndex:menuIndex] objectForKey:@"ctgryId"]
                             , currentIndex
                             , totalCnt];
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(createComponents:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        } else {
            NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=DAA88002E4C06D2EEF7C01690A17C9E4BE721825455A973B59A006C695298A12&timestamp=1377221715487"
                             , KHOST
                             , LISTCTGYINFODATA
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                             , [[[[NSUserDefaults standardUserDefaults] objectForKey:@"menulist1"] objectAtIndex:menuIndex] objectForKey:@"ctgryId"]
                             , currentIndex
                             , totalCnt];
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(createComponentsWithCtgry:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        }
    } else {
        if ([[[menuList1 objectAtIndex:menuIndex] objectForKey:@"isLeaf"] intValue] == 1) {
            NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=DAA88002E4C06D2EEF7C01690A17C9E4BE721825455A973B59A006C695298A12&timestamp=1377221715487"
                             , KHOST
                             , PAGEDLISTCNTNTSINFO
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                             , [[menuList1 objectAtIndex:menuIndex] objectForKey:@"ctgryId"]
                             , currentIndex
                             , totalCnt];
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(createComponents:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        } else {
            NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=DAA88002E4C06D2EEF7C01690A17C9E4BE721825455A973B59A006C695298A12&timestamp=1377221715487"
                             , KHOST
                             , PAGEDLISTALLCNTNTSINFO
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                             , [[[[NSUserDefaults standardUserDefaults] objectForKey:@"menulist2"] objectAtIndex:0] objectForKey:@"upCtgryId"]
                             , currentIndex
                             , totalCnt];
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(createComponents:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        }
    }
}

- (void)doNetworkErrorProcess {
    NSLog(@"010001 error");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"KOLON" message:@"네트워크가 불안정합니다.\n다시 시도하시겠습니까?" delegate:self cancelButtonTitle:@"메인" otherButtonTitles:@"다시 시도", nil];
    [alertView show];
}

- (void)createComponents:(NSString *)data {
    NSLog(@"010001 data : %@", data);
    
    ThumbnailView *thumbnailView;
    
    int thumbW = 0;
    int thumbH = 15;
    
    int thumbWidth = 187;
    int thumbHeight = 171;
    
    for (UIView *view in _scrollView.subviews) {
        if ([view isKindOfClass:[ThumbnailView class]]) {
            [view removeFromSuperview];
        }
    }
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        if ([[[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"] isEqualToString:@"200"]) {
                        
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:resultsDictionary] forKey:@"thumblist"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSArray *resultList = [resultsDictionary objectForKey:@"list"];
            NSDictionary *resultpageInfo = [resultsDictionary objectForKey:@"pagingProperty"];
            
            if (tabbarSetup) {
                UIImageView *menuBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Img_TabBarBG"]];
                [menuBg setFrame:CGRectMake(0, 450, menuBg.image.size.width, menuBg.image.size.height)];
                [menuBg setUserInteractionEnabled:YES];
                [self addSubview:menuBg];
                
                UIButton *btn;
                UILabel *lbl;
                
                for (int i = 0; i < 1; i++) {
                    btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btn setTag:3+i];
                    [btn setImage:[UIImage imageNamed:@"IM_Img_TabBar_Normal01"] forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:@"IM_Img_TabBarSelected01"] forState:UIControlStateSelected];
                    [btn setFrame:CGRectMake(i * btn.imageView.image.size.width, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
                    //                [btn addTarget:self action:@selector(thumbnailSort:) forControlEvents:UIControlEventTouchUpInside];
                    if (i == 0) {
                        [btn setSelected:YES];
                    } else {
                        [btn setSelected:NO];
                    }
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
                    
                    [thumbnailView setFrame:CGRectMake(((([[resultpageInfo objectForKey:@"currentPage"] intValue] - 1) * [UIScreen mainScreen].bounds.size.width) - (([[resultpageInfo objectForKey:@"currentPage"] intValue] - 1) * 20)) + (i % 4) * thumbWidth + ((i % 4) * thumbW), (i / 4) * thumbHeight + ((i / 4) * thumbH), thumbWidth, thumbHeight)];
                    [thumbnailView dnThumbImg:[[menuList1 objectAtIndex:0] objectForKey:@"upCtgryId"]];
                    
                    [thumbnailView setDelegate:self selector:@selector(returnValue:withTitle:)];
                    
                    if (self.autoSelect) {
                        if (i == 0) {
                            [thumbnailView typeSort];
                            [loading startAnimating];
                        }
                    }
                    [_scrollView addSubview:thumbnailView];
                }
                tabbarSetup = NO;
            } else {
                for (int i = 0; i < [resultList count]; i++) {
                    thumbnailView = [[ThumbnailView alloc] init];
                    thumbnailView.thumbnailDic = [resultList objectAtIndex:i];
                    
                    [thumbnailView setFrame:CGRectMake(((([[resultpageInfo objectForKey:@"currentPage"] intValue] - 1) * [UIScreen mainScreen].bounds.size.width) - (([[resultpageInfo objectForKey:@"currentPage"] intValue] - 1) * 20)) + (i % 4) * thumbWidth + ((i % 4) * thumbW), (i / 4) * thumbHeight + ((i / 4) * thumbH), thumbWidth, thumbHeight)];
                    [thumbnailView dnThumbImg:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"menulist2"] objectAtIndex:0] objectForKey:@"upCtgryId"]];
                    
                    [thumbnailView setDelegate:self selector:@selector(returnValue:withTitle:)];
                    if (self.autoSelect) {
                        if (i == 0) {
                            [thumbnailView typeSort];
                            [loading startAnimating];
                        }
                    }
                    [_scrollView addSubview:thumbnailView];
                }
            }
        }
    } else {
        
    }
    
    if (pageSetup) {
        int thumbCount = [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"countItem"] intValue];
        int page = [[[resultsDictionary objectForKey:@"pagingProperty"] objectForKey:@"maxResults"] intValue];
        
        if (thumbCount > page) {
            if (thumbCount%page == 0) {
                [_pageC setNumberOfPages:thumbCount/page];
                [_scrollView setContentSize:CGSizeMake(self.bounds.size.width+(((thumbCount/page)-1)*self.bounds.size.width), self.bounds.size.height - 300)];
            } else {
                [_pageC setNumberOfPages:thumbCount/page + 1];
                [_scrollView setContentSize:CGSizeMake(self.bounds.size.width+((thumbCount/page)*self.bounds.size.width), self.bounds.size.height - 300)];
            }
        } else {
            [_pageC setNumberOfPages:1];
            [_scrollView setContentSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height - 300)];
        }
        
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
        pageSetup = NO;
    }
}

- (void)createComponentsWithCtgry:(NSString *)data {
    NSLog(@"010001 ctgry data : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        if ([[[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"] isEqualToString:@"200"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[resultsDictionary objectForKey:@"results"] forKey:@"menulist2"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            menuList2 = [resultsDictionary objectForKey:@"results"];
            
            UIImageView *menuBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Img_TabBarBG"]];
            [menuBg setFrame:CGRectMake(0, 314, menuBg.image.size.width, menuBg.image.size.height)];
            [menuBg setUserInteractionEnabled:YES];
            [self addSubview:menuBg];
            
            UIButton *btn;
            UILabel *lbl;
            
            for (int i = 0; i < [menuList2 count] + 1; i++) {
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setTag:i];
                [btn setImage:[UIImage imageNamed:@"IM_Img_TabBar_Normal01"] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"IM_Img_TabBarSelected01"] forState:UIControlStateSelected];
                if (i == 0) {
                    [btn setSelected:YES];
                } else {
                    [btn setSelected:NO];
                }
                [btn setFrame:CGRectMake(i * btn.imageView.image.size.width, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
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
                
                [btnArr addObject:btn];
                
                [btn addSubview:lbl];
            }
            
            tabbarSetup = NO;
        }
        
        [self thumbListRequest:1 withTotalPage:4 withMenuIndex:0 withCtgry:2];
    } else {
        
    }
}

- (void)thumbnailSort:(id)sender {
    NSLog(@"sort : %@", sender);
    
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
        [self thumbListRequest:1 withTotalPage:3 withMenuIndex:((UIButton *)sender).tag withCtgry:2];
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        [self thumbListRealignRequest:1 withTotalPage:3 withMenuIndex:((UIButton *)sender).tag];
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)thumbListRealignRequest:(int)currentIndex withTotalPage:(int)totalCnt withMenuIndex:(int)menuIndex {
//                      withCtgry:(int)ctgryIndex {
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

- (void)returnValue:(NSString *)data withTitle:(NSString *)title {
    NSLog(@"010001 - data : %@, title : %@", data, title);
    
    [self.videoView loadHTMLString:nil baseURL:nil];
    
    CGRect frame = self.videoView.frame;
    
    NSString *embedHTML = [NSString stringWithFormat:@"\
                           <html><head>\
                           <style type=\"text/css\">\
                           body {\
                           background-color: transparent;\
                           color: white;\
                           }\
                           </style>\
                           </head><body style=\"margin:0\">\
                           <iframe id=\"ytplayer\" type=\"text/html\" width=\"%0.0f\" height=\"%0.0f\" src=\"%@?showinfo=0\" frameborder=\"0\"/>"
                           , frame.size.width, frame.size.height, data];
    
    [self.videoView loadHTMLString:embedHTML baseURL:nil];
    if (![loading isAnimating]) {
        [loading startAnimating];
    }
    [videoLbl setText:title];
}

#pragma mark - Web view delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [loading stopAnimating];
}

#pragma mark - Scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    if (scrollView.tag == 1) {
    CGFloat pageWidth = scrollView.frame.size.width;
    [_pageC setCurrentPage:floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1];
    
    for (int i = 0; i < [_pageC.subviews count]; i++) {
        if (floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1 == i) {
            ((UIImageView *)[[_pageC subviews] objectAtIndex:i]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_O"];
        } else {
            ((UIImageView *)[[_pageC subviews] objectAtIndex:i]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_N"];
        }
    }
    //    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"did end decelerating");
    //    if (scrollView.tag == 1) {
    CGFloat pageWidth = scrollView.frame.size.width;
    NSLog(@"current page : %f", floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2);
    
    
    int btnIndex = 0;
    
    for (int i = 0; i < [btnArr count]; i++) {
        if (((UIButton *)[btnArr objectAtIndex:i]).selected) {
            btnIndex = i;
        }
    }

    if (btnIndex == 0) {
    NSLog(@"self.dep1 : %d", self.dep1menuIndex);
    
        [self thumbListRequest:floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2 withTotalPage:[[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"pagingProperty"] objectForKey:@"maxResults"] intValue] withMenuIndex:self.dep1menuIndex withCtgry:[[[menuList1 objectAtIndex:self.dep1menuIndex] objectForKey:@"isLeaf"] intValue]];
    } else {
        [self thumbListRealignRequest:floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2 withTotalPage:[[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"pagingProperty"] objectForKey:@"maxResults"] intValue] withMenuIndex:btnIndex];
    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [target performSelector:@selector(goHome)];
    } else {
        [self thumbListRequest:1 withTotalPage:3 withMenuIndex:0 withCtgry:0];
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
