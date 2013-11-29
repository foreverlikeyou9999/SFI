//
//  AppDelegate.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 21..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "AppDelegate.h"
//
#import "LoadingViewController.h"
#import "MasterViewController.h"
#import "LoginViewController/LoginViewController.h"
//
#import "httpRequest.h"
//#import "Update.h"
#import "NSData+AESAdditions.h"

#define DEVICE_MODEL_ALERT_TAG  200     //디바이스 지원 모델 여부 팝업

@implementation AppDelegate
@synthesize navigationC = _navigationC;
@synthesize navigationC2 = _navigationC2;
@synthesize appAlertView = _appAlertView;
@synthesize naviBar = _naviBar;
@synthesize pwView = _pwView;
@synthesize loadingView = _loadingView;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[CommonUtil machineName] isEqualToString:@"iPad1,1"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:@"iPad 2세대 이상에서만 사용이 가능합니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alertView setTag:DEVICE_MODEL_ALERT_TAG];
        [alertView show];
    } else {
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      (__bridge id)kCFBooleanTrue, (__bridge id)kSecReturnAttributes,
                                      (__bridge id)kSecMatchLimitAll, (__bridge id)kSecMatchLimit,
                                      nil];
        
        NSArray *secItemClasses = [NSArray arrayWithObjects:
                                   (__bridge id)kSecClassGenericPassword,
                                   nil];
        
        for (id secItemClass in secItemClasses) {
            [query setObject:secItemClass forKey:(__bridge id)kSecClass];
            
            CFTypeRef result = NULL;
            SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
            if (result != NULL) {
                keyChainCheck = YES;
                CFRelease(result);
            } else {
                keyChainCheck = NO;
            }
        }
        
        if (!keyChainCheck) {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.1) {
                NSLog(@"6.1미만");
                CFUUIDRef theUUID = CFUUIDCreate(NULL);
                CFStringRef string = CFUUIDCreateString(NULL, theUUID);
                CFRelease(theUUID);
                
                NSLog(@"uuid : %@", [(__bridge NSString *)(string) stringByReplacingOccurrencesOfString:@"-" withString:@""]);
                
                [CommonUtil createKeychainValue:[NSString stringWithFormat:@"%@", [(__bridge NSString *)(string) stringByReplacingOccurrencesOfString:@"-" withString:@""]] forIdentifier:@"uuid"];
            } else {
                NSLog(@"6.1이상");
                [CommonUtil createKeychainValue:[[NSString stringWithFormat:@"%@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]] stringByReplacingOccurrencesOfString:@"-" withString:@""] forIdentifier:@"uuid"];
            }
        }
        
        LoadingViewController *loadingVC = [[LoadingViewController alloc] init];
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        
        _naviBar = [[NavigationBar alloc] init];
        _pwView = [[PasswordView alloc] init];
        _loadingView = [[LoadingView alloc] init];
        
        self.navigationC = [[UINavigationController alloc] initWithRootViewController:loadingVC];;
        [self.navigationC setNavigationBarHidden:YES];
        
        self.navigationC2 = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.navigationC2 setNavigationBarHidden:YES];
        
        self.window.backgroundColor = [UIColor clearColor];
        [self.window makeKeyAndVisible];
        
        [self.window setRootViewController:self.navigationC];
        
        [self performSelector:@selector(logout:) withObject:@"yes" afterDelay:0.1f];
    }
    return YES;
}

- (void)mainChange {
    loginTimer = [NSTimer scheduledTimerWithTimeInterval:43200.0f target:self selector:@selector(logout:) userInfo:nil repeats:NO];
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&accessToken=%@&timestamp=%0.f"
                     , KHOST
                     , LISTCNTNTSMENU
                     , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                     , [temp hexadecimalString]
                     , timeInMiliseconds];
    
    httpRequest *_httpRequest = [[httpRequest alloc] init];
    [_httpRequest setDelegate:self selector:@selector(result:)];
    [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    
}

- (void)doNetworkErrorProcess {
    NSLog(@"network error");
    
    [self.window setRootViewController:self.navigationC];
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
            
            [[NSUserDefaults standardUserDefaults] setObject:[resultsDictionary objectForKey:@"results"] forKey:@"mainmenulist"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            MasterViewController *masterVC = [[MasterViewController alloc] init];
            self.navigationC = nil;
            self.navigationC = [[UINavigationController alloc] initWithRootViewController:masterVC];
            [self.navigationC setNavigationBarHidden:YES];
            [self.window setRootViewController:nil];
            [self.window setRootViewController:self.navigationC];
        } else if ([result isEqualToString:@"401.1"]) {//인증오류
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.100"]) {//인증오류_FA
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.101"]) {//단말 미등록
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.102"]) {//단말 미승인
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.103"]) {//단말 분실
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDirectory = [paths objectAtIndex:0];
            NSString *dir = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce"]];
            
            NSError *error = nil;
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:dir error:&error];
            
            [self logout:@"yes"];
        } else if ([result isEqualToString:@"401.104"]) {//비밀번호 5회이상 오류
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([result isEqualToString:@"401.105"]) {//요청시간 초과
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:resultMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            
            [alertView show];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalesForce" message:@"통신이 원활하지 않습니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        
        [alertView show];
    }
}

- (void)callAlertView {
    self.appAlertView = [[UIAlertView alloc] initWithTitle:@"KOLON" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] init];
    [loading setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    NSLog(@"%f, %f", self.appAlertView.frame.size.width, self.appAlertView.frame.size.height);
    
    [loading setFrame:CGRectMake(145, 70, loading.bounds.size.width, loading.bounds.size.height)];
    [self.appAlertView addSubview:loading];
    [loading startAnimating];
    
    [self.appAlertView show];
    
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)logout:(NSString *)animation {
    BOOL ani = NO;
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        [self.navigationC presentViewController:self.navigationC2 animated:ani completion:^{
            
        }];
    } else {
        if ([animation isKindOfClass:[NSTimer class]]) {
            animation = @"yes";
        }
        
        if ([animation isEqualToString:@"yes"]) {
            ani = YES;
        }
        
        [self.navigationC presentViewController:self.navigationC2 animated:ani completion:^{
            
        }];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"asdf");
}

#pragma mark - pdf
- (void)setDocument:(CGPDFDocumentRef)document
{
    _pdfDoc = document;
}

- (CGPDFDocumentRef)getDocument
{
    return _pdfDoc;
}

#pragma mark - Life cycle
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [loginTimer invalidate];
    loginTimer = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    int remainedTime = 43200 - [[CommonUtil dateSecReturn:[[NSUserDefaults standardUserDefaults] objectForKey:@"logintime"] withSelect:nil] intValue];
    
    loginTimer = [NSTimer scheduledTimerWithTimeInterval:remainedTime target:self selector:@selector(logout:) userInfo:nil repeats:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag) {
        case DEVICE_MODEL_ALERT_TAG:
            exit(0);
            break;
            
		default:
			break;
	}
}

@end

