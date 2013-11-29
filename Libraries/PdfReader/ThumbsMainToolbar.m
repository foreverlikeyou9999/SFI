//
//	ThumbsMainToolbar.m
//	Reader v2.4.0
//
//	Created by Julius Oklamcak on 2011-09-01.
//	Copyright © 2011 Julius Oklamcak. All rights reserved.
//
//	This work is being made available under a Creative Commons Attribution license:
//		«http://creativecommons.org/licenses/by/3.0/»
//	You are free to use this work and any derivatives of this work in personal and/or
//	commercial products and projects as long as the above copyright is maintained and
//	the original author is attributed.
//

#import "ReaderConstants.h"
#import "ThumbsMainToolbar.h"
//#import "kNewsletterAppDelegate.h"
#import "Define.h"

@implementation ThumbsMainToolbar

#pragma mark Constants

#define BUTTON_X 12.0f
#define BUTTON_Y 10.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 24.0f

#define DONE_BUTTON_WIDTH 24.0f
#define SHOW_CONTROL_WIDTH 78.0f

#define TITLE_MINIMUM_WIDTH 128.0f
#define TITLE_HEIGHT 28.0f

#pragma mark Properties

@synthesize delegate;

@synthesize _rightBtn;

#pragma mark ThumbsMainToolbar instance methods

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

		//UIImage *imageH = [UIImage imageNamed:@"Reader-Button-H.png"];
		//UIImage *imageN = [UIImage imageNamed:@"Reader-Button-N.png"];

		//UIImage *buttonH = [imageH stretchableImageWithLeftCapWidth:5 topCapHeight:0];
		//UIImage *buttonN = [imageN stretchableImageWithLeftCapWidth:5 topCapHeight:0];

		CGFloat titleX = BUTTON_X; CGFloat titleWidth = (viewWidth - (titleX + titleX));

        
        //확인 버튼 이미지로 변경...
        //1."Done"버튼
		UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];

		doneButton.frame = CGRectMake(viewWidth- DONE_BUTTON_WIDTH - BUTTON_SPACE, BUTTON_Y, DONE_BUTTON_WIDTH, BUTTON_HEIGHT);
		//[doneButton setTitle:NSLocalizedString(@"확인", @"button") forState:UIControlStateNormal];
		//[doneButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		//[doneButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		[doneButton setBackgroundImage:[UIImage imageNamed:@"PDF_Btn_Close_N"] forState:UIControlStateNormal];
		//[doneButton setBackgroundImage:[UIImage imageNamed:@"PDF_Btn_Close_N"] forState:UIControlStateHighlighted];
        //doneButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		doneButton.autoresizingMask = UIViewAutoresizingNone;
        
		[self addSubview:doneButton];

		titleX += (DONE_BUTTON_WIDTH + BUTTON_SPACE); titleWidth -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);
        
        
        
        

#if (READER_BOOKMARKS == TRUE) // Option

		CGFloat showControlX = (viewWidth - (SHOW_CONTROL_WIDTH + BUTTON_SPACE));
        
        NSLog(@"float : %f",titleX);

     
        //버튼 두개 로 처리...
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_rightBtn.frame = CGRectMake (showControlX + 40, BUTTON_Y, 32,32);
        _rightBtn.tag = 0;
        [_rightBtn setBackgroundImage:[UIImage imageNamed:@"bt_07.png"] forState:UIControlStateNormal];
        [_rightBtn setBackgroundImage:[UIImage imageNamed:@"bt_07_on.png"] forState:UIControlStateHighlighted];
        _rightBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_rightBtn addTarget:self action:@selector(showControlTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_rightBtn];
        
		titleWidth -= (SHOW_CONTROL_WIDTH + BUTTON_SPACE);

#endif // end of READER_BOOKMARKS Option
        
        
		if (titleWidth >= TITLE_MINIMUM_WIDTH) // Title minimum width check
		{
			CGRect titleRect = CGRectMake((titleX + 20), BUTTON_Y, titleWidth, TITLE_HEIGHT);
            
            NSLog(@"titleRect : %@",NSStringFromCGRect(titleRect));

			UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];
            
//             kNewsletterAppDelegate * appDelegate = (kNewsletterAppDelegate*)[[UIApplication sharedApplication] delegate];

			titleLabel.textAlignment = UITextAlignmentCenter;
			titleLabel.font = [UIFont systemFontOfSize:20.0f]; // 20 pt
			titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			titleLabel.textColor = RGBCOLOR(142, 64, 16);//[UIColor colorWithWhite:0.0f alpha:1.0f];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.adjustsFontSizeToFitWidth = YES;
			titleLabel.minimumFontSize = 14.0f;
//			titleLabel.text = appDelegate.titleYear;//title;
//            NSLog(@"title2  :%@",appDelegate.titleYear);

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

	[super dealloc];
}

#pragma mark UISegmentedControl action methods

//북마크 선택.
- (void)showControlTapped:(id)sender
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

  //  NSLog(@"tag : %d",[sender tag]);
	[delegate tappedInToolbar:self showControl:[sender tag]];
}

#pragma mark UIButton action methods

- (void)doneButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self doneButton:button];
}

@end
