//
//  LoadingView.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 9. 5..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView
@synthesize fullBg = _fullBg;
@synthesize loadingBg = _loadingBg;
@synthesize spinner = _spinner;
@synthesize loadingImg = _loadingImg;
@synthesize receivedDataLbl = _receivedDataLbl;

#define HEIGHT            [CommonUtil osVersion]

#pragma mark - life cycle
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//        [self setAlpha:0];
//        
//        self.fullBg = [[UIView alloc] initWithFrame:frame];
//        [self.fullBg setUserInteractionEnabled:NO];
//        [self.fullBg setAlpha:0.5f];
//        [self.fullBg setBackgroundColor:[UIColor blackColor]];
//        [self addSubview:self.fullBg];
//        
//        self.loadingImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LoadingBG"]];
//        [self.loadingImg setHidden:YES];
//        [self.loadingImg setFrame:CGRectMake(self.fullBg.frame.size.width/2 - self.loadingImg.image.size.width/2, self.fullBg.frame.size.height/2 - self.loadingImg.image.size.height, self.loadingImg.image.size.width, self.loadingImg.image.size.height)];
//        [self addSubview:self.loadingImg];
//        
//        self.loadingBg = [[UIView alloc] initWithFrame:CGRectMake(self.fullBg.frame.size.width/2 - 50, self.fullBg.frame.size.height/2 - 50, 100, 100)];
//        [self.loadingBg setBackgroundColor:[UIColor grayColor]];
//        [self.loadingBg setAlpha:0.9f];
//        [_loadingBg.layer setCornerRadius:7.0f];
//        [self addSubview:self.loadingBg];
//        
//        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//        [self.spinner setFrame:CGRectMake(1, 1, 100, 100)];
//        [self.spinner setColor:[UIColor blackColor]];
//        [self.loadingBg addSubview:self.spinner];
//        
//        self.receivedDataLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, self.fullBg.frame.size.height/2 + 100, self.fullBg.frame.size.width, 40)];
//        [self.receivedDataLbl setFont:[UIFont systemFontOfSize:14.0f]];
//        [self.receivedDataLbl setNumberOfLines:0];
//        [self.receivedDataLbl setLineBreakMode:NSLineBreakByCharWrapping];
//        [self.receivedDataLbl setTextAlignment:NSTextAlignmentCenter];
//        [self.receivedDataLbl setBackgroundColor:[UIColor clearColor]];
//        [self.receivedDataLbl setTextColor:[UIColor whiteColor]];
//        [self addSubview:self.receivedDataLbl];
//    }
//    return self;
//}

- (id)init
{
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setAlpha:0];
        
        self.fullBg = [[UIView alloc] initWithFrame:frame];
        [self.fullBg setUserInteractionEnabled:NO];
        [self.fullBg setAlpha:0.5f];
        [self.fullBg setBackgroundColor:[UIColor blackColor]];
        [self addSubview:self.fullBg];
        
//        self.loadingImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LoadingBG"]];
//        [self.loadingImg setHidden:YES];
//        [self.loadingImg setFrame:CGRectMake(self.fullBg.frame.size.width/2 - self.loadingImg.image.size.width/2, self.fullBg.frame.size.height/2 - self.loadingImg.image.size.height, self.loadingImg.image.size.width, self.loadingImg.image.size.height)];
//        [self addSubview:self.loadingImg];
        
        self.loadingBg = [[UIView alloc] initWithFrame:CGRectMake(self.fullBg.frame.size.width/2 - 50, self.fullBg.frame.size.height/2 - 50, 100, 100)];
        [self.loadingBg setBackgroundColor:[UIColor grayColor]];
        [self.loadingBg setAlpha:0.9f];
        [_loadingBg.layer setCornerRadius:7.0f];
        [self addSubview:self.loadingBg];
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.spinner setFrame:CGRectMake(1, 1, 100, 100)];
        [self.spinner setColor:[UIColor blackColor]];
        [self.loadingBg addSubview:self.spinner];
        
        self.receivedDataLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, self.fullBg.frame.size.height/2 + 100, self.fullBg.frame.size.width, 40)];
        [self.receivedDataLbl setFont:[UIFont systemFontOfSize:14.0f]];
        [self.receivedDataLbl setNumberOfLines:0];
        [self.receivedDataLbl setLineBreakMode:NSLineBreakByCharWrapping];
        [self.receivedDataLbl setTextAlignment:NSTextAlignmentCenter];
        [self.receivedDataLbl setBackgroundColor:[UIColor clearColor]];
        [self.receivedDataLbl setTextColor:[UIColor whiteColor]];
        [self addSubview:self.receivedDataLbl];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - private method
- (void)startLoading {
    [UIView animateWithDuration:0.5f animations:^{
        [self setAlpha:1.0f];
        [self.spinner startAnimating];
    }];
//    [self.fullBg setAlpha:1];
}

- (void)showCntntsSet {
//    [self.loadingImg setHidden:NO];
    [self.loadingBg setBackgroundColor:[UIColor clearColor]];
    [self.loadingBg setFrame:CGRectMake(self.fullBg.frame.size.width/2 - 50, self.loadingImg.frame.origin.y + self.loadingImg.image.size.height, 100, 100)];
    [self.spinner setColor:[UIColor whiteColor]];
}

- (void)showLoadingSet {
//    [self.loadingImg setHidden:YES];
    [self.loadingBg setBackgroundColor:[UIColor whiteColor]];
    [self.loadingBg setFrame:CGRectMake(self.fullBg.frame.size.width/2 - 50, self.fullBg.frame.size.height/2 - 50, 100, 100)];
    [self.spinner setColor:[UIColor blackColor]];
}

- (void)stopLoading {
    [UIView animateWithDuration:0.5f animations:^{
        [self setAlpha:0];
    }];
//                     completion:^(BOOL finished) {
//        [self removeFromSuperview];
//    }];
}


@end
