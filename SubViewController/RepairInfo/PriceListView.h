//
//  PriceListView.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 16..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PriceListView : UIView <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate> {
    NSMutableArray *sort1BtnArr;
    NSMutableArray *sort2BtnArr;
    NSMutableArray *sort3BtnArr;
    NSMutableArray *sort2InfoArr;
    NSMutableArray *sort3InfoArr;
    NSMutableArray *listInfoArr;
    
    UITableView *sort2View;
    UITableView *sort3View;
    UITableView *infoListView;
    
    NSString *sort1Str;
}

@end
