//
//  ProductDetailView.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 22..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ProductDetailView : UIView <UIScrollViewDelegate, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UIAlertViewDelegate> {
    NSMutableArray *scrollArr;

    // View
    UIImageView *baseView;
    UILabel *titleLbl;
    UIView *productInfoView;
    UIImageView *productImg;
    UIScrollView *_prdtDScroll;
    UIWebView *productDesc;
    UITableView *table;
    
    // data
    NSMutableArray *btnArr;
    NSMutableArray *infoLblArr;
    NSMutableArray *productColorArr;
    NSMutableArray *colorBtnArr;
    NSMutableArray *inventsArr;
    NSString *productCd;    // 제품ID

    LoadingView *loadingView;
}

@property (nonatomic, strong) NSMutableArray *btnArr;
@property (nonatomic, strong) NSMutableArray *infoLblArr;
@property (nonatomic, strong) NSMutableArray *productColorArr;
@property (nonatomic, strong) NSMutableArray *colorBtnArr;
@property (nonatomic, strong) NSMutableArray *inventsArr;
@property (nonatomic, strong) NSString *productCd;

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;


- (id)initWithProductCd:(NSString*)productCd;
- (void)setDelegate:(id)aTarget selector:(SEL)aSelector;
//- (void)productsInfoRequest;

@end
