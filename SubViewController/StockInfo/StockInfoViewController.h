//
//  StockInfoViewController.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 21..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StockInfoViewControllerDelegate <NSObject>

- (void)menuIndexConnect:(NSInteger)index;

@end

@interface StockInfoViewController : UIViewController <NavigationBarDelegate> {
    id <StockInfoViewControllerDelegate> __weak delegate;
    
    UIImageView *cntBgView;
}

@property (nonatomic, weak) id <StockInfoViewControllerDelegate> delegate;

@end
