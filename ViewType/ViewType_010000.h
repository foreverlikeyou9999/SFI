//
//  ViewType_010000.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 28..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>
//
#import "ThumbnailView.h"
#import "ContentManager.h"

@protocol ViewType_010000Delegate <NSObject>

- (void)cntntsLoadingStart:(NSString *)sort;
- (void)cntntsLoadingStop;

@end

@interface ViewType_010000 : UIView <UIScrollViewDelegate, UIAlertViewDelegate, ThumbnanilViewDelegate, ContentManagerDelegate> {
//    id <ViewType_010000> delegate;
    
    NSMutableArray *btnArr;
    NSMutableArray *titleBtnArr;
    NSMutableArray *menuList1;
    NSMutableArray *menuList2;
    
    NSMutableArray *thumbArr;
    
    UIScrollView *_scrollView;
    UIScrollView *menuBg;
    UIPageControl *_pageC;
    
    BOOL pageSetup;
    BOOL tabbarSetup;
    
    NSMutableDictionary *pageCreate;
    
    int currentMenuIndex;
    BOOL thumbBgCheck;
}

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) NSDictionary *selectedItemInfo;   // 선택된 Thumbnanil 정보
@property (nonatomic, strong) ContentManager *contentManager;
@property (nonatomic, strong) NSDictionary *drawItemInfo;
@property int colums;
@property int row;
@property int thumbWidth;
@property int thumbHeight;
@property int thumbW;
@property int thumbH;

//@property int btnIdx;

- (void)thumbListRequest:(int)currentIndex withTotalPage:(int)totalCnt withMenuIndex:(int)menuIndex withCtgry:(int)ctgryIndex;
- (void)setDelegate:(id)aTarget selector:(SEL)aSelector;
//- (void)nextThumblistRequest:(int)currentIndex withTotalPage:(int)totalCnt withMenuIndex:(int)menuIndex;

@end
