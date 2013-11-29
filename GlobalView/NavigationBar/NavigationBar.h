//
//  NavigationBar.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 28..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NavigationBar;

@protocol NavigationBarDelegate <NSObject>

- (void)clickedMobileMenuBtnAtIndex:(NSInteger)buttonIndex;//unfixed menu
- (void)clickedFixedMenuBtnAtIndex:(NSInteger)buttonIndex;
- (void)goPrev;
- (void)goHome:(NavigationBar*) naviBar;

@end

@interface NavigationBar : UIView <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIAlertViewDelegate> {
    id <NavigationBarDelegate> __weak delegate;
    
    NSArray *menuList;
    NSArray *brandList;
    NSMutableArray *menuBtnArr;
    
    UIImageView *brandSelectView;
    UIImageView *menuSelectView;
    
}

@property (nonatomic, weak) id <NavigationBarDelegate> delegate;
@property (nonatomic, strong) NSString *naviTitle;
//@property (nonatomic, strong) LoadingView *loadingView;
//@property (nonatomic, assign) id target;

- (void)createComponents;
- (void)createSubCntntsComponent;
- (void)menuAllClose;

@end
