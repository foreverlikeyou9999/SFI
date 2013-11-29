//
//  ViewType_010001.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 28..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewType_010001 : UIView <UIScrollViewDelegate, UIWebViewDelegate, UIAlertViewDelegate> {
    NSMutableArray *btnArr;
    NSMutableArray *menuList1;
    NSMutableArray *menuList2;
    
    UIScrollView *_scrollView;
    UIPageControl *_pageC;
    
    BOOL pageSetup;
    BOOL tabbarSetup;
    
    UILabel *videoLbl;
    UIActivityIndicatorView *loading;
    
    UIView *tempView;
}

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) UIWebView *videoView;
@property BOOL autoSelect;
@property int dep1menuIndex;

- (void)thumbListRequest:(int)currentIndex withTotalPage:(int)totalCnt withMenuIndex:(int)menuIndex withCtgry:(int)ctgryIndex;
- (void)setDelegate:(id)aTarget selector:(SEL)aSelector;
- (void)returnValue:(NSString *)data withTitle:(NSString *)title;

@end
