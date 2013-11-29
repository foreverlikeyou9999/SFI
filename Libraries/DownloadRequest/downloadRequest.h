//
//  downloadRequest.h
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 21..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface downloadRequest : NSObject {
    NSMutableData *receivedData;
    NSURLResponse *response;
    
    id __weak target;
    SEL selector;
}

- (BOOL)requestUrl:(NSString *)url;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)setDelegate:(id)aTarget selector:(SEL)aSelector;
//- (void)downloadError;

@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *folderName;
@property (nonatomic, strong) NSString *downloadType;


@end
