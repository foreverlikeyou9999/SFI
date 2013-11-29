
#import <Foundation/Foundation.h>

@interface httpRequest : NSObject
{
    NSMutableData *receivedData;
    NSURLResponse *response;
 
    id __weak target;
    SEL selector;
}

- (BOOL)requestUrl:(NSString *)url withRequestType:(NSString *)requestType;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)setDelegate:(id)aTarget selector:(SEL)aSelector;
- (void)doNetworkErrorProcess;
- (void)requestCancel;

@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) NSString *jsonBody;

@end