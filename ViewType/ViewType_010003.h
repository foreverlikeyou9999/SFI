//
//  ViewType_010003.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 28..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ViewType_010003Delegate <NSObject>

- (void)cntntsLoadingStart:(NSString *)sort;
- (void)cntntsLoadingStop;

@end

@interface ViewType_010003 : UIView <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIWebViewDelegate> {
    NSMutableArray *btnArr;
    NSMutableArray *titleBtnArr;
    NSArray *menuList1;
    NSArray *menuList2;
    NSMutableArray *thumbArr;
    
    UIScrollView *_scrollView;
    UIPageControl *_pageC;
    
    BOOL pageSetup;
    BOOL tabbarSetup;
    
//    UIImageView *previewImgView;
    UIScrollView *previewLblScroll;
    UILabel *previewLbl;
    UIImageView *cntntsInfoBox;
    UITableView *productListView;
    UITextView *cntntsInfoView;
    
    UILabel *productListCnt;
    
    NSMutableDictionary *pageCreate;
    
    int currentMenuIndex;
    
    int requestCnt;
    BOOL thumbBgCheck;
}

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property BOOL autoSelect;
@property int dep1menuIndex;
@property (nonatomic, strong) UIImageView *previewImgView;
//@property (nonatomic, strong) UIWebView *videoView;
@property (nonatomic, strong) NSMutableArray * listData;
@property (nonatomic, strong) NSDictionary *drawItemInfo;

- (void)thumbListRequest:(int)currentIndex withTotalPage:(int)totalCnt withMenuIndex:(int)menuIndex withCtgry:(int)ctgryIndex;
- (void)setDelegate:(id)aTarget selector:(SEL)aSelector;
- (void)returnValue:(NSString *)data withThumbInfo:(NSDictionary *)infoDic;
- (void)webviewDelete;

@end
