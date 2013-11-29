//
//  LoginViewController.m
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 14..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "LoginViewController.h"
//
#import "AppDelegate.h"
//
#import "DeviceEnrollViewController.h"
#import "BrandSelectViewController.h"
//
#import "LoadingView.h"
//
#import "httpRequest.h"
#import "Update.h"
//
#import "NSData+AESAdditions.h"
#import "CommonUtil.h"

#define UPDATE_ALERT_TAG   100     //업데이트 여부 팝업
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

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        textFieldArr = [[NSMutableArray alloc] init];
        loginCheckArr = [[NSMutableArray alloc] init];
        
        userType = [[NSUserDefaults standardUserDefaults] objectForKey:@"userType"];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    UpdateManager *um = [UpdateManager getInstance];
    if([um isNetworkReachable] && [um isUpdateSalesForce]) {
        NSLog(@"업데이트 필요");
        
        UIAlertView *alertUpdate = [[UIAlertView alloc] initWithTitle:@"버전 업데이트"
                                        message:@"새로운 버전이 업데이트 되었습니다.\n업데이트 하시겠습니까?"
                                        delegate:self
                                    cancelButtonTitle:@"취소"
                                    otherButtonTitles:@"업데이트", nil];
        alertUpdate.tag = UPDATE_ALERT_TAG;
        [alertUpdate show];
    }
    
    if (textFieldArr != nil) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"id"]) {
            [((UITextField *)[textFieldArr objectAtIndex:0]) setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
            [((UITextField *)[textFieldArr objectAtIndex:1]) setText:@""];
        }
    }
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    BOOL loadingViewCheck = NO;
    for (UIView *view in self.view.subviews) {
        if (view == app.loadingView) {
            loadingViewCheck = YES;
        }
    }
    
    if (!loadingViewCheck) {
        [self.view addSubview:app.loadingView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.    
    UIImageView *baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_CommonBG_01.jpg"]];
    [baseView setUserInteractionEnabled:YES];
    [baseView setFrame:CGRectMake(0, HEIGHT, baseView.image.size.width, baseView.image.size.height)];
    [self.view addSubview:baseView];
    
    UIImageView *loginView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LoginBG"]];
    [loginView setUserInteractionEnabled:YES];
    [loginView setFrame:CGRectMake(125, 156, loginView.image.size.width, loginView.image.size.height)];
    [baseView addSubview:loginView];
    
    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 153, loginView.image.size.width, 320)];//168
    [inputView setBackgroundColor:[UIColor clearColor]];
    [loginView addSubview:inputView];
    
    UIImageView *switchBase = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LoginSlide01"]];
    [switchBase setUserInteractionEnabled:YES];
    [switchBase setFrame:CGRectMake(loginView.image.size.width/2 - switchBase.image.size.width/2, 42, switchBase.image.size.width, switchBase.image.size.height)];
    [inputView addSubview:switchBase];
    
    switchBtn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LoginSlide02"]];
    [switchBtn setUserInteractionEnabled:YES];
    [switchBtn setFrame:CGRectMake(0, switchBase.image.size.height/2 - switchBtn.image.size.height/2 + 3, switchBtn.image.size.width, switchBtn.image.size.height)];
    [switchBase addSubview:switchBtn];
    
    UISwipeGestureRecognizer *swipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchBtn:)];
    [swipeR setDelegate:self];
    swipeR.direction = UISwipeGestureRecognizerDirectionRight;
    [switchBase addGestureRecognizer:swipeR];
    
    UISwipeGestureRecognizer *swipeL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchBtn:)];
    [swipeL setDelegate:self];
    swipeL.direction = UISwipeGestureRecognizerDirectionLeft;
    [switchBase addGestureRecognizer:swipeL];
    
    UIImageView *loginCheck;
    UILabel *lbl;
    for (int i = 0; i < 2; i++) {
        loginCheck = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LoginCheck_N"] highlightedImage:[UIImage imageNamed:@"IM_LoginCheck_O"]];
        [loginCheck setUserInteractionEnabled:YES];
        [loginCheck setTag:i];
        if (i == 0) {
            [loginCheck setFrame:CGRectMake(66, 50, loginCheck.image.size.width, loginCheck.image.size.height)];
            [loginCheck setHighlighted:YES];
        } else {
            [loginCheck setFrame:CGRectMake(424, 50, loginCheck.image.size.width, loginCheck.image.size.height)];
            [loginCheck setHighlighted:NO];
        }
        [loginCheckArr addObject:loginCheck];
        [inputView addSubview:loginCheck];
        
        lbl = [[UILabel alloc] init];
        [lbl setUserInteractionEnabled:YES];
        if (i == 0) {
            [lbl setFrame:CGRectMake(95, 50, 56, 28)];
            [lbl setText:@"본사"];
        } else {
            [lbl setFrame:CGRectMake(368, 50, 56, 28)];
            [lbl setText:@"매장"];
        }
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setFont:[UIFont systemFontOfSize:24.0f]];
        [lbl setTextColor:[UIColor whiteColor]];
        [lbl setShadowColor:[UIColor blackColor]];
        [lbl setShadowOffset:CGSizeMake(1, 0)];
        [inputView addSubview:lbl];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchBtn:)];
        [loginCheck addGestureRecognizer:tap];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchBtn:)];
        [lbl addGestureRecognizer:tap2];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchBtn:)];
    [switchBase addGestureRecognizer:tap];
    
    UIImageView *textFieldBg;
    UIImageView *icon;
    UITextField *textField;
    for (int i = 0; i < 2; i++) {
        textFieldBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LoginTextBox01"]];
        [textFieldBg setUserInteractionEnabled:YES];
        [textFieldBg setFrame:CGRectMake(56, 111 + (i * 22) + (i * 73), textFieldBg.image.size.width, textFieldBg.image.size.height)];//122
        [inputView addSubview:textFieldBg];
        
        icon = [[UIImageView alloc] init];
        if (i == 0) {
            [icon setImage:[UIImage imageNamed:@"IM_Login_Icn_ID"]];
        } else {
            [icon setImage:[UIImage imageNamed:@"IM_Login_Icn_PW"]];
        }
        [icon setFrame:CGRectMake(346, textFieldBg.image.size.height/2 - icon.image.size.height/2, icon.image.size.width, icon.image.size.height)];
        [textFieldBg addSubview:icon];
        
        textField = [[UITextField alloc] init];
        [textField setDelegate:self];
        [textField setTag:i];
        [textField setBackgroundColor:[UIColor clearColor]];
        [textField setTextColor:[UIColor whiteColor]];
        [textField setFrame:CGRectMake(20, 0, 326, textFieldBg.frame.size.height)];
        [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [textField setFont:[UIFont systemFontOfSize:24.0f]];
        [textField setTextAlignment:NSTextAlignmentLeft];
        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
        if (i == 0) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"id"]) {
                [textField setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
            }
            [textField setPlaceholder:@"ID"];
            [textField setReturnKeyType:UIReturnKeyNext];
        } else {
            [textField setPlaceholder:@"Password"];
            [textField setSecureTextEntry:YES];
            [textField setReturnKeyType:UIReturnKeyDone];
        }
        [textField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
        [textFieldArr addObject:textField];
        [textFieldBg addSubview:textField];
    }
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(88, inputView.frame.size.height - 31, 86, 31)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setText:@"아이디 저장"];
    [lbl setFont:[UIFont systemFontOfSize:18.0f]];
    [lbl setTextColor:[UIColor whiteColor]];
    [inputView addSubview:lbl];
    
    idSaveChkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [idSaveChkBtn setImage:[UIImage imageNamed:@"check_N"] forState:UIControlStateNormal];
    [idSaveChkBtn setImage:[UIImage imageNamed:@"check_O"] forState:UIControlStateSelected];
    [idSaveChkBtn setFrame:CGRectMake(54, inputView.frame.size.height - idSaveChkBtn.imageView.image.size.height, idSaveChkBtn.imageView.image.size.width, idSaveChkBtn.imageView.image.size.height)];
    [idSaveChkBtn addTarget:self action:@selector(saveIdChk:) forControlEvents:UIControlEventTouchUpInside];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"id"]) {
        [idSaveChkBtn setSelected:YES];
    }
    [inputView addSubview:idSaveChkBtn];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setUserInteractionEnabled:YES];
    [btn setBackgroundImage:[UIImage imageNamed:@"IM_LoginBtn01"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(loginView.image.size.width/2 - [UIImage imageNamed:@"IM_LoginBtn01"].size.width/2, 528, [UIImage imageNamed:@"IM_LoginBtn01"].size.width, [UIImage imageNamed:@"IM_LoginBtn01"].size.height)];
    [btn setTitle:@"로그인" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:24.0f]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(availabilityCheck) forControlEvents:UIControlEventTouchUpInside];
    [loginView addSubview:btn];
    
    if ([userType isEqualToString:@"매장"]) {
        [self switchBtn:nil];
    }
}

- (void)saveIdChk:(id)sender {
    ((UIButton *)sender).selected = !((UIButton *)sender).selected;
    
    if (((UIButton *)sender).selected == YES) {
        [[NSUserDefaults standardUserDefaults] setObject:((UITextField *)[textFieldArr objectAtIndex:0]).text forKey:@"id"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"id"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)availabilityCheck {
    if ([[((UITextField *)[textFieldArr objectAtIndex:0]) text] length] == 0 || [[((UITextField *)[textFieldArr objectAtIndex:1]) text] length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"KOLON" message:@"아이디와 비밀번호를 확인해 주세요." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        [self loginTry];
    }
}

- (void)loginTry {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView showLoadingSet];
    [app.loadingView startLoading];
    
    if (idSaveChkBtn.selected == YES) {
        [[NSUserDefaults standardUserDefaults] setObject:((UITextField *)[textFieldArr objectAtIndex:0]).text forKey:@"id"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"id"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
//    loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20)];
//    [self.view addSubview:loadingView];
//    [loadingView startLoading];
    
    for (UITextField *textField in textFieldArr) {
        [textField resignFirstResponder];
    }
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (switchBtn.frame.origin.x == 0) {
        NSString *url = [NSString stringWithFormat:@"%@%@?userId=%@&pwd=%@&accessToken=%@&timestamp=%0.f"
                         , KHOST
                         , GETHEDOFCLOGININFO
                         , ((UITextField *)[textFieldArr objectAtIndex:0]).text
                         , ((UITextField *)[textFieldArr objectAtIndex:1]).text
                         , [temp hexadecimalString]
                         , timeInMiliseconds];
        
        httpRequest *_httpRequest = [[httpRequest alloc] init];
        [_httpRequest setDelegate:self selector:@selector(result:)];
        [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    } else {
        NSString *url = [NSString stringWithFormat:@"%@%@?userId=%@&pwd=%@&accessToken=%@&timestamp=%0.f"
                         , KHOST
                         , GETSHOPLOGININFO
                         , [((UITextField *)[textFieldArr objectAtIndex:0]).text uppercaseString]
                         , ((UITextField *)[textFieldArr objectAtIndex:1]).text
                         , [temp hexadecimalString]
                         , timeInMiliseconds];
        
        httpRequest *_httpRequest = [[httpRequest alloc] init];
        [_httpRequest setDelegate:self selector:@selector(result:)];
        [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    }
}



- (void)switchBtn:(id)sender {
    if (((UITextField *)[textFieldArr objectAtIndex:0]).text != nil) {
        [((UITextField *)[textFieldArr objectAtIndex:0]) setText:@""];
        [((UITextField *)[textFieldArr objectAtIndex:1]) setText:@""];
        if (idSaveChkBtn.selected) {
            [self saveIdChk:idSaveChkBtn];
        }
    }
    
    if ([sender isKindOfClass:[UISwipeGestureRecognizer class]]) {
        NSLog(@"swipe");
        if (((UISwipeGestureRecognizer *)sender).direction == UISwipeGestureRecognizerDirectionRight) {
            NSLog(@"right");
            [[NSUserDefaults standardUserDefaults] setObject:@"매장" forKey:@"userType"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [((UIImageView *)[loginCheckArr objectAtIndex:0]) setHighlighted:NO];
            [((UIImageView *)[loginCheckArr objectAtIndex:1]) setHighlighted:YES];
            
            [UIView animateWithDuration:0.2f animations:^{
                [switchBtn setFrame:CGRectMake(136 - switchBtn.image.size.width, 46/2 - switchBtn.image.size.height/2 + 3, switchBtn.image.size.width, switchBtn.image.size.height)];
            }];
        } else {
            NSLog(@"left");
            [[NSUserDefaults standardUserDefaults] setObject:@"본사" forKey:@"userType"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [((UIImageView *)[loginCheckArr objectAtIndex:0]) setHighlighted:YES];
            [((UIImageView *)[loginCheckArr objectAtIndex:1]) setHighlighted:NO];
            
            [UIView animateWithDuration:0.2f animations:^{
                [switchBtn setFrame:CGRectMake(0, 46/2 - switchBtn.image.size.height/2 + 3, switchBtn.image.size.width, switchBtn.image.size.height)];
            }];
        }
    } else {
        if (switchBtn.frame.origin.x == 0) {//본사 -> 매장
            [[NSUserDefaults standardUserDefaults] setObject:@"매장" forKey:@"userType"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [((UIImageView *)[loginCheckArr objectAtIndex:0]) setHighlighted:NO];
            [((UIImageView *)[loginCheckArr objectAtIndex:1]) setHighlighted:YES];
            
            [UIView animateWithDuration:0.2f animations:^{
                [switchBtn setFrame:CGRectMake(136 - switchBtn.image.size.width, 46/2 - switchBtn.image.size.height/2 + 3, switchBtn.image.size.width, switchBtn.image.size.height)];
            }];
        } else {//매장 -> 본사
            [[NSUserDefaults standardUserDefaults] setObject:@"본사" forKey:@"userType"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [((UIImageView *)[loginCheckArr objectAtIndex:0]) setHighlighted:YES];
            [((UIImageView *)[loginCheckArr objectAtIndex:1]) setHighlighted:NO];
            
            [UIView animateWithDuration:0.2f animations:^{
                [switchBtn setFrame:CGRectMake(0, 46/2 - switchBtn.image.size.height/2 + 3, switchBtn.image.size.width, switchBtn.image.size.height)];
            }];
        }
    }
}

- (void)doNetworkErrorProcess {
    NSLog(@"login error");
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    [loadingView stopLoading];
    [app.loadingView stopLoading];
}

- (void)result:(NSString *)data {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"login reulst : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        
//        [loadingView stopLoading];
        [app.loadingView stopLoading];
        
        if ([result isEqualToString:@"200"]) {
            [[GlobalValue sharedSingleton] setPw:((UITextField *)[textFieldArr objectAtIndex:1]).text];
            
            for (int i = 0; i < [loginCheckArr count]; i++) {
                [((UITextField *)[textFieldArr objectAtIndex:i]) setText:@""];
                [((UITextField *)[textFieldArr objectAtIndex:i]) resignFirstResponder];
            }
            
            NSArray *brandsList = [[resultsDictionary objectForKey:@"result"] objectForKey:@"brands"];
            
            if ([brandsList count] == 1) {
                NSString *brandCd =  [[brandsList objectAtIndex:0] objectForKey:@"brandCd"];
                NSString *shopCd =  [[brandsList objectAtIndex:0] objectForKey:@"shopCd"];
                //                brand가 추가되면 사용
                //                NSString *brandNm =  [[brandsList objectAtIndex:0] objectForKey:@"brandNm"];
                
                [[NSUserDefaults standardUserDefaults] setObject:brandCd forKey:@"brandcd"];
                [[NSUserDefaults standardUserDefaults] setObject:shopCd forKey:@"shopCd"];
                [[NSUserDefaults standardUserDefaults] setObject:brandsList forKey:@"brandList"];
                //                brand가 추가되면 사용
                //                [[NSUserDefaults standardUserDefaults] setObject:brandNm forKey:@"brandNm"];
                [[NSUserDefaults standardUserDefaults] setObject:@"KOLON SPORT" forKey:@"brandNm"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [app mainChange];
                
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    [self.navigationController popToRootViewControllerAnimated:NO];
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"logintime"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }];
            } else {
                BrandSelectViewController *nextView = [[BrandSelectViewController alloc] init];
                [nextView setBrandListArr:[[resultsDictionary objectForKey:@"result"] objectForKey:@"brands"]];
                [self.navigationController pushViewController:nextView animated:YES];
            }
        } else if ([result isEqualToString:@"401.1"]) {//인증오류
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:@"아이디와 비밀번호를 확인해 주세요." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.100"]) {//인증오류_FA
            [[GlobalValue sharedSingleton] setPw:((UITextField *)[textFieldArr objectAtIndex:1]).text];
            
            DeviceEnrollViewController *nextView = [[DeviceEnrollViewController alloc] init];
            [nextView setUserInfo:[NSArray arrayWithObjects:((UITextField *)[textFieldArr objectAtIndex:0]).text, ((UITextField *)[textFieldArr objectAtIndex:1]).text, nil]];
            [self.navigationController pushViewController:nextView animated:YES];
        } else if ([result isEqualToString:@"401.101"]) {//단말 미등록
            NSMutableDictionary *userid = [[NSMutableDictionary alloc] initWithObjectsAndKeys:((UITextField *)[textFieldArr objectAtIndex:0]).text, @"userId", nil];
            [[GlobalValue sharedSingleton] setPw:((UITextField *)[textFieldArr objectAtIndex:1]).text];
            
            if (switchBtn.frame.origin.x == 0) {
                NSString *url = [NSString stringWithFormat:@"%@%@?accessToken=%@&timestamp=%0.f"
                                 , KHOST
                                 , ADDHEDOFCDEVICEINFO
                                 , [temp hexadecimalString]
                                 , timeInMiliseconds];
                
                httpRequest *_httpRequest = [[httpRequest alloc] init];
                [_httpRequest setDelegate:self selector:@selector(deviceRegiResult:)];
                [_httpRequest setJsonBody:[userid JSONString]];
                [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"POST"];
            } else {
                NSString *url = [NSString stringWithFormat:@"%@%@?accessToken=%@&timestamp=%0.f"
                                 , KHOST
                                 , ADDSHOPDEVICEINFO
                                 , [temp hexadecimalString]
                                 , timeInMiliseconds];
                
                httpRequest *_httpRequest = [[httpRequest alloc] init];
                [_httpRequest setDelegate:self selector:@selector(deviceRegiResult:)];
                [_httpRequest setJsonBody:[userid JSONString]];
                [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"POST"];
            }
        } else if ([result isEqualToString:@"401.102"]) {//단말 미승인
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"KOLON" message:[[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"] delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.103"]) {//단말 분실
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDirectory = [paths objectAtIndex:0];
            NSString *dir = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce"]];
            
            NSError *error = nil;
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:dir error:&error];
            
//            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app logout:@"yes"];
        } else if ([result isEqualToString:@"401.104"]) {//비밀번호 5회이상 오류
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:[[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"] delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.105"]) {//요청시간 초과
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:[[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"] delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else {//서버 error
//            [loadingView stopLoading];
            [app.loadingView stopLoading];
        }
    } else {
//        [loadingView stopLoading];
        [app.loadingView stopLoading];
    }
}

- (void)deviceRegiResult:(NSString *)data {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"device Regi Result : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        
        if ([result isEqualToString:@"200"]) {
            [[GlobalValue sharedSingleton] setPw:((UITextField *)[textFieldArr objectAtIndex:1]).text];
            
            if (switchBtn.frame.origin.x == 0) {//본사
                NSString *url = [NSString stringWithFormat:@"%@%@?userId=%@&pwd=%@&accessToken=%@&timestamp=%0.f"
                                 , KHOST
                                 , GETHEDOFCLOGININFO
                                 , ((UITextField *)[textFieldArr objectAtIndex:0]).text
                                 , ((UITextField *)[textFieldArr objectAtIndex:1]).text
                                 , [temp hexadecimalString]
                                 , timeInMiliseconds];
                
                httpRequest *_httpRequest = [[httpRequest alloc] init];
                [_httpRequest setDelegate:self selector:@selector(result:)];
                [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
            } else {//매장
                NSString *url = [NSString stringWithFormat:@"%@%@?userId=%@&pwd=%@&accessToken=%@&timestamp=%0.f"
                                 , KHOST
                                 , GETSHOPLOGININFO
                                 , ((UITextField *)[textFieldArr objectAtIndex:0]).text
                                 , ((UITextField *)[textFieldArr objectAtIndex:1]).text
                                 , [temp hexadecimalString]
                                 , timeInMiliseconds];
                
                httpRequest *_httpRequest = [[httpRequest alloc] init];
                [_httpRequest setDelegate:self selector:@selector(result:)];
                [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
            }
        } else if ([result isEqualToString:@"401.1"]) {//인증오류
            
        } else if ([result isEqualToString:@"401.100"]) {//인증오류_FA
            [[GlobalValue sharedSingleton] setPw:((UITextField *)[textFieldArr objectAtIndex:1]).text];
            
            DeviceEnrollViewController *nextView = [[DeviceEnrollViewController alloc] init];
            [nextView setUserInfo:[NSArray arrayWithObjects:((UITextField *)[textFieldArr objectAtIndex:0]).text, ((UITextField *)[textFieldArr objectAtIndex:1]).text, nil]];
            [self.navigationController pushViewController:nextView animated:YES];
        } else if ([result isEqualToString:@"401.101"]) {//단말 미등록
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:[[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"] delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.102"]) {//단말 미승인
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:[[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"] delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.103"]) {//단말 분실
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDirectory = [paths objectAtIndex:0];
            NSString *dir = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce"]];
            
            NSError *error = nil;
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:dir error:&error];

            [app logout:@"yes"];
        } else if ([result isEqualToString:@"401.104"]) {//비밀번호 5회이상 오류
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:[[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"] delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.105"]) {//요청시간 초과
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:[[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"] delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else {//서버 error
//            [loadingView stopLoading];
            [app.loadingView stopLoading];
        }
    } else {
//        [loadingView stopLoading];
        [app.loadingView stopLoading];
    }
}

#pragma mark - Textfield view delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userType"] isEqualToString:@"매장"]) {
        if (textField.tag == 0) {
            [textField setText:[textField.text uppercaseString]];
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        [(UITextField *)[textFieldArr objectAtIndex:1] becomeFirstResponder];
    } else {
        for (UITextField *textField in textFieldArr) {
            [textField resignFirstResponder];
        }
        [self availabilityCheck];
    }
    return YES;
}

#pragma mark - UIAlert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == UPDATE_ALERT_TAG) {
        if (buttonIndex != 0) {
            //설치 웹사이트 이동
            UpdateManager *um = [UpdateManager getInstance];
            [um goUpdateWebSite];
            
            // 업데이트선택 후 취소하는경우로 인해 앱 종료
            exit(0);
        }
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
