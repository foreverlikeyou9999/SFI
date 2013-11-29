//
//  LoadingView.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 9. 5..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface LoadingView : UIView {

}

@property (nonatomic, strong) UIView *fullBg;
@property (nonatomic, strong) UIView *loadingBg;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIImageView *loadingImg;
@property (nonatomic, strong) UILabel *receivedDataLbl;

- (void)startLoading;
- (void)stopLoading;
- (void)showCntntsSet;
- (void)showLoadingSet;

@end
