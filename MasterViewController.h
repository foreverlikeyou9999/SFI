//
//  MasterViewController.h
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 14..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>
//
#import <QuartzCore/QuartzCore.h>
#import <dispatch/dispatch.h>
#import "ContentsViewController.h"
#import "EduListViewController.h"
#import "ShopInfoViewController.h"
#import "RepairInfoViewController.h"
#import "StockInfoViewController.h"


@interface MasterViewController : UIViewController <UIAlertViewDelegate, UIScrollViewDelegate, ContentsViewDelegate, EduListViewControllerDelegate, ShopInfoViewControllerDelegate, RepairInfoViewControllerDelegate, StockInfoViewControllerDelegate, NSURLConnectionDelegate, UIGestureRecognizerDelegate> {
    NSArray *menuList;
    NSMutableArray *scrollArr;
    NSMutableArray *thumbArr;
    
    UIView *naviBar;
    UIView *menuListBase;
    UIView *thumbnailBase;
    UIView *screenSaverBase;
    UIView *brandSelectBase;
    
    UILabel *timeLbl;
    
    int screenSaverCnt;
    
//    LoadingView *loadingView;
    
    float          _fTot;
    NSNumber       *numberFileSize;
    NSMutableData  *receivedData;
}

@property int selectIndex;
@property (nonatomic, strong) NSTimer *screenSaverTimer;
@property (nonatomic, strong) NSTimer *timeTimer;
@property (nonatomic, strong) NSString *dirPath;

@end
