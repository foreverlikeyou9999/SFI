//
//  ADGalleryViewController.h
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 16..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADGalleryViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UIActionSheetDelegate> {
    NSMutableArray *thumbnailListArr;
    NSMutableArray *btnArr;
    
    UIView *adGalBgView;
    
    UIImageView *cntBgView;
    UIView *previewBaseView;
    UIView *thumbnailBaseView;
    UIWebView *videoView;
    UIScrollView *variableBaseMenu;
    
    UIActivityIndicatorView *loading;
    
    UIScrollView *_scrollView;
    UITableView *productListView;
    UIPageControl *_pageC;
}

@property BOOL pageSetup;

@end
