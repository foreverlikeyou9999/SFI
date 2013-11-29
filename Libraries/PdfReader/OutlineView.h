//
//  OutlineView.h
//  Reader
//
//  Created by 정후 조 on 11. 10. 7..
//  Copyright 2011 코롱베니트. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OutlineItem.h"
#import "PDFDocumentHelper.h"

@interface UIView (OutlineViewController)
- (UIViewController *) firstAvailableUIViewController;
- (id) traverseResponderChainForUIViewController;
@end

@class OutlineView;

@protocol OutlineViewDelegate <NSObject, UIScrollViewDelegate>

@required // Delegate protocols

- (NSUInteger)numberOfThumbsInThumbsView:(OutlineView *)thumbsView;

- (id)thumbsView:(OutlineView *)thumbsView thumbCellWithFrame:(CGRect)frame;

- (void)thumbsView:(OutlineView *)thumbsView updateThumbCell:(id)thumbCell forIndex:(NSInteger)index;

- (void)thumbsView:(OutlineView *)thumbsView didSelectThumbWithIndex:(NSInteger)index;

@optional // Delegate protocols

- (void)thumbsView:(OutlineView *)thumbsView refreshThumbCell:(id)thumbCell forIndex:(NSInteger)index;

@end

@interface OutlineView : UIView <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> 
{
    UITableView * _tableOutlineView;
    
    OutlineItem* root;
	int outlineCount;
	NSMutableArray* outlineItems; 
    
    PDFDocumentHelper* _pdfhelper;
    
}

@property (nonatomic, retain)UITableView * _tableOutlineView;

-(void) loadFromFileName:(NSString*) fileName;
-(void) loadFromPDFDocument:(CGPDFDocumentRef) PDFDocument;
-(void) updateOutlines:(OutlineItem*) outlineItem;

//- (void)tableReloadviews:(CGRect)tableFrame;
@end
