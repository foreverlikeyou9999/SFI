//
//  MyClass.m
//  mPlusSign
//
//  Created by 정후 조 on 11. 5. 24..
//  modified by yuil jung 13. 6. 14..
//  Copyright 2011 코롱베니트. All rights reserved.
//

#import "Update.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

#define KOLON_APPS_URL    @"http://m.kolon.com/"

#define NET_VERSION_URL   @"http://m.kolon.com:8080/business/app/servAppVer.do?appNm=mSalesForceE"
#define NET_DOWNLOAD_URL  @"http://m.kolon.com:8080/business/app/servAppUrl.do?appNm=mSalesForceE"

#define KOLON_HOTLINE_SCHEME @"Hotline://"

@implementation UpdateManager


+ (UpdateManager *) getInstance
{
	static UpdateManager * instance;
	
	if (instance == nil) {
		instance = [[UpdateManager alloc] init];
	}
	
	return instance;
}


- (id) init
{
	self = [super init];
	if (self != nil) {
        
	}
	return self;
}

-(BOOL) isNetworkReachable
{
	struct sockaddr_in zeroAddr;
	bzero(&zeroAddr, sizeof(zeroAddr));
	zeroAddr.sin_len = sizeof(zeroAddr);
	zeroAddr.sin_family = AF_INET;
	
	SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddr);
	
	SCNetworkReachabilityFlags flag;
	SCNetworkReachabilityGetFlags(target, &flag);
	
    if(flag & kSCNetworkFlagsReachable)
	{
		return YES;
	}
	else 
	{
		return NO;
	}
}

//버전 체크
//실행중인 바이너리 버전
- (NSString*)getBundleVersion
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSLog(@"getBundleVersion = [%@]", version);
    return version;
}

//m.kolon.com에 업로드된 바이너리 버전
- (NSString*)getNetVersion
{
    NSURL * url = [NSURL URLWithString:NET_VERSION_URL];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    NSURLResponse * response;
    NSError * error;
    NSData * recvData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    NSString * strBundleVer = nil;
    if(!recvData)
    {
        NSString *errorIdentifier = [NSString stringWithFormat:@"(%@)[%d]",error.domain,error.code];
        NSLog(@"Request Error=(%@)", errorIdentifier);
    }
    else
    {
        strBundleVer = [[NSString alloc] initWithData:recvData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", strBundleVer);
    }
    
    return strBundleVer;     
}

- (BOOL)isUpdateSalesForce
{
    BOOL bUpdate = NO;
    //    float fbundleVer = [[self getBundleVersion] floatValue];
    //    float fnetVer    = [[self getNetVersion] floatValue];
    
    NSString *netVersion = [self getNetVersion];
    if (netVersion) {
        float fbundleVer = [[[self getBundleVersion] stringByReplacingOccurrencesOfString:@"." withString:@""] floatValue];
        float fnetVer    = [[netVersion stringByReplacingOccurrencesOfString:@"." withString:@""] floatValue];
        
        if (fbundleVer != fnetVer) {
            bUpdate = YES;
        }
        NSLog(@"bundle(%f) net(%f) update(%d)", fbundleVer, fnetVer, bUpdate);
    }

    return bUpdate;
}


- (void)goUpdateWebSite
{
    //1. Request Download URL!!
    NSURL * url = [NSURL URLWithString:NET_DOWNLOAD_URL];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    NSURLResponse * response;
    NSError * error;
    NSData * recvData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error]; 
    if(!recvData)
    {
        NSString *errorIdentifier = [NSString stringWithFormat:@"(%@)[%d]",error.domain,error.code];
        NSLog(@"Request Error=(%@)", errorIdentifier);
    }
    NSString * recvUrl = [[NSString alloc] initWithData:recvData encoding:NSUTF8StringEncoding];
    //@"itms-services://?action=download-manifest&url=http://m.kolon.com/smartdown/ikenuc.plist";
    NSLog(@"%@", recvUrl);
    
    // 사파리 호출
    NSURL *updateUrl = [NSURL URLWithString:recvUrl];
	
    if ([[UIApplication sharedApplication] canOpenURL:updateUrl]) 
    {
		[[UIApplication sharedApplication] openURL:updateUrl];
    }
}

- (BOOL)isInstallKolonApps
{
    NSString *appUrlScheme = KOLON_HOTLINE_SCHEME;                   //url scheme 값을 주소형식으로 입력
    BOOL isInstall = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appUrlScheme]];
    NSLog(@"isInstallKolonApps = (%d)", isInstall);
    return isInstall;
}

- (void)runKolonApps
{
    NSString *appUrlScheme = KOLON_HOTLINE_SCHEME;                   //url scheme 값을 주소형식으로 입력
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appUrlScheme]]; 
}


@end
