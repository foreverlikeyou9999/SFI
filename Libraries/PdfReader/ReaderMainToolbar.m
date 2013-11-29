//
//	ReaderMainToolbar.m
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
#import "ReaderMainToolbar.h"

#import <MessageUI/MessageUI.h>

#import "Define.h"

@implementation ReaderMainToolbar

#pragma mark Constants

#define BUTTON_X 12.0f
#define BUTTON_Y 10.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 24.0f

#define DONE_BUTTON_WIDTH 24.0f
#define THUMBS_BUTTON_WIDTH 24.0f
#define PRINT_BUTTON_WIDTH 24.0f
#define EMAIL_BUTTON_WIDTH 24.0f
#define MARK_BUTTON_WIDTH 24.0f

#define TITLE_MINIMUM_WIDTH 128.0f
#define TITLE_HEIGHT 28.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark ReaderMainToolbar instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [self initWithFrame:frame title:nil];
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super initWithFrame:frame]))
	{
		CGFloat viewWidth = self.bounds.size.width;
        
        

//		UIImage *imageH = [UIImage imageNamed:@"Reader-Button-H.png"];
//		UIImage *imageN = [UIImage imageNamed:@"Reader-Button-N.png"];

//		UIImage *buttonH = [imageH stretchableImageWithLeftCapWidth:5 topCapHeight:0];
//		UIImage *buttonN = [imageN stretchableImageWithLeftCapWidth:5 topCapHeight:0];

		CGFloat titleX = BUTTON_X; CGFloat titleWidth = (viewWidth - (titleX + titleX));

		CGFloat leftButtonX = BUTTON_X; // Left button start X position

#if (READER_STANDALONE == FALSE) // Option

        //1. "index"버튼
		UIButton *outlineButton = [UIButton buttonWithType:UIButtonTypeCustom];

		outlineButton.frame = CGRectMake(leftButtonX, BUTTON_Y, DONE_BUTTON_WIDTH, BUTTON_HEIGHT);
		[outlineButton addTarget:self action:@selector(outlineButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[outlineButton setBackgroundImage:[UIImage imageNamed:@"PDF_Btn_Index_N"] forState:UIControlStateNormal];
        [outlineButton setBackgroundImage:[UIImage imageNamed:@"PDF_Btn_Index_O"] forState:UIControlStateHighlighted];
		outlineButton.autoresizingMask = UIViewAutoresizingNone;

		[self addSubview:outlineButton];
        
        leftButtonX += (DONE_BUTTON_WIDTH + BUTTON_SPACE);
		titleX += (DONE_BUTTON_WIDTH + BUTTON_SPACE); titleWidth -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);

#endif // end of READER_STANDALONE Option

#if (READER_ENABLE_THUMBS == TRUE) // Option

        //2. "Thumbs"버튼
		UIButton *thumbsButton = [UIButton buttonWithType:UIButtonTypeCustom];

		thumbsButton.frame = CGRectMake(leftButtonX + 10, BUTTON_Y, THUMBS_BUTTON_WIDTH, BUTTON_HEIGHT);
		[thumbsButton setImage:[UIImage imageNamed:@"PDF_Btn_Thumb_N"] forState:UIControlStateNormal];
        [thumbsButton setImage:[UIImage imageNamed:@"PDF_Btn_Thumb_O"] forState:UIControlStateHighlighted];
		[thumbsButton addTarget:self action:@selector(thumbsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		//[thumbsButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		//[thumbsButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		thumbsButton.autoresizingMask = UIViewAutoresizingNone;

		[self addSubview:thumbsButton]; //leftButtonX += (THUMBS_BUTTON_WIDTH + BUTTON_SPACE);

		titleX += (THUMBS_BUTTON_WIDTH + BUTTON_SPACE); titleWidth -= (THUMBS_BUTTON_WIDTH + BUTTON_SPACE);

#endif // end of READER_ENABLE_THUMBS Option
        
        //2. "Outline"버튼
//        leftButtonX += (THUMBS_BUTTON_WIDTH + BUTTON_SPACE);
//		UIButton *outlineButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        
//		outlineButton.frame = CGRectMake(leftButtonX, BUTTON_Y, 32, 32);
//		[outlineButton setImage:[UIImage imageNamed:@"bt_08.png"] forState:UIControlStateNormal];
//        [outlineButton setImage:[UIImage imageNamed:@"bt_08_on.png"] forState:UIControlStateHighlighted];
//		[outlineButton addTarget:self action:@selector(outlineButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//        outlineButton.autoresizingMask = UIViewAutoresizingNone;
//        
//		[self addSubview:outlineButton]; //leftButtonX += (THUMBS_BUTTON_WIDTH + BUTTON_SPACE);
        
//		titleX += (THUMBS_BUTTON_WIDTH + BUTTON_SPACE); titleWidth -= (THUMBS_BUTTON_WIDTH + BUTTON_SPACE);

		CGFloat rightButtonX = viewWidth; // Right button start X position

#if (READER_BOOKMARKS == TRUE) // Option

		rightButtonX -= (MARK_BUTTON_WIDTH + BUTTON_SPACE);
        
        NSLog(@"right : %f",rightButtonX);
        
        NSLog(@"button : %f",BUTTON_Y);

        //3. "Bookmark"버튼
		UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];

		flagButton.frame = CGRectMake(rightButtonX + 5, BUTTON_Y, 32,32);//MARK_BUTTON_WIDTH, BUTTON_HEIGHT);
		//[flagButton setImage:[UIImage imageNamed:@"Reader-Mark-N.png"] forState:UIControlStateNormal];
		[flagButton addTarget:self action:@selector(markButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[flagButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        [flagButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		flagButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

		[self addSubview:flagButton]; titleWidth -= (MARK_BUTTON_WIDTH + BUTTON_SPACE);
        
        NSLog(@"title : %f",titleWidth);

		markButton = [flagButton retain]; markButton.enabled = NO; markButton.tag = NSIntegerMin;

		markImageN = [[UIImage imageNamed:@"bt_07.png"] retain]; 
		markImageY = [[UIImage imageNamed:@"bt_07_on.png"] retain]; 

#endif // end of READER_BOOKMARKS Option

//#if (READER_ENABLE_MAIL == TRUE) // Option

	//	if ([MFMailComposeViewController canSendMail] == YES)
	//	{
//			rightButtonX -= (EMAIL_BUTTON_WIDTH + BUTTON_SPACE);
//
//            //4. "Email"버튼
//			UIButton *emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
//
//			emailButton.frame = CGRectMake(rightButtonX + 10, BUTTON_Y+1, EMAIL_BUTTON_WIDTH - 7, BUTTON_HEIGHT);
//			[emailButton setImage:[UIImage imageNamed:@"bt_09.png"] forState:UIControlStateNormal];
//            [emailButton setImage:[UIImage imageNamed:@"bt_09_on.png"] forState:UIControlStateHighlighted];
//			[emailButton addTarget:self action:@selector(emailButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//			[emailButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
//			[emailButton setBackgroundImage:buttonN forState:UIControlStateNormal];
//			emailButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//
//			[self addSubview:emailButton]; titleWidth -= (EMAIL_BUTTON_WIDTH + BUTTON_SPACE);
	//	}

//#endif // end of READER_ENABLE_MAIL Option

#if (READER_ENABLE_PRINT == TRUE) // Option

		Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");

		if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
		{
			rightButtonX -= (PRINT_BUTTON_WIDTH + BUTTON_SPACE);

            //5. "Print"버튼
			UIButton *printButton = [UIButton buttonWithType:UIButtonTypeCustom];

			printButton.frame = CGRectMake(rightButtonX, BUTTON_Y, PRINT_BUTTON_WIDTH, BUTTON_HEIGHT);
			[printButton setImage:[UIImage imageNamed:@"Reader-Print.png"] forState:UIControlStateNormal];
			[printButton addTarget:self action:@selector(printButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
			[printButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
			[printButton setBackgroundImage:buttonN forState:UIControlStateNormal];
			printButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

			[self addSubview:printButton]; titleWidth -= (PRINT_BUTTON_WIDTH + BUTTON_SPACE);
		}

#endif // end of READER_ENABLE_PRINT Option
        
        
        //3. "Done"버튼
        rightButtonX -= (PRINT_BUTTON_WIDTH + BUTTON_SPACE);
		UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
		doneButton.frame = CGRectMake(rightButtonX, BUTTON_Y, DONE_BUTTON_WIDTH, BUTTON_HEIGHT);
		[doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [doneButton setImage:[UIImage imageNamed:@"PDF_Btn_Close_N"] forState:UIControlStateNormal];
        [doneButton setImage:[UIImage imageNamed:@"PDF_Btn_Close_N"] forState:UIControlStateHighlighted];
        [self addSubview:doneButton]; titleWidth -= (PRINT_BUTTON_WIDTH + BUTTON_SPACE);
        
        //[doneButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		//[doneButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		doneButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		doneButton.autoresizingMask = UIViewAutoresizingNone;
        
		[self addSubview:doneButton];
        

		if (titleWidth >= TITLE_MINIMUM_WIDTH) // Title minimum width check
		{
			CGRect titleRect = CGRectMake(titleX, BUTTON_Y, titleWidth, TITLE_HEIGHT);

			UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];

			titleLabel.textAlignment = UITextAlignmentCenter;
			titleLabel.font = [UIFont systemFontOfSize:20.0f]; // 20 pt
			titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			titleLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.adjustsFontSizeToFitWidth = YES;
			titleLabel.minimumFontSize = 14.0f;
			titleLabel.text = title;

			[self addSubview:titleLabel]; [titleLabel release];
		}
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[markButton release], markButton = nil;

	[markImageN release], markImageN = nil;
	[markImageY release], markImageY = nil;

	[super dealloc];
}

- (void)setBookmarkState:(BOOL)state
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#if (READER_BOOKMARKS == TRUE) // Option

	if (state != markButton.tag) // Only if different state
	{
		if (self.hidden == NO) // Only if toolbar is visible
		{
			UIImage *image = (state ? markImageY : markImageN);

			[markButton setImage:image forState:UIControlStateNormal];
		}

		markButton.tag = state; // Update bookmarked state tag
	}

	if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)updateBookmarkImage
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#if (READER_BOOKMARKS == TRUE) // Option

	if (markButton.tag != NSIntegerMin) // Valid tag
	{
		BOOL state = markButton.tag; // Bookmarked state

		UIImage *image = (state ? markImageY : markImageN);

		[markButton setImage:image forState:UIControlStateNormal];
	}

	if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)hideToolbar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.hidden == NO)
	{
		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.alpha = 0.0f;
			}
			completion:^(BOOL finished)
			{
				self.hidden = YES;
			}
		];
	}
}

- (void)showToolbar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.hidden == YES)
	{
		[self updateBookmarkImage]; // First

		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.hidden = NO;
				self.alpha = 1.0f;
			}
			completion:NULL
		];
	}
}

#pragma mark UIButton action methods

//확인버튼...
- (void)doneButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self doneButton:button];
}

- (void)thumbsButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self thumbsButton:button];
}

- (void)outlineButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
    [delegate tappedInToolbar:self outlineButton:button];
}

- (void)printButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self printButton:button];
}

- (void)emailButtonTapped:(UIButton *)button
{
    NSLog(@"aaa");
    
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self emailButton:button];
}

- (void)markButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self markButton:button];
}

@end
