//
//	ReaderViewController.m
//	Reader v2.4.0
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

#import "ReaderConstants.h"
#import "ReaderViewController.h"
#import "ReaderScrollView.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"
#import "Define.h"

#import "PDFDocumentHelper.h"
#import "httpRequest.h"
#import "ProductDetailView.h"
#import "ContentManager.h"

#import "NSData+AESAdditions.h"

#define HEIGHT            [CommonUtil osVersion]

@implementation UINavigationController (Rotation_IOS6)

-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end

@implementation ReaderViewController

#pragma mark Constants

#define PAGING_VIEWS 3

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define TAP_AREA_SIZE 48.0f

#pragma mark Properties

@synthesize delegate;
@synthesize pdfhelper;
@synthesize outlineItems;
@synthesize contentsID;
@synthesize isDelete;
@synthesize indexView;
@synthesize productView;
@synthesize allProductListData;
@synthesize pageProductListData;

#pragma mark Support methods

- (void)updateScrollViewContentSize
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger count = [document.pageCount integerValue];

	if (count > PAGING_VIEWS) count = PAGING_VIEWS; // Limit

	CGFloat contentHeight = (theScrollView.bounds.size.height);

    //pageCnt->scrolling
	CGFloat contentWidth = (theScrollView.bounds.size.width * count);

	theScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateScrollViewContentViews
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[self updateScrollViewContentSize]; // Update the content size

	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSet]; // Page set

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(id key, id object, BOOL *stop)
		{
			ReaderContentView *contentView = object; [pageSet addIndex:contentView.tag];
		}
	];

	__block CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;

	__block CGPoint contentOffset = CGPointZero; NSInteger page = [document.pageNumber integerValue];

	[pageSet enumerateIndexesUsingBlock: // Enumerate page number set
		^(NSUInteger number, BOOL *stop)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key

			ReaderContentView *contentView = [contentViews objectForKey:key];

			contentView.frame = viewRect; if (page == number) contentOffset = viewRect.origin;

			viewRect.origin.x += viewRect.size.width; // Next view frame position
		}
	];

	if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
	{
		theScrollView.contentOffset = contentOffset; // Update content offset
	}
}

- (void)updateToolbarBookmarkIcon
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSInteger page = [document.pageNumber integerValue];

	BOOL bookmarked = [document.bookmarks containsIndex:page];

	[mainToolbar setBookmarkState:bookmarked]; // Update
}
/*
 함수명    - showDocumentPage
 매개 변수 - page:선택 페이지 인덱스
 기능     - 해당 페이지 인덱스를 보여준다.
 */
- (void)showDocumentPage:(NSInteger)page
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (page != currentPage) // Only if different
	{
		NSInteger minValue; NSInteger maxValue;
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1;

		if ((page < minPage) || (page > maxPage)) return;

		if (maxPage <= PAGING_VIEWS) // Few pages
		{
			minValue = minPage;
			maxValue = maxPage;
		}
		else // Handle more pages
		{
			minValue = (page - 1);
			maxValue = (page + 1);

			if (minValue < minPage)
				{minValue++; maxValue++;}
			else
				if (maxValue > maxPage)
					{minValue--; maxValue--;}
		}

		NSMutableIndexSet *newPageSet = [NSMutableIndexSet new];

		NSMutableDictionary *unusedViews = [contentViews mutableCopy];

		CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;

		for (NSInteger number = minValue; number <= maxValue; number++)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key

			ReaderContentView *contentView = [contentViews objectForKey:key];

			if (contentView == nil) // Create a brand new document content view
			{
				NSURL *fileURL = document.fileURL; NSString *phrase = document.password; // Document properties

				contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:number password:phrase];

				[theScrollView addSubview:contentView]; [contentViews setObject:contentView forKey:key];

				contentView.delegate = self; [contentView release]; [newPageSet addIndex:number];
			}
			else // Reposition the existing content view
			{
				contentView.frame = viewRect; [contentView zoomReset];

				[unusedViews removeObjectForKey:key];
			}

			viewRect.origin.x += viewRect.size.width;
		}

		[unusedViews enumerateKeysAndObjectsUsingBlock: // Remove unused views
			^(id key, id object, BOOL *stop)
			{
				[contentViews removeObjectForKey:key];

				ReaderContentView *contentView = object;

				[contentView removeFromSuperview];
			}
		];

		[unusedViews release], unusedViews = nil; // Release unused views

		CGFloat viewWidthX1 = viewRect.size.width;
		CGFloat viewWidthX2 = (viewWidthX1 * 2.0f);

		CGPoint contentOffset = CGPointZero;

		if (maxPage >= PAGING_VIEWS)
		{
			if (page == maxPage)
				contentOffset.x = viewWidthX2;
			else
				if (page != minPage)
					contentOffset.x = viewWidthX1;
		}
		else
			if (page == (PAGING_VIEWS - 1))
				contentOffset.x = viewWidthX1;

		if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
		{
			theScrollView.contentOffset = contentOffset; // Update content offset
		}

		if ([document.pageNumber integerValue] != page) // Only if different
		{
			document.pageNumber = [NSNumber numberWithInteger:page]; // Update page number
		}

		NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid;

		if ([newPageSet containsIndex:page] == YES) // Preview visible page first
		{
			NSNumber *key = [NSNumber numberWithInteger:page]; // # key

			ReaderContentView *targetView = [contentViews objectForKey:key];

			[targetView showPageThumb:fileURL page:page password:phrase guid:guid];

			[newPageSet removeIndex:page]; // Remove visible page from set
		}

		[newPageSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock: // Show previews
			^(NSUInteger number, BOOL *stop)
			{
				NSNumber *key = [NSNumber numberWithInteger:number]; // # key

				ReaderContentView *targetView = [contentViews objectForKey:key];

				[targetView showPageThumb:fileURL page:number password:phrase guid:guid];
			}
		];

		[newPageSet release], newPageSet = nil; // Release new page set
#if (USE_MAIN_PAGEBAR == TRUE)
		[mainPagebar updatePagebar]; // Update the pagebar display
#endif
		[self updateToolbarBookmarkIcon]; // Update bookmark

		currentPage = page; // Track current page number
        
        [self updateProductListView];
	}
}

- (void)showDocument:(id)object
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[self updateScrollViewContentSize]; // Set content size

	[self showDocumentPage:[document.pageNumber integerValue]]; // Show

	document.lastOpen = [NSDate date]; // Update last opened date

	isVisible = YES; // iOS present modal bodge
}

#pragma mark UIViewController methods

- (id)initWithReaderDocument:(ReaderDocument *)object
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	id reader = nil; // ReaderViewController object

	if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]]))
	{
		if ((self = [super initWithNibName:nil bundle:nil])) // Designated initializer
		{
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

			[notificationCenter addObserver:self selector:@selector(saveReaderDocument:) name:UIApplicationWillTerminateNotification object:nil];

			[notificationCenter addObserver:self selector:@selector(saveReaderDocument:) name:UIApplicationWillResignActiveNotification object:nil];

			document = [object retain]; // Retain the supplied ReaderDocument object for our use

			reader = self; // Return an initialized ReaderViewController object
		}
	}

	return reader;
}

/*
- (void)loadView
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	// Implement loadView to create a view hierarchy programmatically, without using a nib.
}
*/

- (void)viewDidLoad
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif

	[super viewDidLoad];

	NSAssert(!(document == nil), @"ReaderDocument == nil");

	assert(self.splitViewController == nil); // Not supported (sorry)
    
	[ReaderThumbCache createThumbCacheWithGUID:document.guid]; // Cache

	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

//    iOS7 대응
//	CGRect viewRect = self.view.bounds; // View controller's view bounds
    CGRect viewRect = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - HEIGHT);
    
    UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, HEIGHT)];
    [statusBar setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:statusBar];

	theScrollView = [[ReaderScrollView alloc] initWithFrame:viewRect]; //All

	theScrollView.scrollsToTop = NO;
	theScrollView.pagingEnabled = YES;
	theScrollView.delaysContentTouches = NO;
	theScrollView.showsVerticalScrollIndicator = NO;
	theScrollView.showsHorizontalScrollIndicator = NO;
	theScrollView.contentMode = UIViewContentModeRedraw;
	theScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	theScrollView.backgroundColor = [UIColor clearColor];
	theScrollView.userInteractionEnabled = YES;
	theScrollView.autoresizesSubviews = NO;
	theScrollView.delegate = self;

	[self.view addSubview:theScrollView];
    
    //Remove CJH

	NSString *toolbarTitle = (self.title == nil) ? [document.fileName stringByDeletingPathExtension] : self.title;
    

	CGRect toolbarRect = viewRect;
	toolbarRect.size.height = TOOLBAR_HEIGHT;

    NSLog(@"toolbarTitle : %@",toolbarTitle);
	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect title:toolbarTitle]; // At top

	mainToolbar.delegate = self;

	[self.view addSubview:mainToolbar];

#if (USE_MAIN_PAGEBAR == TRUE)
	CGRect pagebarRect = viewRect;
	pagebarRect.size.height = PAGEBAR_HEIGHT;
	pagebarRect.origin.y = (viewRect.size.height - PAGEBAR_HEIGHT);

	mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document]; // At bottom

	mainPagebar.delegate = self;

	[self.view addSubview:mainPagebar];
#endif
    
	UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;

	UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;

	UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapTwo.numberOfTouchesRequired = 2; doubleTapTwo.numberOfTapsRequired = 2; doubleTapTwo.delegate = self;

	[singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail

	[self.view addGestureRecognizer:singleTapOne]; [singleTapOne release];
	[self.view addGestureRecognizer:doubleTapOne]; [doubleTapOne release];
	[self.view addGestureRecognizer:doubleTapTwo]; [doubleTapTwo release];

	contentViews = [NSMutableDictionary new]; lastHideTime = [NSDate new];
    
    
    // 제품 목록 가져오기
    if ([[[GlobalValue sharedSingleton] value] isEqualToString:@"contents"]) {
        if(contentsID) {
            [self requestProductList:self.contentsID];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif

	[super viewWillAppear:animated];

	if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
	{
		if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
		{
			[self updateScrollViewContentViews]; // Update content views
		}

		lastAppearSize = CGSizeZero; // Reset view size tracking
	}
}

- (void)viewDidAppear:(BOOL)animated
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif

	[super viewDidAppear:animated];

	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero)) // First time
	{
		[self performSelector:@selector(showDocument:) withObject:nil afterDelay:0.0];
	}

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = YES;

#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewWillDisappear:(BOOL)animated
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif

	[super viewWillDisappear:animated];

	lastAppearSize = self.view.bounds.size; // Track view size

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = NO;

#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewDidDisappear:(BOOL)animated
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif

	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[mainToolbar release], mainToolbar = nil; [mainPagebar release], mainPagebar = nil;

	[theScrollView release], theScrollView = nil; [contentViews release], contentViews = nil;

	[lastHideTime release], lastHideTime = nil; lastAppearSize = CGSizeZero; currentPage = 0;

	[super viewDidUnload];
}

//for iOS6-------
-(BOOL)shouldAutorotate {
#ifdef DEBUGX
	NSLog(@"%s (%d)", __FUNCTION__, self.preferredInterfaceOrientationForPresentation);
#endif
    
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSArray *arrayComponent = [osVersion pathComponents];
    NSLog(@"iOS version is %d", [[arrayComponent objectAtIndex:0] intValue]);
    
    
    
    if ([[arrayComponent objectAtIndex:0] intValue] < 5) {
        // viewRect = CGRectMake(0, 0, 320, 460);
        
        // outlineView._tableOutlineView.frame = viewRect;
        
        return NO;
        
    }else {
        
        return YES;
    }
}

//-(BOOL)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskAll;
//}
- (BOOL)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
//-------for iOS6

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#ifdef DEBUGX
	NSLog(@"%s (%d)", __FUNCTION__, interfaceOrientation);
#endif
    
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];  
    NSArray *arrayComponent = [osVersion pathComponents];  
    NSLog(@"iOS version is %d", [[arrayComponent objectAtIndex:0] intValue]);  
    
    
    
    if ([[arrayComponent objectAtIndex:0] intValue] < 5) {
        // viewRect = CGRectMake(0, 0, 320, 460); 
        
        // outlineView._tableOutlineView.frame = viewRect;
        
        return NO;
        
    }else {
        
        return YES;
    }
    
//#ifdef AUTO_ROTATE
//    return YES;
//#else
//	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // See README
//		return UIInterfaceOrientationIsPortrait(interfaceOrientation);
//	else
//		return YES;
//#endif
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
#ifdef DEBUGX
	NSLog(@"%s %@ (%d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), toInterfaceOrientation);
#endif

	if (isVisible == NO) return; // iOS present modal bodge

	if (printInteraction != nil) [printInteraction dismissAnimated:NO];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
#ifdef DEBUGX
	NSLog(@"%s %@ (%d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), interfaceOrientation);
#endif

	if (isVisible == NO) return; // iOS present modal bodge

	[self updateScrollViewContentViews]; // Update content views

	lastAppearSize = CGSizeZero; // Reset view size tracking
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
#ifdef DEBUGX
	NSLog(@"%s %@ (%d to %d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), fromInterfaceOrientation, self.interfaceOrientation);
#endif

	//if (isVisible == NO) return; // iOS present modal bodge

	//if (fromInterfaceOrientation == self.interfaceOrientation) return;
}

- (void)didReceiveMemoryWarning
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

	[notificationCenter removeObserver:self name:UIApplicationWillTerminateNotification object:nil];

	[notificationCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];

	[mainToolbar release], mainToolbar = nil; [mainPagebar release], mainPagebar = nil;

	[theScrollView release], theScrollView = nil; [contentViews release], contentViews = nil;

	[lastHideTime release], lastHideTime = nil; [document release], document = nil;

    [pdfhelper release];
    [outlineItems release];
    [contentsID release];
    [indexView release];
    [productView release];
    [allProductListData release];
    [pageProductListData release];
    
	[super dealloc];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	__block NSInteger page = 0;

	CGFloat contentOffsetX = scrollView.contentOffset.x;

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(id key, id object, BOOL *stop)
		{
			ReaderContentView *contentView = object;

			if (contentView.frame.origin.x == contentOffsetX)
			{
				page = contentView.tag; *stop = YES;
			}
		}
	];

	if (page != 0) [self showDocumentPage:page]; // Show the page
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[self showDocumentPage:theScrollView.tag]; // Show page

	theScrollView.tag = 0; // Clear page number tag
}

- (void)scrollViewTouchesBegan:(UIScrollView *)scrollView touches:(NSSet *)touches
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#if (USE_MAIN_PAGEBAR == TRUE)
	if ((mainToolbar.hidden == NO) || (mainPagebar.hidden == NO))
#else
    if (mainToolbar.hidden == NO)
#endif
	{
		if (touches.count == 1) // Single touches only
		{
			UITouch *touch = [touches anyObject]; // Touch info

			CGPoint point = [touch locationInView:self.view]; // Touch location

			CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);

			if (CGRectContainsPoint(areaRect, point) == false) return;
		}
#if NOT_USED    //(고객요청사항)항상 노출되도록 수정
		[mainToolbar hideToolbar];
#if (USE_MAIN_PAGEBAR == TRUE)
        [mainPagebar hidePagebar]; // Hide
#endif
        //[indexView hideBar];
        [self hideOutlineView];
        [productView hideBar];
#endif
        
		[lastHideTime release]; lastHideTime = [NSDate new];
	}
}




#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ([touch.view isMemberOfClass:[ReaderScrollView class]]) return YES;

	return NO;
}

#pragma mark UIGestureRecognizer action methods

- (void)decrementPageNumber
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum


		if ((maxPage > minPage) && (page != minPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;

			contentOffset.x -= theScrollView.bounds.size.width; // -= 1

			[theScrollView setContentOffset:contentOffset animated:YES];

			theScrollView.tag = (page - 1); // Decrement page number
		}
	}
}

- (void)incrementPageNumber
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum

		if ((maxPage > minPage) && (page != maxPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;

			contentOffset.x += theScrollView.bounds.size.width; // += 1

			[theScrollView setContentOffset:contentOffset animated:YES];

			theScrollView.tag = (page + 1); // Increment page number
		}
	}
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view];

		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area

		if (CGRectContainsPoint(areaRect, point)) // Single tap is inside the area
		{
			NSInteger page = [document.pageNumber integerValue]; // Current page #

			NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key

			ReaderContentView *targetView = [contentViews objectForKey:key];

			id target = [targetView singleTap:recognizer]; // Process tap

			if (target != nil) // Handle the returned target object
			{
				if ([target isKindOfClass:[NSURL class]]) // Open a URL
				{
					[[UIApplication sharedApplication] openURL:target];
				}
				else // Not a URL, so check for other possible object type
				{
					if ([target isKindOfClass:[NSNumber class]]) // Goto page
					{
						NSInteger value = [target integerValue]; // Number

						[self showDocumentPage:value]; // Show the page
					}
				}
			}
			else // Nothing active tapped in the target content view
			{
				if ([lastHideTime timeIntervalSinceNow] < -0.75) // Delay since hide
				{
#if (USE_MAIN_PAGEBAR == TRUE)
					if ((mainToolbar.hidden == YES) || (mainPagebar.hidden == YES))
					{
						[mainToolbar showToolbar]; [mainPagebar showPagebar]; // Show
					}
#else
                    if ((mainToolbar.hidden == YES))
					{
						[mainToolbar showToolbar]; // Show
                        
                        [indexView showBar];
                        [productView showBar];
					}
#endif
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	} 
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view];

		CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE);

		if (CGRectContainsPoint(zoomArea, point)) // Double tap is in the zoom area
		{
			NSInteger page = [document.pageNumber integerValue]; // Current page #

			NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key

			ReaderContentView *targetView = [contentViews objectForKey:key];

			switch (recognizer.numberOfTouchesRequired) // Touches count
			{
				case 1: // One finger double tap: zoom ++
				{
					[targetView zoomIncrement]; break;
				}

				case 2: // Two finger double tap: zoom --
				{
					[targetView zoomDecrement]; break;
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}

#pragma mark ReaderMainToolbarDelegate methods

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#if (READER_STANDALONE == FALSE) // Option

	[document saveReaderDocument]; // Save any ReaderDocument object changes

	[[ReaderThumbQueue sharedInstance] cancelOperationsWithGUID:document.guid];

	[[ReaderThumbCache sharedInstance] removeAllObjects]; // Empty the thumb cache

	if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismiss

	if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
	{
        // 삭제 플래그가 있을경우 파일 삭제
        if(isDelete)
        {
            [ContentManager DeletePDFFile:document.fileName TARGET:SAVE_PDF];
        }
        // NOT_USED
        //[self.httpRequest requestCancel];

		[delegate dismissReaderViewController:self]; // Dismiss the ReaderViewController
	}
	else // We have a "Delegate must respond to -dismissReaderViewController: error"
	{
		NSAssert(NO, @"Delegate must respond to -dismissReaderViewController:");
	}

#endif // end of READER_STANDALONE Option
    
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar thumbsButton:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismiss

	ThumbsViewController *thumbsViewController = [[ThumbsViewController alloc] initWithReaderDocument:document];
    
    NSLog(@"Thumbtitle : %@",self.title);

	thumbsViewController.delegate = self; thumbsViewController.title = self.title;

	thumbsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	thumbsViewController.modalPresentationStyle = UIModalPresentationFullScreen;

	[self presentModalViewController:thumbsViewController animated:NO];

	[thumbsViewController release]; // Release ThumbsViewController
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar printButton:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#if (READER_ENABLE_PRINT == TRUE) // Option

	Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");

	if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
	{
		NSURL *fileURL = document.fileURL; // Document file URL

		printInteraction = [printInteractionController sharedPrintController];

		if ([printInteractionController canPrintURL:fileURL] == YES)
		{
			UIPrintInfo *printInfo = [NSClassFromString(@"UIPrintInfo") printInfo];

			printInfo.duplex = UIPrintInfoDuplexLongEdge;
			printInfo.outputType = UIPrintInfoOutputGeneral;
			printInfo.jobName = document.fileName;

			printInteraction.printInfo = printInfo;
			printInteraction.printingItem = fileURL;
			printInteraction.showsPageRange = YES;

			[printInteraction presentFromRect:button.bounds inView:button animated:YES completionHandler:
				^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
				{
					#ifdef DEBUG
						if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
					#endif
				}
			];
		}
	}

#endif // end of READER_ENABLE_PRINT Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar emailButton:(UIButton *)button
{
    
//    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
//    
//    if (mailController) {
// 
//        mailController.mailComposeDelegate = self;
//        [mailController setSubject:@"kolon사보 문의사항."];
//        [mailController setToRecipients:[NSArray arrayWithObjects:@"sabo@kolon.com", nil]];
//        [self presentModalViewController:mailController animated:YES];
//        [mailController release];
//
//    }
    
/* 
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#if (READER_ENABLE_MAIL == TRUE) // Option

	if ([MFMailComposeViewController canSendMail] == NO) return;

	if (printInteraction != nil) [printInteraction dismissAnimated:YES];

	unsigned long long fileSize = [document.fileSize unsignedLongLongValue];

	if (fileSize < (unsigned long long)15728640) // Check attachment size limit (15MB)
	{
		NSURL *fileURL = document.fileURL; NSString *fileName = document.fileName; // Document

		NSData *attachment = [NSData dataWithContentsOfURL:fileURL options:(NSDataReadingMapped|NSDataReadingUncached) error:nil];

		if (attachment != nil) // Ensure that we have valid document file attachment data
		{
			MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];

			[mailComposer addAttachmentData:attachment mimeType:@"application/pdf" fileName:fileName];

			[mailComposer setSubject:fileName]; // Use the document file name for the subject

			mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;

			mailComposer.mailComposeDelegate = self; // Set the delegate

			[self presentModalViewController:mailComposer animated:YES];

			[mailComposer release]; // Cleanup
		}
	}
	else // The document file is too large to email alert
	{
		UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FileTooLargeTitle", @"text")
								message:NSLocalizedString(@"FileTooLargeMessage", @"text") delegate:NULL
								cancelButtonTitle:NSLocalizedString(@"OK", @"button") otherButtonTitles:nil];

		[theAlert show]; [theAlert release]; // Show and cleanup
	}

#endif // end of READER_ENABLE_MAIL Option
    
    
    */
    
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar markButton:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (printInteraction != nil) [printInteraction dismissAnimated:YES];

	NSInteger page = [document.pageNumber integerValue];

	if ([document.bookmarks containsIndex:page])
	{
		[mainToolbar setBookmarkState:NO];

		[document.bookmarks removeIndex:page];
	}
	else // Add the bookmarked page index
	{
		[mainToolbar setBookmarkState:YES];

		[document.bookmarks addIndex:page];
	}
}


-(void) pdfloadFromPDFDocument:(CGPDFDocumentRef) PDFloadDocument
{
	self.pdfhelper = [[[PDFDocumentHelper alloc] initWithDocument:PDFloadDocument]autorelease];
	root = [pdfhelper getOutlinesRoot];
	outlineCount = pdfhelper.outlineCount;
	self.outlineItems = [[[NSMutableArray alloc] init]autorelease];
    
    NSLog(@"outline : %d",outlineCount);
    
    if (outlineCount <= 0) {
        return;
    }
    
    NSLog(@"root : %@",root);
    
	[self pdfupdateOutlines:root];
   
    
}


-(void) pdfupdateOutlines:(OutlineItem*) pdfoutlineItem {
	[outlineItems addObject:pdfoutlineItem];
   // NSLog(@"outlinechild : %d",[pdfoutlineItem.children count]);
	for (int i = 0; i < [pdfoutlineItem.children count]; i++) {
		[self pdfupdateOutlines:(OutlineItem*)[pdfoutlineItem.children objectAtIndex:i]];
	}
}

 

//Add CJH
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar outlineButton:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
//    if ([button isSelected]) {
//        button.selected = NO;
//        [self hideOutlineView];
//    }
//    else {
//        button.selected = YES;
//        [self showOutlineView];
//    }
    if (self.indexView == nil) {
        [self showOutlineView];
    }
    else {
        [self hideOutlineView];
    }
}

- (void) showOutlineView
{
    if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismis
    
    NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    NSLog(@"pdf : %@",pdfs);
    
    id appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    [self pdfloadFromPDFDocument:(CGPDFDocumentRef)[appDelegate getDocument]];
    
    
    if (outlineCount <= 0) {
        UIAlertView   *alertView = [[UIAlertView alloc] initWithTitle:@"알림!" message:@"목차가 존재하지 않는 카탈로그입니다." delegate:nil cancelButtonTitle:@"확 인" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        
        return;
    }
    
    self.indexView = [[[IndexListView alloc] init]autorelease];
    indexView.delegate = self;
    [self.view addSubview:indexView];
}

- (void) hideOutlineView
{
    [self.indexView removeFromSuperview];
    self.indexView = nil;
}

//Add End


//mail_response
//- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
//	switch (result) {
//		case MFMailComposeResultCancelled:
//            break;
//		case MFMailComposeResultSaved:
//			break;
//		case MFMailComposeResultSent:
//        {
//             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"성공" message:@"성공적으로 보냈습니다." delegate:nil cancelButtonTitle:@"확 인" otherButtonTitles:nil];
//            [alert show];
//            [alert release];
//        }
//            break;
//		case MFMailComposeResultFailed:
//        {           
//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"실패" message:@"전송에 실패했습니다." delegate:nil cancelButtonTitle:@"확 인" otherButtonTitles:nil];
//            [alert show];
//            [alert release];
//        }
//			break;
//	}
//   
//    
//	[controller dismissModalViewControllerAnimated:YES];
//}



/*
#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#ifdef DEBUG
	if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
#endif

	[self dismissModalViewControllerAnimated:YES]; // Dismiss
}
 */


#pragma mark ThumbsViewControllerDelegate methods

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

//	[self dismissModalViewControllerAnimated:NO]; // Dismiss
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[self showDocumentPage:page]; // Show the page
}

#pragma mark OutlineViewControllerDelegate methods

- (void)dismissOutlineViewController:(OutlineViewController *)viewController
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
//	[self dismissModalViewControllerAnimated:NO]; // Dismiss
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)outlineViewController:(OutlineViewController *)viewController gotoPage:(NSInteger)page
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
    NSLog(@"outlinePag : %d",page);
    
	[self showDocumentPage:page]; // Show the page
}

#pragma mark ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[self showDocumentPage:page]; // Show the page
}

#pragma mark Notification methods

- (void)saveReaderDocument:(NSNotification *)notification
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[document saveReaderDocument]; // Save any ReaderDocument object changes
}

#pragma mark IndexListViewDelegate

- (void)indexListViewGoToPage:(NSInteger)page
{
    [self showDocumentPage:page]; // Show the page
 
    [self hideOutlineView];
    
#if NOT_USED
    // create indexList view
    id appDelegate = [[UIApplication sharedApplication] delegate];
    [self pdfloadFromPDFDocument:(CGPDFDocumentRef)[appDelegate getDocument]];
    if (outlineCount > 0) {
        self.indexView = [[[IndexListView alloc] init]autorelease];
        indexView.delegate = self;
        [self.view addSubview:indexView];
    }
#endif

}

#pragma mark - ProductList
- (void)requestProductList:(NSString *)contentID
{
    if (contentID == nil) {
        return;
    }
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&shopCd=%@&cntntsId=%@&accessToken=%@&timestamp=%0.f"
                     , KHOST
                     , LISTPRODUCT
                     , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                     , [[NSUserDefaults standardUserDefaults] objectForKey:@"shopCd"]
                     , contentID
                     , [temp hexadecimalString]
                     , timeInMiliseconds];
    httpRequest *_httpRequest = [[httpRequest alloc] init];
    [_httpRequest setDelegate:self selector:@selector(result:)];
    [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    [_httpRequest release];
}

- (void)result:(NSString *)data {
    NSLog(@"data : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            //            NSLog(@"dic : %@", [resultsDictionary objectForKey:@"results"]);

            // data
            self.allProductListData = [resultsDictionary objectForKey:@"results"];

            // create productList
            [self createProductListView];
            
        } else if ([result isEqualToString:@"401.1"]) {//인증오류
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
        } else if ([result isEqualToString:@"401.100"]) {//인증오류_FA
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
        } else if ([result isEqualToString:@"401.101"]) {//단말 미등록
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
        } else if ([result isEqualToString:@"401.102"]) {//단말 미승인
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
        } else if ([result isEqualToString:@"401.103"]) {//단말 분실
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDirectory = [paths objectAtIndex:0];
            NSString *dir = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce"]];
            
            NSError *error = nil;
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:dir error:&error];
            
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app logout:@"yes"];
        } else if ([result isEqualToString:@"401.104"]) {//비밀번호 5회이상 오류
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
        } else if ([result isEqualToString:@"401.105"]) {//요청시간 초과
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            
            [alertView show];
            [alertView release];
        }
    } else {
        NSLog(@"통신에러");
    }
}

- (void)doNetworkErrorProcess {
    NSLog(@"login error");
}

// productListData에 currentPage데이터가 있을경우 제품리스트 보여준다.
- (void) createProductListView
{
    // (고객요청사항) 제품이 없는경우에도 제품리스트 메뉴가 나오게
//    if([self.allProductListData count] <= 0)
//        return ;
    
    self.pageProductListData = [[[NSMutableArray alloc] init] autorelease];

    //1. 현재페이지 정보가 있는지 조회
    for(NSDictionary * item in self.allProductListData) {
        if ([[item objectForKey:@"expsrOrdr"] intValue] == currentPage) {
            [self.pageProductListData addObject:item];
        }
    }
    
    [self.productView removeFromSuperview];
    //2. 있으면 뷰 생성 => (고객요청사항) 제품이 없는경우에도 제품리스트 메뉴가 나오게
//    if ([self.pageProductListData count] > 0)
    {
        self.productView = [[[ProductListView alloc] init]autorelease];
        productView.listData = self.pageProductListData;
        productView.delegate = self;
        //툴바가 hide면 hide
        if (mainToolbar.hidden == YES)
        {
            productView.hidden = YES;
        }
        [self.view addSubview:productView];
    }
}

- (void) updateProductListView
{
    if (self.productView == nil) {
        return;
    }
    //1. 데이터 변경
    self.pageProductListData = [[[NSMutableArray alloc] init] autorelease];
    for(NSDictionary * item in self.allProductListData) {
        if ([[item objectForKey:@"expsrOrdr"] intValue] == currentPage) {
            [self.pageProductListData addObject:item];
        }
    }
    //2. 리스트 갱신
    productView.listData = self.pageProductListData;
    [productView.productListView reloadData];
}

- (void)productListView:(ProductListView*)view didSelectedID:(NSString*) selectedID
{
    ProductDetailView *productDV = [[ProductDetailView alloc] initWithProductCd:selectedID];
    [productDV setDelegate:self selector:@selector(detailProductDismiss)];
    [self.view addSubview:productDV];
    [productDV release];
}

- (void)detailProductDismiss {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[ProductDetailView class]]) {
            [view removeFromSuperview];
        }
    }
}

@end
