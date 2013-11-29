
#import "httpRequest.h"

@implementation httpRequest

@synthesize response;
@synthesize target;
@synthesize selector;
@synthesize jsonBody = _jsonBody;

- (BOOL)requestUrl:(NSString *)url withRequestType:(NSString *)requestType {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestCancel) name:@"requestcancel" object:nil];
    
//    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//	NSArray* sepratedStr;
//	sepratedStr = [url componentsSeparatedByString:@"?"];
    NSLog(@"httpRequest : %@", url);
	
    // URL Request 객체 생성
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[sepratedStr objectAtIndex:0]]
//                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                            cachePolicy:NSURLRequestReloadRevalidatingCacheData
//                                                            timeoutInterval:15.0f];
    NSMutableURLRequest *request;
    
    // 통신방식 정의 (POST, GET)
    if ([requestType isEqualToString:@"POST"]) {
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10.0f];
        [request setHTTPMethod:requestType];
        [request setHTTPBody:[self.jsonBody dataUsingEncoding:NSUTF8StringEncoding]];
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    } else if ([requestType isEqualToString:@"GET"]) {
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10.0f];
        [request setHTTPMethod:requestType];
    } else {
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10.0f];
        [request setHTTPMethod:requestType];
        [request setHTTPBody:[self.jsonBody dataUsingEncoding:NSUTF8StringEncoding]];
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    }
    
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
    [receivedData setLength:0];
    self.response = aResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 데이터를 전송받는 도중에 호출되는 메서드, 여러번에 나누어 호출될 수 있으므로 appendData를 사용한다.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // 에러가 발생되었을 경우 호출되는 메서드
    NSLog(@"error : %@", error);
	[self doNetworkErrorProcess];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 데이터 전송이 끝났을 때 호출되는 메서드, 전송받은 데이터를 NSString형태로 변환한다.
  NSString*  result = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
   
    // 델리게이트가 설정되어있다면 실행한다.
    if(target != nil)
    {
//        if (selector != nil) {
//            if ([target respondsToSelector:selector]) {
                [target performSelector:selector withObject:result];
//            }
//        }
    }
}

- (void)setDelegate:(id)aTarget selector:(SEL)aSelector
{
    // 데이터 수신이 완료된 이후에 호출될 메서드의 정보를 담고 있는 셀렉터 설정
    self.target = aTarget;
    self.selector = aSelector;
}

- (void)doNetworkErrorProcess
{
	if(target)
    {
        if ([target respondsToSelector:@selector(doNetworkErrorProcess)]) {
            [target performSelector:@selector(doNetworkErrorProcess) withObject:nil];
        }
    }
}

- (void)requestCancel {
    self.target = nil;
    self.selector = nil;
}


@end