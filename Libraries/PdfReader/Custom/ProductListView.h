//
//  ProductListView.h
//  SalesForce
//
//  Created by 여성현 on 13. 8. 29..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProductListView;

@protocol ProductListViewDelegate <NSObject>

@optional // Delegate protocols

- (void)productListView:(ProductListView*)view didSelectedID:(NSString*) selectedID;

@end


@interface ProductListView : UIView <UITableViewDelegate, UITableViewDataSource> {
    BOOL isShow;
}

@property (nonatomic, strong) UIButton *headerBtn;
@property (nonatomic, strong) UITableView * productListView;
@property (nonatomic, strong) NSArray * listData;
@property (nonatomic, weak) id <ProductListViewDelegate> delegate;

- (void)hideBar;
- (void)showBar;
@end