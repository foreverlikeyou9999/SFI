//
//  OutlineViewController.h
//  Reader
//
//  Created by 정후 조 on 11. 10. 6..
//  Copyright 2011 코롱베니트. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OutlineItem.h"
#import "PDFDocumentHelper.h"
#import "OutlineMainToolbar.h"
#import "ReaderThumbsView.h"

#import "OutlineView.h"

//#import "ReaderDocument.h"

@class ReaderViewController;
@class MainViewController;

@class OutlineViewController;

@protocol OutlineViewControllerDelegate <NSObject>

@required // Delegate protocols

- (void)outlineViewController:(OutlineViewController *)viewController gotoPage:(NSInteger)page;

- (void)dismissOutlineViewController:(OutlineViewController *)viewController;

@end

@interface OutlineViewController : UIViewController <OutlineMainToolbarDelegate, OutlineViewDelegate>
{
    OutlineMainToolbar *mainToolbar;
    OutlineView *outlineView;
    
    
    
    CGRect viewRect;
  //  ReaderDocument *document;
    
    NSInteger       nLandscape;
    
   // NSInteger       nResize;
}

@property (nonatomic, assign, readwrite) id <OutlineViewControllerDelegate> delegate;

- (void)showPage:(int)numberPage;

@end
