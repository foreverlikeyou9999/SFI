//
//  downloadRequest.m
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 21..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "downloadRequest.h"
//
#import "AppDelegate.h"

@implementation downloadRequest
@synthesize response;
@synthesize target;
@synthesize selector;
@synthesize fileName = _fileName;
@synthesize folderName = _folderName;
@synthesize downloadType = _downloadType;


- (BOOL)requestUrl:(NSString *)url {
    self.fileName = @"";
    //    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    //	NSArray *sepratedStr = [url componentsSeparatedByString:@"?"];
    NSLog(@"imagedownloadreqeust : %@", url);
	
    // URL Request 객체 생성
    //    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[sepratedStr objectAtIndex:0]]
    //   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
    // cachePolicy:NSURLRequestUseProtocolCachePolicy
    //                                                           cachePolicy:NSURLRequestReloadRevalidatingCacheData
    //													   timeoutInterval:90.0f];
    NSMutableURLRequest *request;
    
    // 통신방식 정의 (POST, GET)
    //    [request setHTTPMethod:@"POST"];
    // 	[request setHTTPBody:[[sepratedStr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding] ];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:15.0f];
    [request setHTTPMethod:@"GET"];
    
    // Request를 사용하여 실제 연결을 시도하는 NSURLConnection 인스턴스 생성
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    // 정상적으로 연결이 되었다면
    if(connection)
    {
        // 데이터를 전송받을 멤버 변수 초기화
        receivedData = [[NSMutableData alloc] init];
        return YES;
    }
    return NO;
    //    [pool release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
    // 데이터를 전송받기 전에 호출되는 메서드, 우선 Response의 헤더만을 먼저 받아 온다.
//    NSLog(@"%@", aResponse.URL);
    [receivedData setLength:0];
    self.response = aResponse;
    self.fileName = [aResponse suggestedFilename];
    NSLog(@"%@", self.fileName);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 데이터를 전송받는 도중에 호출되는 메서드, 여러번에 나누어 호출될 수 있으므로 appendData를 사용한다.>)]
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // 에러가 발생되었을 경우 호출되는 메서드
    //	[self downloadError];
    NSLog(@"down error : %@", error);
    [self performSelectorOnMainThread:@selector(log:) withObject:@"Fail!" waitUntilDone:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //NSString *fileInfo= [NSString stringWithFormat:@"Succeeded! Received %d bytes of data",[receivedData length]];
//    [self performSelectorOnMainThread:@selector(log:) withObject:fileInfo waitUntilDone:NO];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    if ([self.downloadType isEqualToString:@"img"]) {
//        NSArray *tempArr = [[NSString stringWithFormat:@"%@", [connection currentRequest].URL] componentsSeparatedByString:@"brandCd="];
        NSString *dirPath = [NSString stringWithFormat:@"%@/salesforce/%@/%@", cachesDirectory, self.folderName, [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/%@/%@", self.folderName, [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"], self.fileName]];
        UIImage *image = [[UIImage alloc] initWithData:receivedData];
        NSData *temp = [NSData dataWithData:UIImagePNGRepresentation(image)];
        
        [temp writeToFile:cachePath atomically:NO];
    } else {
        NSArray *tempArr = [[[[NSString stringWithFormat:@"%@", [connection currentRequest].URL] componentsSeparatedByString:@"?"] objectAtIndex:1] componentsSeparatedByString:@"&"];
        NSString *dirPath = [NSString stringWithFormat:@"%@/%@/%@", cachesDirectory, self.folderName, [[[tempArr objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@/%@", self.folderName, [[[tempArr objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1], self.fileName]];
//        UIImage *image = [[[UIImage alloc] initWithData:receivedData] autorelease];
//        NSData *temp = [NSData dataWithData:UIImagePNGRepresentation(image)];
        NSData *temp = [NSData dataWithData:receivedData];
        
        [temp writeToFile:cachePath atomically:NO];
    }
    
    // release the connection, and the data object
    //    [connection release];
    //    [receivedData release];
    
    if(target)
    {
        [target performSelector:selector withObject:@"success"];
    }
}

- (void)setDelegate:(id)aTarget selector:(SEL)aSelector
{
    // 데이터 수신이 완료된 이후에 호출될 메서드의 정보를 담고 있는 셀렉터 설정
    self.target = aTarget;
    self.selector = aSelector;
}

//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
//    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//
//    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//}

//- (void)downloadError
//{
//	if(target)
//    {
//        [target performSelector:@selector(downloadError) withObject:nil];
//    }
//}

- (void)log:(NSString *)log {
    NSLog(@"log : %@", log);
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *tempArr = [self.fileName componentsSeparatedByString:@"."];
    
    if ([log isEqualToString:@"Fail!"]) {
        
    } else {
        if ([[tempArr objectAtIndex:1] isEqualToString:@"zip"]) {
            NSDictionary *temp = [[NSDictionary alloc] initWithObjectsAndKeys:[[self.response URL] absoluteString], @"response", self.fileName, @"filename", self.folderName, @"foldername", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"zipdownloadsuccess" object:nil userInfo:temp];
        } else {
           [[app appAlertView] dismissWithClickedButtonIndex:0 animated:YES]; 
        }
    }
}

@end