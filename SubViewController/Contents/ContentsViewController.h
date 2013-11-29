//
//  ContentsViewController.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 28..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>
//
#import "NavigationBar.h"
#import "ReaderViewController.h"
#import "ContentsSubViewController.h"
#import "ViewType_010000.h"

@protocol ContentsViewDelegate <NSObject>

- (void)menuIndexConnect:(NSInteger)index;
- (void)viewChange:(id)sender;

@end

@interface ContentsViewController : UIViewController <NavigationBarDelegate, ReaderViewControllerDelegate, UIScrollViewDelegate, ViewType_010000Delegate, ContentsSubViewControllerDelegate> {
    id <ContentsViewDelegate> __weak delegate;
    
    NSMutableArray *thumbnailListArr;
    NSMutableArray *btnArr;
    NSMutableArray *menuList1;
    
    NSMutableArray *requestArr;
    
    UIView *adGalBgView;
    UIImageView *cntBgView;
    UIScrollView *menuScroll;
    
    ReaderViewController *readerViewController;
    ContentsSubViewController *cntntsSubViewController;
    
    LoadingView *loadingView;
    
    NavigationBar *naviBar;
    
    NSDictionary *currentCtgry;
}

@property (nonatomic, weak) id <ContentsViewDelegate> delegate;
@property (nonatomic, strong) NSDictionary *currentTopCtgry;
//@property (nonatomic, retain) NSString *ctgryName;
@property (nonatomic, strong) LoadingView *loadingView;
@property int currentMenuIndex;

- (void)goHome;
//- (void)cntntsLoadingView;

@end
