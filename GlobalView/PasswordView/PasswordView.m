//
//  PasswordView.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 8..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "PasswordView.h"

@implementation PasswordView
@synthesize delegate;

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self) {
        UIView *pwBg = [[UIView alloc] initWithFrame:self.frame];
        [pwBg setBackgroundColor:[UIColor blackColor]];
        [pwBg setAlpha:0.5f];
        [self addSubview:pwBg];
        
        [self createComponents];
    }
    return self;
}

- (void)createComponents {
    UIImageView *pwImgBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Popup_PW_BG"]];
    [pwImgBg setUserInteractionEnabled:YES];
    [pwImgBg setFrame:CGRectMake(self.frame.size.width/2 - pwImgBg.image.size.width/2, self.frame.size.height/2 - pwImgBg.image.size.height/2, pwImgBg.image.size.width, pwImgBg.image.size.height)];
    [self addSubview:pwImgBg];
    
    UILabel *lbl;
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 418, 36)];
    [lbl setText:@"비밀번호 확인"];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [pwImgBg addSubview:lbl];
    
    UIButton *btn;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTag:0];
    [btn setImage:[UIImage imageNamed:@"IM_LP_Btn_Close_N"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(pwImgBg.image.size.width - btn.imageView.image.size.width, 0, btn.imageView.image.size.width, btn.imageView.image.size.height)];
    [btn addTarget:delegate action:@selector(pwCheckClose) forControlEvents:UIControlEventTouchUpInside];
    [pwImgBg addSubview:btn];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Popup_PW_ICN"]];
    [icon setFrame:CGRectMake(18, 76, icon.image.size.width, icon.image.size.height)];
    [pwImgBg addSubview:icon];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(67, 76, 320, 36)];
    [lbl setText:@"해당 메뉴 사용을 위해 비밀번호를 입력해주세요."];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setFont:[UIFont systemFontOfSize:15.0f]];
    [pwImgBg addSubview:lbl];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(67, 144, 88, 29)];
    [lbl setText:@"비밀번호 입력"];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setFont:[UIFont systemFontOfSize:15.0f]];
    [pwImgBg addSubview:lbl];
    
    UIImageView *textBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Popup_PW_TextBox"]];
    [textBox setFrame:CGRectMake(168, 144, textBox.image.size.width, textBox.image.size.height)];
    [pwImgBg addSubview:textBox];
    
    pwInput = [[UITextField alloc] initWithFrame:textBox.frame];
    [pwInput setDelegate:self];
    [pwInput setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [pwInput setBackgroundColor:[UIColor clearColor]];
    [pwInput setSecureTextEntry:YES];
    [pwInput setTextAlignment:NSTextAlignmentCenter];
    [pwInput setPlaceholder:@"비밀번호"];
    [pwInput setFont:[UIFont systemFontOfSize:15.0f]];
    [pwInput setTextColor:[UIColor whiteColor]];
    [pwInput setAutocorrectionType:UITextAutocorrectionTypeNo];
    [pwInput setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [pwImgBg addSubview:pwInput];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTag:1];
    [btn setBackgroundImage:[UIImage imageNamed:@"IM_Popup_BTN_BG01"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(139, 288, [UIImage imageNamed:@"IM_Popup_BTN_BG01"].size.width, [UIImage imageNamed:@"IM_Popup_BTN_BG01"].size.height)];
    [btn setTitle:@"확인" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [btn addTarget:self action:@selector(pwCheck:) forControlEvents:UIControlEventTouchUpInside];
    [pwImgBg addSubview:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTag:1];
    [btn setBackgroundImage:[UIImage imageNamed:@"IM_Popup_BTN_BG02"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(235, 288, [UIImage imageNamed:@"IM_Popup_BTN_BG02"].size.width, [UIImage imageNamed:@"IM_Popup_BTN_BG02"].size.height)];
    [btn setTitle:@"취소" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [btn addTarget:delegate action:@selector(pwCheckClose) forControlEvents:UIControlEventTouchUpInside];
    [pwImgBg addSubview:btn];
}

- (void)pwCheck:(id)sender {
    if ([pwInput.text isEqualToString:[[GlobalValue sharedSingleton] pw]]) {
        [pwInput setText:@""];
        [pwInput resignFirstResponder];
        
        [delegate pwCheckClose:NO];
        [delegate pwCheckResult:YES];
    } else {
        [pwInput setText:@""];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalseForce" message:@"비밀번호를 확인해주세요." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)pwCheckClose {
    [delegate pwCheckClose:YES];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text isEqualToString:[[GlobalValue sharedSingleton] pw]]) {
        [pwInput setText:@""];
        
        [textField resignFirstResponder];
        
        [delegate pwCheckClose:NO];
        [delegate pwCheckResult:YES];
        return YES;
    } else {
        [pwInput setText:@""];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalseForce" message:@"비밀번호를 확인해주세요." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alertView show];
        
        [delegate pwCheckResult:NO];
        return NO;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
