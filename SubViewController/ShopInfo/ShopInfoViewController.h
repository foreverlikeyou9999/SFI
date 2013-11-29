//
//  ShopInfoViewController.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 10..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShopInfoViewControllerDelegate <NSObject>

- (void)menuIndexConnect:(NSInteger)index;

@end

@interface ShopInfoViewController : UIViewController <NavigationBarDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate> {
    id <ShopInfoViewControllerDelegate> __weak delegate;
    NSMutableArray *btnArr;
    NSMutableDictionary *shopListDic;
    NSMutableArray *textFieldArr;
    NSMutableArray *spinnerArr;
    
    UIImageView *cntBgView;
    UIImageView *areaBtnBg;
    UITableView *shopList;
    
    int cellCnt;
    int begin;
    
    BOOL pageLoadCheck;
    BOOL searchCheck;
    
//    UIActivityIndicatorView *spinner;
    NSString *searchTxt;
    
    UIView *tempBg;
}

@property (nonatomic, weak) id <ShopInfoViewControllerDelegate> delegate;

@end
