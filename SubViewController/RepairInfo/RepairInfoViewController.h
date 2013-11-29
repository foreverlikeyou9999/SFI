//
//  RepairInfoViewController.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 16..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RepairInfoViewControllerDelegate <NSObject>

- (void)menuIndexConnect:(NSInteger)index;

@end

@interface RepairInfoViewController : UIViewController <NavigationBarDelegate, UIScrollViewDelegate> {
    id <RepairInfoViewControllerDelegate> __weak delegate;
    
    NSMutableArray *btnArr;
    
    UIImageView *cntBgView;
    UIScrollView *menuScroll;
}

@property (nonatomic, weak) id <RepairInfoViewControllerDelegate> delegate;

@end