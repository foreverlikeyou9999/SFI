//
//  DeviceEnrollViewController.m
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 14..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "DeviceEnrollViewController.h"
//
#import "AppDelegate.h"
//
#import "BrandSelectViewController.h"
//
#import "Defines.h"
//
#import "httpRequest.h"
#import "CommonUtil.h"
#import "NSData+AESAdditions.h"

#define FA_UNAUTHORIZED     100
#define USER_UNAUTHORIZED        200
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

@interface DeviceEnrollViewController ()

@end

@implementation DeviceEnrollViewController
@synthesize userInfo = _userInfo;
@synthesize userType = _userType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.userInfo = [[NSArray alloc] init];
        textFieldArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
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
    
    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 168, loginView.image.size.width, 320)];
    [inputView setBackgroundColor:[UIColor clearColor]];
    [loginView addSubview:inputView];
    
    UIImageView *infoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Login_DeviceText"]];
    [infoView setFrame:CGRectMake(loginView.image.size.width/2 - infoView.image.size.width/2, 30, infoView.image.size.width, infoView.image.size.height)];
    [inputView addSubview:infoView];
    
    UIImageView *textFieldBg;
    UIImageView *icon;
    UITextField *textField;
    for (int i = 0; i < 2; i++) {
        textFieldBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LoginTextBox01"]];
        [textFieldBg setUserInteractionEnabled:YES];
        [textFieldBg setFrame:CGRectMake(56, 122 + (i * 22) + (i * 73), textFieldBg.image.size.width, textFieldBg.image.size.height)];
        [inputView addSubview:textFieldBg];
        
        icon = [[UIImageView alloc] init];
        if (i == 0) {
            [icon setImage:[UIImage imageNamed:@"IM_Login_Icn_Name"]];
        } else {
            [icon setImage:[UIImage imageNamed:@"IM_Login_Icn_Phone"]];
        }
        [icon setFrame:CGRectMake(346, textFieldBg.image.size.height/2 - icon.image.size.height/2, icon.image.size.width, icon.image.size.height)];
        [textFieldBg addSubview:icon];
        
        textField = [[UITextField alloc] init];
        [textField setTag:i];
        [textField setDelegate:self];
        [textField setBackgroundColor:[UIColor clearColor]];
        [textField setTextColor:[UIColor whiteColor]];
        [textField setFrame:CGRectMake(20, 73/2 - 26/2, 326, 26)];
        [textField setFont:[UIFont systemFontOfSize:24.0f]];
        [textField setTextAlignment:NSTextAlignmentLeft];
        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
        if (i == 0) {
            [textField setPlaceholder:@"Name"];
            [textField setReturnKeyType:UIReturnKeyNext];
        } else {
            [textField setPlaceholder:@"Phone"];
            [textField setReturnKeyType:UIReturnKeyDone];
        }
        [textFieldArr addObject:textField];
        [textFieldBg addSubview:textField];
    }
    
    UIButton *btn;
    UILabel *lbl;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setUserInteractionEnabled:YES];
    [btn setImage:[UIImage imageNamed:@"IM_LoginBtn01"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(loginView.image.size.width/2 - btn.imageView.image.size.width/2, 528, btn.imageView.image.size.width, btn.imageView.image.size.height)];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(btn.imageView.image.size.width/2 - 33, 0, 66, btn.imageView.image.size.height)];
    [lbl setUserInteractionEnabled:YES];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setText:@"등록"];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setShadowColor:[UIColor blackColor]];
    [lbl setShadowOffset:CGSizeMake(1, 0)];
    [lbl setFont:[UIFont boldSystemFontOfSize:24.0f]];
    [btn addSubview:lbl];
    
    [btn addTarget:self action:@selector(deviceEnroll) forControlEvents:UIControlEventTouchUpInside];
    [loginView addSubview:btn];
}

- (void)availabilityCheck {
    if ([[((UITextField *)[textFieldArr objectAtIndex:0]) text] length] == 0 || [[((UITextField *)[textFieldArr objectAtIndex:1]) text] length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"KOLON" message:@"입력하신 정보를 확인해 주십시오." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alertView setTag:0];
        [alertView show];
    } else {
        [self deviceEnroll];
    }
}

- (void)deviceEnroll {
//    loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20)];
//    [self.view addSubview:loadingView];
//    [loadingView startLoading];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.loadingView showLoadingSet];
    [app.loadingView startLoading];
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"cnt : %@", [(UITextField *)[textFieldArr objectAtIndex:1] text]);
    
    if ([((UITextField *)[textFieldArr objectAtIndex:1]).text length] > 9 && [((UITextField *)[textFieldArr objectAtIndex:1]).text length] < 12) {
        NSString *telno1 = @"";
        NSString *telno2 = @"";
        NSString *telno3 = @"";
        
        
        if ([((UITextField *)[textFieldArr objectAtIndex:1]).text length] == 10) {
            telno1 = [((UITextField *)[textFieldArr objectAtIndex:1]).text substringWithRange:NSMakeRange(0, 3)];
            telno2 = [((UITextField *)[textFieldArr objectAtIndex:1]).text substringWithRange:NSMakeRange(3, 3)];
            telno3 = [((UITextField *)[textFieldArr objectAtIndex:1]).text substringWithRange:NSMakeRange(6, 4)];
            
        } else if ([((UITextField *)[textFieldArr objectAtIndex:1]).text length] == 11) {
            telno1 = [((UITextField *)[textFieldArr objectAtIndex:1]).text substringWithRange:NSMakeRange(0, 3)];
            telno2 = [((UITextField *)[textFieldArr objectAtIndex:1]).text substringWithRange:NSMakeRange(3, 4)];
            telno3 = [((UITextField *)[textFieldArr objectAtIndex:1]).text substringWithRange:NSMakeRange(7, 4)];
        }
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                         ((UITextField *)[textFieldArr objectAtIndex:0]).text, @"userNm"
                                         , telno1, @"telno1"
                                         , telno2, @"telno2"
                                         , telno3, @"telno3", nil];
        
        NSString *url = [NSString stringWithFormat:@"%@%@?accessToken=%@&timestamp=%0.f"
                         , KHOST
                         , MODIFYFADEVICEINFO
                         , [temp hexadecimalString]
                         , timeInMiliseconds];
        
        httpRequest *_httpRequest = [[httpRequest alloc] init];
        [_httpRequest setDelegate:self selector:@selector(result:)];
        [_httpRequest setJsonBody:[userInfo JSONString]];
        [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"PUT"];
        
    } else {
//        [loadingView stopLoading];
        [app.loadingView stopLoading];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"KOLON" message:@"입력하신 정보를 확인해 주십시오." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alertView setTag:0];
        [alertView show];
    }
}

- (void)doNetworkErrorProcess {
    NSLog(@"device enroll error");
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    [loadingView stopLoading];
    [app.loadingView stopLoading];
}

- (void)result:(NSString *)data {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"device enroll result ; %@", data);
    
    NSError *error = nil;
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            NSString *url = [NSString stringWithFormat:@"%@%@?userId=%@&pwd=%@&accessToken=%@&timestamp=%0.f"
                             , KHOST
                             , GETSHOPLOGININFO
                             , [self.userInfo objectAtIndex:0]
                             , [self.userInfo objectAtIndex:1]
                             , [temp hexadecimalString]
                             , timeInMiliseconds];
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(loginResult:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        } else if ([result isEqualToString:@"401.1"]) {//인증오류
//            [loadingView stopLoading];
            [app.loadingView stopLoading];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalseForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView setTag:USER_UNAUTHORIZED];
            [alertView show];
        } else if ([result isEqualToString:@"401.100"]) {//인증오류_FA
            
        } else if ([result isEqualToString:@"401.101"]) {//단말 미등록
            
        } else if ([result isEqualToString:@"401.102"]) {//단말 미승인
            NSString *url = [NSString stringWithFormat:@"%@%@?userId=%@&pwd=%@&accessToken=%@&timestamp=%0.f"
                             , KHOST
                             , GETSHOPLOGININFO
                             , [self.userInfo objectAtIndex:0]
                             , [self.userInfo objectAtIndex:1]
                             , [temp hexadecimalString]
                             , timeInMiliseconds];
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(loginResult:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
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
        [app.loadingView stopLoading];
//        [loadingView stopLoading];
    }
}

- (void)loginResult:(NSString *)data {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"login reulst : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            for (int i = 0; i < [textFieldArr count]; i++) {
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
            
        } else if ([result isEqualToString:@"401.100"]) {//인증오류_FA
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalseForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView setTag:FA_UNAUTHORIZED];
            [alertView show];
        } else if ([result isEqualToString:@"401.101"]) {//단말 미등록
            
        } else if ([result isEqualToString:@"401.102"]) {//단말 미승인
            [app.loadingView stopLoading];
//            [loadingView stopLoading];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"KOLON" message:[[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"] delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView setTag:1];
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

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (alertView.tag == 0) {
        for (int i = 0; i < [textFieldArr count]; i++) {
            [((UITextField *)[textFieldArr objectAtIndex:i]) setText:@""];
        }
        [((UITextField *)[textFieldArr objectAtIndex:0]) becomeFirstResponder];
        
//        [loadingView stopLoading];
        [app.loadingView stopLoading];
    } else if (alertView.tag == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (alertView.tag == FA_UNAUTHORIZED) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (alertView.tag == USER_UNAUTHORIZED) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Textfield view delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 1) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return (([string isEqualToString:filtered])&&(newLength <= 11));
    } else {
        return YES;
    }
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
