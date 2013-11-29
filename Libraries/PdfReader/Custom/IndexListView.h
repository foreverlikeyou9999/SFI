//
//  IndexView.h
//  SalesForce
//
//  Created by 여성현 on 13. 8. 28..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OutlineItem.h"
#import "PDFDocumentHelper.h"

@protocol IndexListViewDelegate <NSObject>

@required // Delegate protocols

- (void)indexListViewGoToPage:(NSInteger)page;

@end


@interface IndexListView : UIView <UITableViewDelegate, UITableViewDataSource> {
    BOOL isShow;
    
    UITableView * tableOutlineView;
    
    OutlineItem* root;
	int outlineCount;
	NSMutableArray* outlineItems;
    
    PDFDocumentHelper* _pdfhelper;
    
    id <IndexListViewDelegate> __weak delegate;
}

@property (nonatomic, strong) UITableView * tableOutlineView;
@property (nonatomic, weak) id <IndexListViewDelegate> delegate;


- (void)hideBar;
- (void)showBar;
@end


