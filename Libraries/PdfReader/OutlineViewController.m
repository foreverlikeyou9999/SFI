//
//  OutlineViewController.m
//  Reader
//
//  Created by 정후 조 on 11. 10. 6..
//  Copyright 2011 코롱베니트. All rights reserved.
//

#import "OutlineViewController.h"
#import "ReaderViewController.h"
#import "AppDelegate.h"
#import "Define.h"

#define TOOLBAR_HEIGHT 44.0f


@implementation OutlineViewController

@synthesize delegate;

-(id)init
{
	self = [super init];
	if (self != nil) 
	{
		[self setTitle:@"Outline"];	
	}
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [outlineView._tableOutlineView reloadData];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    //
//    NSAssert(!(document == nil), @"ReaderDocument == nil");
//    
//	assert(self.splitViewController == nil); // Not supported (sorry)
//    
//	[ReaderThumbCache createThumbCacheWithGUID:document.guid]; // Cache
    //
    
	//CGRect 
    //if (nLandscape != 1) {
        viewRect = self.view.bounds; // View controller's view bounds    
   // }
    
    
    
    NSLog(@"mainframe : %@", NSStringFromCGRect(self.view.frame));
    
    NSLog(@"rect1: %@", NSStringFromCGRect(viewRect));
    
	//NSString *toolbarTitle = (self.title == nil) ? [document.fileName stringByDeletingPathExtension] : self.title;
    
	CGRect toolbarRect = viewRect; 
    toolbarRect.size.height = TOOLBAR_HEIGHT;
    
    NSLog(@"rect2: %@", NSStringFromCGRect(toolbarRect));

	mainToolbar = [[OutlineMainToolbar alloc] initWithFrame:toolbarRect title:@"목차"]; 
    mainToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	mainToolbar.delegate = self;
    
	[self.view addSubview:mainToolbar];
    
	CGRect thumbsRect = viewRect; UIEdgeInsets insets = UIEdgeInsetsZero;
    
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		thumbsRect.origin.y += TOOLBAR_HEIGHT; thumbsRect.size.height -= TOOLBAR_HEIGHT;
	}
	else // Set UIScrollView insets for non-UIUserInterfaceIdiomPad case
	{
		insets.top = TOOLBAR_HEIGHT;
    }
    NSLog(@"rect4444: %@", NSStringFromCGRect(thumbsRect));
	
    outlineView = [[OutlineView alloc] initWithFrame:thumbsRect];
    [self.view insertSubview:outlineView belowSubview:mainToolbar];    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark ThumbsMainToolbarDelegate methods

- (void)tappedInToolbar:(ThumbsMainToolbar *)toolbar showControl:(NSInteger)control
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
    //북마크.
    [self dismissModalViewControllerAnimated:NO];    
}


- (void)tappedInToolbar:(ThumbsMainToolbar *)toolbar doneButton:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
    [self dismissModalViewControllerAnimated:NO]; // Dismiss
}

//for IPhone5-------
-(BOOL)shouldAutorotate {
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSArray *arrayComponent = [osVersion pathComponents];
    NSLog(@"iOS version is %d", [[arrayComponent objectAtIndex:0] intValue]);
    
    
    
    if ([[arrayComponent objectAtIndex:0] intValue] < 5) {
        // viewRect = CGRectMake(0, 0, 320, 460);
        
        // outlineView._tableOutlineView.frame = viewRect;
        
        return NO;
        
    }else {
        
        
        nLandscape = 1;
        if (UIInterfaceOrientationIsPortrait(self.preferredInterfaceOrientationForPresentation)) {
            viewRect = CGRectMake(0, 0, 320, 460);
            if (IS_IPHONE_5)
            {
                viewRect.size.height += 88;
            }            
            NSLog(@"가로? 세로?");
        } else {
            
            NSLog(@"세로? 가로?");
            viewRect = CGRectMake(0, 0, 480, 320);
            if (IS_IPHONE_5)
            {
                viewRect.size.width += 88;
            }
        }
        outlineView._tableOutlineView.frame = viewRect;
        
        NSLog(@"frame 1111111 : %@", NSStringFromCGRect(self.view.frame));
        
        //NSLog(@"outlineframe  : %@", NSStringFromCGRect(outlineView._tableOutlineView.frame));
        
        
        return  YES;
    }
}

-(BOOL)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
//-------for IPhone5

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
        
//#ifdef AUTO_ROTATE
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];  
    NSArray *arrayComponent = [osVersion pathComponents];  
    NSLog(@"iOS version is %d", [[arrayComponent objectAtIndex:0] intValue]);  
    
    
    
    if ([[arrayComponent objectAtIndex:0] intValue] < 5) {
       // viewRect = CGRectMake(0, 0, 320, 460); 
        
       // outlineView._tableOutlineView.frame = viewRect;
        
        return NO;
        
    }else {
    
    
    nLandscape = 1;
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        viewRect = CGRectMake(0, 0, 320, 460); 
        
        NSLog(@"가로? 세로?");
    } else {
        
        NSLog(@"세로? 가로?");
        viewRect = CGRectMake(0, 0, 480, 320);
    }
    outlineView._tableOutlineView.frame = viewRect;
    
    NSLog(@"frame 1111111 : %@", NSStringFromCGRect(self.view.frame));
    
    //NSLog(@"outlineframe  : %@", NSStringFromCGRect(outlineView._tableOutlineView.frame));
   
    
    return  YES;
    }
    /*
    BOOL isPortrait = UIDeviceOrientationIsLandscape(self.interfaceOrientation);
    
    if (isPortrait) {
       viewRect = CGRectMake(0, 0, 460, 320);
        
    }else {
       viewRect = CGRectMake(0, 0, 320, 460); 
    }

    outlineView._tableOutlineView.frame = viewRect;
     
     
    return YES;
     */

    
   /*   
#else
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // See README
		return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	else
		return YES;
#endif
 */
    
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
#ifdef DEBUGX
	NSLog(@"%s %@ (%d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), toInterfaceOrientation);
#endif
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
#ifdef DEBUGX
	NSLog(@"%s %@ (%d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), interfaceOrientation);
#endif
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
   // self.view.frame = CGRectMake(0, 20, 480, 320);
#ifdef DEBUGX
	NSLog(@"%s %@ (%d to %d)", __FUNCTION__,NSStringFromCGRect(self.view.bounds) , fromInterfaceOrientation, self.interfaceOrientation);
    
#endif
    
	//if (fromInterfaceOrientation == self.interfaceOrientation) return;
}


- (void)showPage:(int)numberPage
{
//    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    ECatalogViewController * mainViewController = (ECatalogViewController*)[appDelegate GetMainViewController];
//    [((ReaderViewController*)mainViewController.modalViewController) showDocumentPage:numberPage];

    [delegate outlineViewController:self gotoPage:numberPage];
    [self dismissModalViewControllerAnimated:NO];    
}




@end
