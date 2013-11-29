//
//  EduListViewController.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 4..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>
//
#import "NavigationBar.h"
#import "ReaderViewController.h"
#import "EduSubViewController.h"
#import "PasswordView.h"

@protocol EduListViewControllerDelegate <NSObject>

- (void)menuIndexConnect:(NSInteger)index;

@end

@interface EduListViewController : UIViewController <NavigationBarDelegate, UIScrollViewDelegate, ReaderViewControllerDelegate, PasswordViewDelegate, EduSubViewControllerDelegate> {
    id <EduListViewControllerDelegate> __weak delegate;
    
    NSMutableArray *menuList1;
    NSMutableArray *btnArr;
    
    UIView *eduBgView;
    UIImageView *cntBgView;
    UIScrollView *menuScroll;
    
    ReaderViewController *readerViewController;
    EduSubViewController *eduSubViewController;
}

@property (nonatomic, weak) id <EduListViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *currentTopCtgry;
@property int currentMenuIndex;


@end
