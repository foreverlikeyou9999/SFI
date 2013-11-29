//
//  ContentsSubViewController.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 9. 11..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>
//
#import "NavigationBar.h"
#import "ViewType_010003.h"

@protocol ContentsSubViewControllerDelegate <NSObject>

- (void)clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface ContentsSubViewController : UIViewController <NavigationBarDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    UIImageView *cntBgView;
    UIScrollView *aScrollView;
    
    NavigationBar *naviBar;
    
    NSDictionary *thumbDic;
    
    int pageCheck;
    BOOL pageStatus;
    
    httpRequest *productRequest;
    
    UIView *productBg;
    UIButton *headerBtn;
    UITableView *productListView;
    
    LoadingView *loadingView;
    
    NSMutableArray *btnArr;
    NSMutableArray *menuList1;
    NSMutableArray *menuList2;
    UIScrollView *menuScroll;
    
    ViewType_010003 *view010003;
    
    BOOL videoFullScreen;
}

@property (nonatomic, assign, readwrite) id <ContentsSubViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *thumbnailInfo;
@property (nonatomic, strong) NSDictionary *ctgryInfo;
@property (nonatomic, strong) NSString *rootDir;
@property (nonatomic, strong) NSMutableArray *listData;
@property int firstCtgryIndex;

@end
