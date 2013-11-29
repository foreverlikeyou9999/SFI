//
//	ReaderViewController.h
//	Reader v2.3.0
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011 Julius Oklamcak. All rights reserved.
//
//	This work is being made available under a Creative Commons Attribution license:
//		«http://creativecommons.org/licenses/by/3.0/»
//	You are free to use this work and any derivatives of this work in personal and/or
//	commercial products and projects as long as the above copyright is maintained and
//	the original author is attributed.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "ReaderDocument.h"
#import "ReaderContentView.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ThumbsViewController.h"
//#import "OutlineViewController.h"
#import "OutlineItem.h"
#import "IndexListView.h"
#import "ProductListView.h"
#import "httpRequest.h"

@class PDFDocumentHelper;
@class ReaderViewController;
@class ReaderMainToolbar;
@class ReaderScrollView;


@protocol ReaderViewControllerDelegate <NSObject>

@optional // Delegate protocols

- (void)dismissReaderViewController:(ReaderViewController *)viewController;

@end

@interface ReaderViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, 
													ReaderMainToolbarDelegate, ReaderMainPagebarDelegate, ReaderContentViewDelegate,
													ThumbsViewControllerDelegate, OutlineViewControllerDelegate,UIAlertViewDelegate, IndexListViewDelegate, ProductListViewDelegate>
{
@private // Instance variables

	ReaderDocument *document;

	ReaderMainToolbar *mainToolbar;

	ReaderMainPagebar *mainPagebar;

	ReaderScrollView *theScrollView;

	NSMutableDictionary *contentViews;

	UIPrintInteractionController *printInteraction;

	NSInteger currentPage;

	CGSize lastAppearSize;

	NSDate *lastHideTime;

	BOOL isVisible;
    
    
   // UIAlertView             *alertView;
    
    PDFDocumentHelper   *pdfhelper;
    
    OutlineItem* root;
	int outlineCount;
	NSMutableArray* outlineItems; 
    
    NSString * contentsID;          // 컨텐츠 ID
    BOOL isDelete;                  // file 삭제 여부
    IndexListView *indexView;       // 인덱스 리스트 뷰
    ProductListView *productView;   // 제품 리스트 뷰
    NSArray *allProductListData;    // 전체 제품 리스트 데이타
    NSMutableArray *pageProductListData;   // 현재 페이지 제품 리스트 데이타
   
}

@property (nonatomic, assign, readwrite) id <ReaderViewControllerDelegate> delegate;

@property (nonatomic, retain) PDFDocumentHelper  *pdfhelper;
@property (nonatomic, retain) NSMutableArray* outlineItems; 
@property (nonatomic, retain) NSString * contentsID;
@property (nonatomic, assign) BOOL isDelete;
@property (nonatomic, retain) IndexListView *indexView;
@property (nonatomic, retain) ProductListView *productView;
@property (nonatomic, retain) NSArray *allProductListData;
@property (nonatomic, retain) NSMutableArray *pageProductListData;

- (id)initWithReaderDocument:(ReaderDocument *)object;
- (void)showDocumentPage:(NSInteger)page;

-(void) pdfloadFromPDFDocument:(CGPDFDocumentRef) PDFloadDocument;

-(void) pdfupdateOutlines:(OutlineItem*) pdfoutlineItem;

@end
