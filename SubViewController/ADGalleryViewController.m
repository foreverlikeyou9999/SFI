//
//  ADGalleryViewController.m
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 16..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "ADGalleryViewController.h"
//
#import "NavigationBar/NavigationBar.h"
#import "ThumbnailView/ThumbnailView.h"
#import "ProductDetailView/ProductDetailView.h"
#import "ProductCell/ProductCell.h"
//
#import "httpRequest.h"
#import "downloadRequest.h"
#import "JSONKit.h"

@interface ADGalleryViewController ()

@end

@implementation ADGalleryViewController
@synthesize pageSetup = _pageSetup;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        thumbnailListArr = [[NSMutableArray alloc] init];
        btnArr = [[NSMutableArray alloc] init];
        
        //        UIBarButtonItem *homeBtn = [[UIBarButtonItem alloc] initWithTitle:@"home" style:UIBarButtonItemStyleBordered target:self action:@selector(goHome)];
        //        [self.navigationItem setRightBarButtonItem:homeBtn];
        //        [homeBtn release];
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    for (UIView *view in adGalBgView.subviews) {
        if ([view isKindOfClass:[NavigationBar class]]) {
            [adGalBgView bringSubviewToFront:view];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    adGalBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20)];
    [adGalBgView setUserInteractionEnabled:YES];
    [adGalBgView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:adGalBgView];
    [adGalBgView release];
    
    NavigationBar *naviBar = [[NavigationBar alloc] init];
    [naviBar setDelegate:self];
    [naviBar setNaviTitle:@"KOLON SPORTS"];
    [naviBar createComponents];
    [adGalBgView addSubview:naviBar];
    [naviBar release];
    
    cntBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_BG01"]];
    [cntBgView setFrame:CGRectMake(0, 44, cntBgView.image.size.width, cntBgView.image.size.height)];
    [cntBgView setUserInteractionEnabled:YES];
    [adGalBgView addSubview:cntBgView];
    [cntBgView release];
    
    UIButton *btn;
    UILabel *lbl;
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 34, 500, 40)];
    [lbl setText:@"AD Gallery"];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setFont:[UIFont boldSystemFontOfSize:36]];
    [cntBgView addSubview:lbl];
    [lbl release];
    
    UIImageView *titleUnderBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Img_TitleUnderBar"]];
    [titleUnderBarView setFrame:CGRectMake(20, 86, titleUnderBarView.image.size.width, titleUnderBarView.image.size.height)];
    [cntBgView addSubview:titleUnderBarView];
    [titleUnderBarView release];
    
    int cnt = [[[NSUserDefaults standardUserDefaults] objectForKey:@"adgallerymenulist"] count];
    for (int i = 0; i < [[[NSUserDefaults standardUserDefaults] objectForKey:@"adgallerymenulist"] count] + 1; i++) {
        btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [btn setTag:i];
        [btn setAdjustsImageWhenHighlighted:NO];
        if (i == 0) {
            [btn setImage:[UIImage imageNamed:@"IM_Btn_All_Normal"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"IM_Btn_All_Over"] forState:UIControlStateSelected];
            [btn setSelected:YES];
            [btn setUserInteractionEnabled:NO];
        } else if (i == 1) {
            [btn setImage:[UIImage imageNamed:@"IM_Btn_MediaCut_Normal"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"IM_Btn_MediaCut_Over"] forState:UIControlStateSelected];
            [btn setSelected:NO];
            [btn setUserInteractionEnabled:YES];
        } else {
            [btn setImage:[UIImage imageNamed:@"IM_Btn_TVCF_Normal"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"IM_Btn_TVCF_Over"] forState:UIControlStateSelected];
            [btn setSelected:NO];
            [btn setUserInteractionEnabled:YES];
        }
        [btn setFrame:CGRectMake(706 - (cnt * 62), 36, btn.imageView.image.size.width, btn.imageView.image.size.height)];
        [btn addTarget:self action:@selector(viewHChange:) forControlEvents:UIControlEventTouchUpInside];
        [btnArr addObject:btn];
        [cntBgView addSubview:btn];
        [btn release];
        cnt--;
    }
    
    _pageC = [[UIPageControl alloc] init];
    [_pageC setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - _pageC.bounds.size.width/2, 915, _pageC.bounds.size.width, _pageC.bounds.size.height)];
    [_pageC setCurrentPage:0];
    [cntBgView addSubview:_pageC];
    [_pageC release];
    
    //    btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    //    [btn setTag:0];
    //    [btn setAdjustsImageWhenHighlighted:NO];
    //    [btn setImage:[UIImage imageNamed:@"IM_Btn_All_Normal"] forState:UIControlStateNormal];
    //    [btn setImage:[UIImage imageNamed:@"IM_Btn_All_Over"] forState:UIControlStateSelected];
    //    [btn setFrame:CGRectMake(582, 36, btn.imageView.image.size.width, btn.imageView.image.size.height)];
    //    [btn setSelected:YES];
    //    [btn setUserInteractionEnabled:NO];
    //    [btn addTarget:self action:@selector(viewHChange:) forControlEvents:UIControlEventTouchUpInside];
    //    [btnArr addObject:btn];
    //    [cntBgView addSubview:btn];
    //    [btn release];
    //
    //    btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    //    [btn setTag:1];
    //    [btn setAdjustsImageWhenHighlighted:NO];
    //    [btn setImage:[UIImage imageNamed:@"IM_Btn_TVCF_Normal"] forState:UIControlStateNormal];
    //    [btn setImage:[UIImage imageNamed:@"IM_Btn_TVCF_Over"] forState:UIControlStateSelected];
    //    [btn setFrame:CGRectMake(644, 36, btn.imageView.image.size.width, btn.imageView.image.size.height)];
    //    [btn setSelected:NO];
    //    [btn addTarget:self action:@selector(viewHChange:) forControlEvents:UIControlEventTouchUpInside];
    //    [btnArr addObject:btn];
    //    [cntBgView addSubview:btn];
    //    [btn release];
    //
    //    btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    //    [btn setTag:2];
    //    [btn setAdjustsImageWhenHighlighted:NO];
    //    [btn setImage:[UIImage imageNamed:@"IM_Btn_MediaCut_Normal"] forState:UIControlStateNormal];
    //    [btn setImage:[UIImage imageNamed:@"IM_Btn_MediaCut_Over"] forState:UIControlStateSelected];
    //    [btn setFrame:CGRectMake(706, 36, btn.imageView.image.size.width, btn.imageView.image.size.height)];
    //    [btn setSelected:NO];
    //    [btn addTarget:self action:@selector(viewHChange:) forControlEvents:UIControlEventTouchUpInside];
    //    [btnArr addObject:btn];
    //    [cntBgView addSubview:btn];
    //    [btn release];
    
    //    httpRequest *_httpRequest = [[httpRequest alloc] init];
    //    [_httpRequest setDelegate:self selector:@selector(result:)];
    //    [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:@"http://172.20.60.217:8080/rest/cntntsmgmt/getMainInfo?brandCd=6J" withObject:@"GET"];
    //    [_httpRequest release];
    
    previewBaseView = [[UIView alloc] init];
    [previewBaseView setBackgroundColor:[UIColor clearColor]];
    
    thumbnailBaseView = [[UIView alloc] init];
    [thumbnailBaseView setBackgroundColor:[UIColor clearColor]];
    
    variableBaseMenu = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 40, 30)];
    [variableBaseMenu setDelegate:self];
    [variableBaseMenu setTag:0];
    [variableBaseMenu setHidden:YES];
    [variableBaseMenu setShowsHorizontalScrollIndicator:NO];
    [variableBaseMenu setBackgroundColor:[UIColor clearColor]];
    [variableBaseMenu setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, 30)];
    [thumbnailBaseView addSubview:variableBaseMenu];
    [variableBaseMenu release];
    
    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 110)];
    [_scrollView setDelegate:self];
    [_scrollView setTag:1];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setPagingEnabled:YES];
    [thumbnailBaseView addSubview:_scrollView];
    
    UIImageView *menuBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Img_TabBarBG"]];
    [menuBg setFrame:CGRectMake(0, 0, menuBg.image.size.width, menuBg.image.size.height)];
    [menuBg setUserInteractionEnabled:YES];
    [variableBaseMenu addSubview:menuBg];
    [menuBg release];
    
    for (int i = 0; i < 7; i++) {
        btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [btn setTag:3+i];
        [btn setImage:[UIImage imageNamed:@"IM_Img_TabBar_Normal01"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"IM_Img_TabBarSelected01"] forState:UIControlStateSelected];
        [btn setFrame:CGRectMake(i * btn.imageView.image.size.width, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
        [btn addTarget:self action:@selector(thumbnailSort:) forControlEvents:UIControlEventTouchUpInside];
        [btnArr addObject:btn];
        [menuBg addSubview:btn];
        [btn release];
        
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setText:@"All"];
        [lbl setFont:[UIFont boldSystemFontOfSize:11]];
        [lbl setTextColor:[UIColor whiteColor]];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [btn addSubview:lbl];
        [lbl release];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"all" forKey:@"adgalstatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self thumbListRequest:1 withTotalPage:12 withMenuIndex:0];
    
    self.pageSetup = YES;
    
    NSLog(@"view did load");
}

- (void)thumbListRequest:(int)currentIndex withTotalPage:(int)totalCnt withMenuIndex:(int)menuIndex {
    
    NSLog(@"adgalstatus : %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"]);
    
    NSString *url = @"";
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"] isEqualToString:@"all"]) {
    if (totalCnt == 12) {
        url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=DAA88002E4C06D2EEF7C01690A17C9E4BE721825455A973B59A006C695298A12&timestamp=1377221715487"
               , KHOST
               , PAGEDLISTALLCNTNTSINFO
               , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
               , [[[[NSUserDefaults standardUserDefaults] objectForKey:@"adgallerymenulist"] objectAtIndex:menuIndex] objectForKey:@"upCtgryId"]
               , currentIndex
               , totalCnt];
    } else {
        url = [NSString stringWithFormat:@"%@%@?brandCd=%@&ctgryId=%@&currentPage=%d&maxResults=%d&maxLinks=1&accessToken=DAA88002E4C06D2EEF7C01690A17C9E4BE721825455A973B59A006C695298A12&timestamp=1377221715487"
               , KHOST
               , PAGEDLISTCNTNTSINFO
               , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
               , [[[[NSUserDefaults standardUserDefaults] objectForKey:@"adgallerymenulist"] objectAtIndex:menuIndex - 1] objectForKey:@"ctgryId"]
               , currentIndex
               , totalCnt];
    }
    
    NSLog(@"url : %@", url);
    
    httpRequest *_httpRequest = [[httpRequest alloc] init];
    [_httpRequest setDelegate:self selector:@selector(result:)];
    [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    [_httpRequest release];
}

- (void)doNetworkErrorProcess {
    NSLog(@"error");
}

- (void)result:(NSString *)data {
//    ThumbnailView *thumbnailView;
    
    [thumbnailListArr removeAllObjects];
    
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    if (videoView) {
        [videoView loadHTMLString:nil baseURL:nil];
    }
    
    NSLog(@"result data : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        if ([[[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"] isEqualToString:@"200"]) {
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:resultsDictionary] forKey:@"thumblist"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            int thumbCount = [[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"pagingProperty"] objectForKey:@"countItem"] intValue];
            int page = [[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"pagingProperty"] objectForKey:@"maxResults"] intValue];
            
            if (self.pageSetup) {
                if (thumbCount > page) {
                    if (thumbCount%page == 0) {
                        [_pageC setNumberOfPages:thumbCount/page];
                        [_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width+(((thumbCount/page)-1)*[UIScreen mainScreen].bounds.size.width), [UIScreen mainScreen].bounds.size.height - 110)];
                    } else {
                        [_pageC setNumberOfPages:thumbCount/page + 1];
                        [_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width+((thumbCount/page)*[UIScreen mainScreen].bounds.size.width), [UIScreen mainScreen].bounds.size.height - 110)];
                    }
                } else {
                    [_pageC setNumberOfPages:1];
                    [_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 110)];
                }
                
                if ([_pageC.subviews count] == 1) {
                    ((UIImageView *)[[_pageC subviews] objectAtIndex:0]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_Over"];
                    [((UIImageView *)[[_pageC subviews] objectAtIndex:0]) setFrame:CGRectMake(((UIImageView *)[[_pageC subviews] objectAtIndex:0]).bounds.origin.x, ((UIImageView *)[[_pageC subviews] objectAtIndex:0]).bounds.origin.y, 11, 11)];
                } else {
                    for (int i = 1; i < [_pageC.subviews count]; i++) {
                        ((UIImageView *)[[_pageC subviews] objectAtIndex:i]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_Normal"];
                        [((UIImageView *)[[_pageC subviews] objectAtIndex:i]) setFrame:CGRectMake(((UIImageView *)[[_pageC subviews] objectAtIndex:0]).bounds.origin.x, ((UIImageView *)[[_pageC subviews] objectAtIndex:0]).bounds.origin.y, 11, 11)];
                    }
                    ((UIImageView *)[[_pageC subviews] objectAtIndex:0]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_Over"];
                    [((UIImageView *)[[_pageC subviews] objectAtIndex:0]) setFrame:CGRectMake(((UIImageView *)[[_pageC subviews] objectAtIndex:0]).bounds.origin.x, ((UIImageView *)[[_pageC subviews] objectAtIndex:0]).bounds.origin.y, 11, 11)];
                }
                self.pageSetup = NO;
            }

            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"] isEqualToString:@"all"]) {
                NSLog(@"all");
                
                [_scrollView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 110)];
                
                [self createAllThumbnail];
            } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"] isEqualToString:@"010001"]) {
                NSLog(@"동영상");
                
                [_scrollView setFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 110)];
                
                [self createVideoPreview];
            } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"] isEqualToString:@"010003"]) {
                NSLog(@"이미지");
                [_scrollView setFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 110)];
                [self createProductPreview];
            } else {
                
            }
        } else {
            
        }
    } else {
        
    }
}

- (void)createAllThumbnail {
    for (UIView *view in previewBaseView.subviews) {
        [view removeFromSuperview];
    }
    
    [variableBaseMenu setHidden:YES];
    
    [cntBgView addSubview:previewBaseView];
    
    //    [thumbnailBaseView setFrame:CGRectMake(20, 434, 728, 430)];
    [thumbnailBaseView setFrame:CGRectMake(20, 120, 728, 653)];
    [cntBgView addSubview:thumbnailBaseView];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"all" forKey:@"adgalstatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self addThumbnail:[[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"]];
}

- (void)createProductPreview {
    for (UIView *view in previewBaseView.subviews) {
        [view removeFromSuperview];
    }
    
    [variableBaseMenu setHidden:NO];
    
    if (videoView) {
        [videoView loadHTMLString:nil baseURL:nil];
    }
    
    [previewBaseView setFrame:CGRectMake(20, 120, 728, 256)];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Icn_MediaCut"]];
    [iconView setTag:0];
    [iconView setFrame:CGRectMake(0, 0, iconView.image.size.width, iconView.image.size.height)];
    [previewBaseView addSubview:iconView];
    [iconView release];
    
    UILabel *lbl;
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 500, 14)];
    [lbl setText:[NSString stringWithFormat:@"%@ / %@", [[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"cntntsNm"], [[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"cntntsCn"]]];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setFont:[UIFont boldSystemFontOfSize:14]];
    [previewBaseView addSubview:lbl];
    [lbl release];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/%@/%@/%@.%@"
                                                                           , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                                                           , [[[[NSUserDefaults standardUserDefaults] objectForKey:@"adgallerymenulist"] objectAtIndex:0] objectForKey:@"upCtgryId"]
                                                                           , [[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"cntntsId"]
                                                                           , [[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"cntntsFileLc"]
                                                                           , [[[[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"thumbFileNm"] componentsSeparatedByString:@"."] objectAtIndex:1]]];
    
    UIImageView *preView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:cachePath]];
    [preView setTag:1];
    [preView setFrame:CGRectMake(0, 30, 408, 256)];
    [previewBaseView addSubview:preView];
    [preView release];
    
    productListView = [[UITableView alloc] initWithFrame:CGRectMake(428, 30, 300, 256)];
    [productListView setDelegate:self];
    [productListView setDataSource:self];
    [productListView setRowHeight:95];
    [productListView setBackgroundColor:[UIColor clearColor]];
    [productListView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [previewBaseView addSubview:productListView];
    
    NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&cntntsId=%@&accessToken=DAA88002E4C06D2EEF7C01690A17C9E4BE721825455A973B59A006C695298A12&timestamp=1377221715487"
                     , KHOST
                     , GETCNTNTSINFO
                     , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                     , [[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] objectAtIndex:1] objectForKey:@"cntntsId"]];
    
    httpRequest *_httpRequest = [[httpRequest alloc] init];
    [_httpRequest setDelegate:self selector:@selector(prductInfos:)];
    [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    [_httpRequest release];
    
    //    [self createThumbnail:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] objectForKey:@"pagingProperty"] objectForKey:@"countItem"] intValue] withPageLimit:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] objectForKey:@"pagingProperty"] objectForKey:@"maxResults"] intValue]];
}

- (void)prductInfos:(NSString *)data {
    NSLog(@"result data : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        if ([[[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"] isEqualToString:@"200"]) {
            NSLog(@"product : %@", [[resultsDictionary objectForKey:@"result"] objectForKey:@"prductInfos"]);
            
            [[NSUserDefaults standardUserDefaults] setObject:[[resultsDictionary objectForKey:@"result"] objectForKey:@"prductInfos"] forKey:@"cntntslist"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self addThumbnail:[[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"]];
            
            [productListView reloadData];
        } else {
            
        }
    } else {
        
    }
}

- (void)createVideoPreview {
    if (videoView) {
        [videoView loadHTMLString:nil baseURL:nil];
    }
    
    for (UIView *view in previewBaseView.subviews) {
        [view removeFromSuperview];
    }
    
    [variableBaseMenu setHidden:NO];
    
    [previewBaseView setFrame:CGRectMake(20, 120, 728, 408)];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Icn_TVCF"]];
    [iconView setFrame:CGRectMake(0, 0, iconView.image.size.width, iconView.image.size.height)];
    [previewBaseView addSubview:iconView];
    [iconView release];
    
    UILabel *lbl;
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 500, 14)];
//    [lbl setText:[NSString stringWithFormat:@"%@ / %@", [[[[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"cntntsNm"], [[[[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"cntntsCn"]]];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setFont:[UIFont boldSystemFontOfSize:14]];
    [previewBaseView addSubview:lbl];
    [lbl release];
    
//    NSString *url = @"http://www.youtube.com/v/co6PECjmlJo?version=3&enablejsapi=1&playerapiid=ytplayer&fs=1";
    NSString *url = [NSString stringWithFormat:@"%@", [[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"linkUrl"]];
    
    videoView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 30, 728, 394)];
    [videoView setDelegate:self];
    [videoView.scrollView setScrollEnabled:NO];
    [videoView.scrollView setBackgroundColor:[UIColor clearColor]];
    videoView.allowsInlineMediaPlayback = YES;
    [previewBaseView addSubview:videoView];
    
    loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loading setColor:[UIColor grayColor]];
    [loading setFrame:CGRectMake(previewBaseView.frame.size.width/2 - loading.bounds.size.width/2, previewBaseView.frame.size.height/2 - loading.bounds.size.height/2, loading.bounds.size.width, loading.bounds.size.height)];
    [videoView addSubview:loading];
    
    [self embedUrl:url withTitle:[NSString stringWithFormat:@"%@ / %@", [[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"cntntsNm"], [[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] objectAtIndex:0] objectForKey:@"cntntsCn"]]];

    //    [self createThumbnail:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] objectForKey:@"pagingProperty"] objectForKey:@"countItem"] intValue] withPageLimit:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"] objectForKey:@"pagingProperty"] objectForKey:@"maxResults"] intValue]];
    [self addThumbnail:[[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"]];
}

//<embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
//width=\"%0.0f\" height=\"%0.0f\"></embed>\
//</body></html>"

- (void)embedUrl:(NSString *)data withTitle:(NSString *)title {
    NSLog(@"data : %@, %@", data, title);
    
    CGRect frame = videoView.frame;
    
    NSString *embedHTML = [NSString stringWithFormat:@"\
                           <html><head>\
                           <style type=\"text/css\">\
                           body {\
                           background-color: transparent;\
                           color: white;\
                           }\
                           </style>\
                           </head><body style=\"margin:0\">\
                           <iframe id=\"ytplayer\" type=\"text/html\" width=\"%0.0f\" height=\"%0.0f\" src=\"%@\" frameborder=\"0\"/>"
                           , frame.size.width, frame.size.height, data];
    
    [videoView loadHTMLString:embedHTML baseURL:nil];
    [loading startAnimating];
    
    for (UIView *view in previewBaseView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [((UILabel *)view) setText:title];
        }
    }
}

- (void)embedImg:(NSString *)data withTitle:(NSString *)title {
    NSLog(@"data : %@, %@", data, title);
    
    for (UIView *view in previewBaseView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [((UILabel *)view) setText:title];
        }
        
        if ([view isKindOfClass:[UIImageView class]]) {
            if (view.tag == 1) {
                [((UIImageView *)view) setImage:[UIImage imageWithContentsOfFile:data]];
            }
        }
    }
}

//- (void)createThumbnail:(int)thumbCount withPageLimit:(int)page {
//    ThumbnailView *thumbnailView;
//
//    [thumbnailListArr removeAllObjects];
//
//    if (_scrollView) {
//        [_scrollView removeFromSuperview];
//    }
//
//    _scrollView = [[UIScrollView alloc] init];
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"] isEqualToString:@"all"]) {
//        [_scrollView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 110)];
//    } else {
//        [_scrollView setFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 110)];
//    }
//    [_scrollView setDelegate:self];
//    [_scrollView setTag:1];
//    [_scrollView setBackgroundColor:[UIColor clearColor]];
//    [_scrollView setShowsHorizontalScrollIndicator:NO];
//    [_scrollView setPagingEnabled:YES];
//    if (thumbCount > page) {
//        if (thumbCount%page == 0) {
//            [_pageC setNumberOfPages:thumbCount/page];
//            [_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width+(((thumbCount/page)-1)*[UIScreen mainScreen].bounds.size.width), [UIScreen mainScreen].bounds.size.height - 110)];
//        } else {
//            [_pageC setNumberOfPages:thumbCount/page + 1];
//            [_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width+((thumbCount/page)*[UIScreen mainScreen].bounds.size.width), [UIScreen mainScreen].bounds.size.height - 110)];
//        }
//    } else {
//        [_pageC setNumberOfPages:1];
//        [_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 110)];
//    }
//    [thumbnailBaseView addSubview:_scrollView];
//
//    if ([_pageC.subviews count] == 1) {
//        ((UIImageView *)[[_pageC subviews] objectAtIndex:0]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_Over"];
//        [((UIImageView *)[[_pageC subviews] objectAtIndex:0]) setFrame:CGRectMake(0, 0, 11, 11)];
//    } else {
//        for (int i = 1; i < [_pageC.subviews count]; i++) {
//            ((UIImageView *)[[_pageC subviews] objectAtIndex:i]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_Normal"];
//            [((UIImageView *)[[_pageC subviews] objectAtIndex:i]) setFrame:CGRectMake(0, 0, 11, 11)];
//        }
//        ((UIImageView *)[[_pageC subviews] objectAtIndex:0]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_Over"];
//        [((UIImageView *)[[_pageC subviews] objectAtIndex:0]) setFrame:CGRectMake(0, 0, 11, 11)];
//    }
//
//    for (int i = 0; i < thumbCount; i++) {
//        thumbnailView = [[ThumbnailView alloc] init];
//        [thumbnailView setThumbIndex:i];
//        [thumbnailView dnThumbImg];
//        [thumbnailView createComponents];
//        [thumbnailView setFrame:CGRectMake(0, 0, 226, 164)];
//        [thumbnailView setDelegate:self selector:@selector(embedUrl:)];
//        [thumbnailListArr addObject:thumbnailView];
//        [thumbnailView release];
//    }
//}

- (void)test:(NSString *)data {
    NSLog(@"test : %@", data);
}

- (void)addThumbnail:(NSString *)currentView {
    NSLog(@"currentview : %@", currentView);
    
    ThumbnailView *thumbnailView;
    
    int thumbH = 30;
    
    int rowCount = 0;
    int col = 3;
    
    if ([currentView isEqualToString:@"all"]) {
        rowCount = 4;
    } else if ([currentView isEqualToString:@"010001"]) {
        rowCount = 1;
    } else if ([currentView isEqualToString:@"010003"]) {
        rowCount = 2;
    } else {
        
    }
    
    for (int i = 0; i < [[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"list"] count]; i++) {
        thumbnailView = [[ThumbnailView alloc] init];
        [thumbnailView setThumbIndex:i];
//        [thumbnailView setSubDir:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"adgallerymenulist"] objectAtIndex:0] objectForKey:@"upCtgryId"]];
        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(dispatchQueue, ^(void) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [thumbnailView dnThumbImg:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"adgallerymenulist"] objectAtIndex:0] objectForKey:@"upCtgryId"]];
            });
        });

        
//        if ([thumbnailListArr count]%col == 0) {//3개로 나눠짐
//            
//        } else {
//            if ([thumbnailListArr count]/3 == 0) {//3개 미만
//        
//            } else {
//                if ([thumbnailListArr count] > (rowCount*col)) {
//                    NSLog(@"2페이지 이상");
//                } else {
//                    NSLog(@"1페이지");
                
        [thumbnailView setFrame:CGRectMake((([[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"pagingProperty"] objectForKey:@"currentPage"] intValue] - 1) * [UIScreen mainScreen].bounds.size.width) + (i % 3) * 226 + ((i % 3) * 25), (i / 3) * 164 + ((i / 3) * thumbH), 226, 164)];

//                    for (int i = 0; i < [thumbnailListArr count]/col + 1; i++) {
//                        if (i == [thumbnailListArr count]/col) {
//                            for (int j = 0; j < [thumbnailListArr count]%col; j++) {
//                                thumbnailView = (ThumbnailView *)[thumbnailListArr objectAtIndex:i*3+j];
//                                [thumbnailView setFrame:CGRectMake(j * 226 + (j * 25), i * 164 + (i * thumbH), 226, 164)];
//                                [thumbnailListArr replaceObjectAtIndex:i*3+j withObject:thumbnailView];
//                            }
//                        } else {
//                            for (int j = 0; j < col; j++) {
//                                thumbnailView = (ThumbnailView *)[thumbnailListArr objectAtIndex:i*3+j];
//                                [thumbnailView setFrame:CGRectMake(j * 226 + (j * 25), i * 164 + (i * thumbH), 226, 164)];
//                                [thumbnailListArr replaceObjectAtIndex:i*3+j withObject:thumbnailView];
//                            }
//                        }
//                    }
//                }
//            }
//        }
        
        if ([[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectAtIndex:i] objectForKey:@"cntntsTyCd"] isEqualToString:@"008001"]) {
            dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            dispatch_async(dispatchQueue, ^(void) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [thumbnailView dnCntImg:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"adgallerymenulist"] objectAtIndex:0] objectForKey:@"upCtgryId"]];
                });
            });
            [thumbnailView setDelegate:self selector:@selector(embedImg:withTitle:)];
        } else if ([[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectAtIndex:i] objectForKey:@"cntntsTyCd"] isEqualToString:@"008004"]) {
            [thumbnailView setDelegate:self selector:@selector(embedUrl:withTitle:)];
        } else {
            
        }
        [thumbnailListArr addObject:thumbnailView];
        [_scrollView addSubview:thumbnailView];
//        [thumbnailView release];
    }
    
    //    if ([thumbnailListArr count]%col == 0) {//3개로 나눠짐
    //        if ([thumbnailListArr count] > rowCount*col) {//페이지 추가
    //            for (int k = 0; k < [thumbnailListArr count]/rowCount*col; k++) {
    //                for (int i = 0; i < [thumbnailListArr count]/col; i++) {
    //                    for (int j = 0; j < col; j++) {
    //                        thumbnailView = (ThumbnailView *)[thumbnailListArr objectAtIndex:i*3+j];
    //                        [thumbnailView setFrame:CGRectMake((((i*3+j)/(col*rowCount)) * [UIScreen mainScreen].bounds.size.width) + j * 226 + (j * 25), ((i%rowCount) * 164) + ((i%rowCount) * thumbH), 226, 164)];
    //                        [thumbnailListArr replaceObjectAtIndex:i*3+j withObject:thumbnailView];
    //                    }
    //                }
    //            }
    //        } else {//페이지 한개
    //            for (int i = 0; i < [thumbnailListArr count]/col; i++) {
    //                for (int j = 0; j < col; j++) {
    //                    thumbnailView = (ThumbnailView *)[thumbnailListArr objectAtIndex:i*3+j];
    //                    [thumbnailView setFrame:CGRectMake(j * 226 + (j * 25), i * 164 + (i * thumbH), 226, 164)];
    //                    [thumbnailListArr replaceObjectAtIndex:i*3+j withObject:thumbnailView];
    //                }
    //            }
    //        }
    //    } else {//나머지가 있음
    //        if ([thumbnailListArr count]/3 == 0) {//3개 미만
    //            for (int i = 0; i < [thumbnailListArr count]; i++) {
    //                thumbnailView = (ThumbnailView *)[thumbnailListArr objectAtIndex:i];
    //                [thumbnailView setFrame:CGRectMake(i * 226 + (i * 25), 0, 226, 164)];
    //                [thumbnailListArr replaceObjectAtIndex:i withObject:thumbnailView];
    //            }
    //        } else {//3개 이상
    //            if ([thumbnailListArr count] > (rowCount*col)) {
    //                NSLog(@"2페이지 이상");
    //                for (int k = 0; k < [thumbnailListArr count]/(rowCount*col); k++) {
    //                    if (k == [thumbnailListArr count]/(rowCount*col) - 1) {
    //                        for (int i = 0; i < [thumbnailListArr count]/col; i++) {
    //                            if (i == [thumbnailListArr count]/col - 1) {
    //                                for (int j = 0; j < [thumbnailListArr count]%col; j++) {
    //                                    thumbnailView = (ThumbnailView *)[thumbnailListArr objectAtIndex:i*3+j];
    //                                    [thumbnailView setFrame:CGRectMake((((i*3+j)/(col*rowCount)) * [UIScreen mainScreen].bounds.size.width) + j * 226 + (j * 25), ((i%rowCount) * 164) + ((i%rowCount) * thumbH), 226, 164)];
    //                                    [thumbnailListArr replaceObjectAtIndex:i*3+j withObject:thumbnailView];
    //                                }
    //                            } else {
    //                                for (int j = 0; j < col; j++) {
    //                                    thumbnailView = (ThumbnailView *)[thumbnailListArr objectAtIndex:i*3+j];
    //                                    [thumbnailView setFrame:CGRectMake((((i*3+j)/(col*rowCount)) * [UIScreen mainScreen].bounds.size.width) + j * 226 + (j * 25), ((i%rowCount) * 164) + ((i%rowCount) * thumbH), 226, 164)];
    //                                    [thumbnailListArr replaceObjectAtIndex:i*3+j withObject:thumbnailView];
    //                                }
    //                            }
    //                        }
    //                    } else {//1번 페이지
    //                        for (int i = 0; i < 2; i++) {
    //                            for (int j = 0; j < 3; j++) {
    //                                thumbnailView = (ThumbnailView *)[thumbnailListArr objectAtIndex:i*3+j];
    //                                [thumbnailView setFrame:CGRectMake(j * 226 + (j * 25), i * 164 + (i * thumbH), 226, 164)];
    //                                [thumbnailListArr replaceObjectAtIndex:i*3+j withObject:thumbnailView];
    //                            }
    //                        }
    //                    }
    //                }
    //            } else {
    //                NSLog(@"1페이지 이하");
    //                for (int i = 0; i < [thumbnailListArr count]/col + 1; i++) {
    //                    if (i == [thumbnailListArr count]/col) {
    //                        for (int j = 0; j < [thumbnailListArr count]%col; j++) {
    //                            thumbnailView = (ThumbnailView *)[thumbnailListArr objectAtIndex:i*3+j];
    //                            [thumbnailView setFrame:CGRectMake(j * 226 + (j * 25), i * 164 + (i * thumbH), 226, 164)];
    //                            [thumbnailListArr replaceObjectAtIndex:i*3+j withObject:thumbnailView];
    //                        }
    //                    } else {
    //                        for (int j = 0; j < col; j++) {
    //                            thumbnailView = (ThumbnailView *)[thumbnailListArr objectAtIndex:i*3+j];
    //                            [thumbnailView setFrame:CGRectMake(j * 226 + (j * 25), i * 164 + (i * thumbH), 226, 164)];
    //                            [thumbnailListArr replaceObjectAtIndex:i*3+j withObject:thumbnailView];
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
    
//    for (int i = 0; i < [thumbnailListArr count]; i++) {
//        UIView *temp = [[UIView alloc] init];
//        [(ThumbnailView *)[thumbnailListArr objectAtIndex:i] dnThumbImg];
//        temp = (ThumbnailView *)[thumbnailListArr objectAtIndex:i];
//        [_scrollView addSubview:(ThumbnailView *)[thumbnailListArr objectAtIndex:i]];
//        [temp release];
//    }
}

- (void)goHome {
    [videoView loadHTMLString:nil baseURL:nil];
    [videoView setDelegate:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)goPrev {
    [videoView loadHTMLString:nil baseURL:nil];
    [videoView setDelegate:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewHChange:(id)sender {
    self.pageSetup = YES;
    
    if (((UIButton *)sender).tag == 0) {
        for (int i = 0; i < [[[NSUserDefaults standardUserDefaults] objectForKey:@"adgallerymenulist"] count] + 1; i++) {
            if (((UIButton *)sender).tag == i) {
                [(UIButton *)[btnArr objectAtIndex:i] setSelected:YES];
                [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:NO];
            } else {
                [(UIButton *)[btnArr objectAtIndex:i] setSelected:NO];
                [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:YES];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@"all" forKey:@"adgalstatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [thumbnailBaseView setFrame:CGRectMake(20, 120, 728, 653)];
        [_pageC setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - _pageC.bounds.size.width/2, 915, _pageC.bounds.size.width, _pageC.bounds.size.height)];

        [self thumbListRequest:1 withTotalPage:12 withMenuIndex:((UIButton *)sender).tag];
    } else if (((UIButton *)sender).tag == 1) {
        for (int i = 0; i < [[[NSUserDefaults standardUserDefaults] objectForKey:@"adgallerymenulist"] count] + 1; i++) {
            if (((UIButton *)sender).tag == i) {
                [(UIButton *)[btnArr objectAtIndex:i] setSelected:YES];
                [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:NO];
            } else {
                [(UIButton *)[btnArr objectAtIndex:i] setSelected:NO];
                [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:YES];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"adgallerymenulist"] objectAtIndex:((UIButton *)sender).tag - 1] objectForKey:@"scrinTyCd"] forKey:@"adgalstatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [thumbnailBaseView setFrame:CGRectMake(20, 434, 728, 430)];
        
        [_pageC setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - _pageC.bounds.size.width/2, 880, _pageC.bounds.size.width, _pageC.bounds.size.height)];
        
        [self thumbListRequest:1 withTotalPage:6 withMenuIndex:((UIButton *)sender).tag];
    } else if (((UIButton *)sender).tag == 2) {
        for (int i = 0; i < [[[NSUserDefaults standardUserDefaults] objectForKey:@"adgallerymenulist"] count] + 1; i++) {
            if (((UIButton *)sender).tag == i) {
                [(UIButton *)[btnArr objectAtIndex:i] setSelected:YES];
                [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:NO];
            } else {
                [(UIButton *)[btnArr objectAtIndex:i] setSelected:NO];
                [(UIButton *)[btnArr objectAtIndex:i] setUserInteractionEnabled:YES];
            }
        }
        
        NSLog(@"ㅁㄴㅇㄹ111 : %@", [[[[NSUserDefaults standardUserDefaults] objectForKey:@"adgallerymenulist"] objectAtIndex:((UIButton *)sender).tag - 1] objectForKey:@"scrinTyCd"]);
        
        [[NSUserDefaults standardUserDefaults] setObject:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"adgallerymenulist"] objectAtIndex:((UIButton *)sender).tag - 1] objectForKey:@"scrinTyCd"] forKey:@"adgalstatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [thumbnailBaseView setFrame:CGRectMake(20, 568, 728, 296)];
        [_pageC setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - _pageC.bounds.size.width/2, 835, _pageC.bounds.size.width, _pageC.bounds.size.height)];
        
        [self thumbListRequest:1 withTotalPage:3 withMenuIndex:((UIButton *)sender).tag];
    } else {
        
    }
}

- (void)thumbnailSort:(id)sender {
    //    if (((UIButton *)sender).tag == 3) {
    //        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"] isEqualToString:@"all"]) {
    //            [self createThumbnail:24 withPageLimit:6];
    //        } else {
    //            [self createThumbnail:24 withPageLimit:9];
    //        }
    //        [self addThumbnail:[[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"]];
    //    } else if (((UIButton *)sender).tag == 4) {
    //        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"] isEqualToString:@"all"]) {
    //            [self createThumbnail:4 withPageLimit:6];
    //        } else {
    //            [self createThumbnail:4 withPageLimit:9];
    //        }
    //        [self addThumbnail:[[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"]];
    //    } else {
    //        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"] isEqualToString:@"all"]) {
    //            [self createThumbnail:18 withPageLimit:6];
    //        } else {
    //            [self createThumbnail:18 withPageLimit:9];
    //        }
    //        [self addThumbnail:[[NSUserDefaults standardUserDefaults] objectForKey:@"adgalstatus"]];
    //    }
}

- (void)detailProduct:(id)sender {
    NSLog(@"tag : %d", ((UIButton *)sender).tag);
    
    [adGalBgView setUserInteractionEnabled:NO];
    
    ProductDetailView *productDV = [[ProductDetailView alloc] init];
    [productDV setDelegate:self selector:@selector(detailProductDismiss)];
    [self.view addSubview:productDV];
    [productDV release];
}

- (void)detailProductDismiss {
    [adGalBgView setUserInteractionEnabled:YES];
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[ProductDetailView class]]) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1) {
        CGFloat pageWidth = scrollView.frame.size.width;
        [_pageC setCurrentPage:floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1];
        
        for (int i = 0; i < [_pageC.subviews count]; i++) {
            if (floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1 == i) {
                ((UIImageView *)[[_pageC subviews] objectAtIndex:i]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_Over"];
            } else {
                ((UIImageView *)[[_pageC subviews] objectAtIndex:i]).image = [UIImage imageNamed:@"IM_Btn_SlideCircle_Normal"];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"did end decelerating");
    if (scrollView.tag == 1) {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSLog(@"current page : %f", floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2);
        
        [self thumbListRequest:floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 2 withTotalPage:[[[[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"thumblist"]] objectForKey:@"pagingProperty"] objectForKey:@"maxResults"] intValue] withMenuIndex:2];
    }
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"did end dragging");
//}
//
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    NSLog(@"did end scrollinganimation");
//}
//
//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"will begin decelerating");
//}
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    NSLog(@"will begin dragging");
//}
//
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    NSLog(@"will end dragging");
//}

#pragma mark - Web view delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [loading stopAnimating];
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
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"cntntslist"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    ProductCell *cell = (ProductCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.row%2 == 0) {
        [cell.thumbnnailView setImage:[UIImage imageNamed:@"IM_Img_ThumbSmall001"]];
        [cell.thumbnnailView setFrame:CGRectMake(0, 0, cell.thumbnnailView.image.size.width, cell.thumbnnailView.image.size.height)];
    } else {
        [cell.thumbnnailView setImage:[UIImage imageNamed:@"IM_Img_ThumbSmall002"]];
        [cell.thumbnnailView setFrame:CGRectMake(0, 0, cell.thumbnnailView.image.size.width, cell.thumbnnailView.image.size.height)];
    }
    
    [cell.productNameLbl setText:@"EAGLE 프린트 라운드 티셔츠"];
    [cell.amountLbl setText:@"52,000 원"];
    
    UIButton *btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [btn setTag:indexPath.row];
    [btn setImage:[UIImage imageNamed:@"IM_Btn_ProductDetail"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(100, 50, btn.imageView.image.size.width, btn.imageView.image.size.height)];
    [btn addTarget:self action:@selector(detailProduct:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btn];
    [btn release];
    
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
    // Navigation logic may go here. Create and push another view controller.
    //    if (indexPath.row == 0) {
    //        ADGalleryViewController *detailViewController = [[ADGalleryViewController alloc] init];
    // ...
    // Pass the selected object to the new view controller.
    //        [self.navigationController pushViewController:detailViewController animated:YES];
    //        [detailViewController release];
    //    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
