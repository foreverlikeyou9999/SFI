//
//  ContentManager.m
//  kNewsletter
//
//  Created by 정후 조 on 11. 11. 1..
//  Copyright 2011 코롱베니트. All rights reserved.
//
#import "ContentManager.h"
#import "AppDelegate.h"

#import "Define.h"

#define DOWN_ALERT_TAG          100     //다운로드 여부 팝업
#define FILEOPEN_ALERT_TAG      101     //다운로드 완료후 파일열기 여부 팝업
#define DOWNFAIL_ALERT_TAG      102     //다운로드 실패 팝업

@implementation ContentManager

@synthesize connection;
@synthesize dataPDF;
@synthesize progressView ;
@synthesize progressAlert ;
@synthesize numberFileSize;

@synthesize fileName ;
@synthesize fileURL;
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) 
    {
        
    }
    return self;
}



#pragma mark - private method

-(NSData*)DownloadServerFile:(NSString*)strURL
{
    if (strURL == nil) {
        return nil;
    }
    self.fileURL = strURL;
    self.fileName = [[fileURL componentsSeparatedByString:@"/"] lastObject];;
    
    NSURL * url = [NSURL URLWithString:fileURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [connection start];  // connection을 만드셨으면 업로드 시작
    
    //프로그레스바 생성 및 화면에 보여줌
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"다운로드 받는 중"
                                                        message:@".............\n   "
                                                       delegate:self cancelButtonTitle:@"취소"
                                              otherButtonTitles:nil];
    self.progressAlert = alertView;
    self.progressAlert.tag = DOWN_ALERT_TAG;
    UIProgressView *progView = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 70.0f, 225.0f, 90.0f)];
    self.progressView = progView;
    [self.progressAlert addSubview:self.progressView];
    [self.progressView setProgressViewStyle:UIProgressViewStyleDefault];//UIProgressViewStyleBar];
    [self.progressAlert show];
    
    return nil;
}
// NOT_USED
//-(NSData*)DownloadServerFile:(NSString*)strFileName
//{
//    NSURLResponse *response = nil;
//    NSError *error = nil;
//    NSString * strPDFURL = [NSString stringWithFormat:@"%@%@",FILEURL,strFileName];
//    NSURL * url = [NSURL URLWithString:strPDFURL];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//
//    if([data length]>10000)
//    {
//        NSLog(@"PDF파일이 존재");
//    }
//    return data;
//}

/*
 함수명 : SaveFileAtFolder
 설명   : 년도폴더의 서브폴더("/image" of "/pdf")에 파일을 저장한다.
 매개변수: strYear    - 저장하고자 하는 년도폴더명
         nTarget    - 저장하고자 하는 서브폴더명 (0:"/image", 1:"/pdf")
        strFileName - 저장하고자 하는 파일명(==서버의 원본파일명) 
         data       - 이미지 or PDF파일 데이터 (NSData)
 리턴값 : YES or NO
 */

-(BOOL)SaveFileAtFolder:(NSString*)strFileName TARGET:(int)nTarget DATA:(NSData*)data
{
    BOOL bRet = NO;
    if ([data length] <= 0) return bRet;
    
    NSString * strSubFolder;
    if (nTarget == SAVE_IMAGE)
        strSubFolder = [NSString stringWithFormat:@"%@", IMAGE_FOLDERNAME];
    else
        strSubFolder = [NSString stringWithFormat:@"%@", PDF_FOLDERNAME];
    NSLog(@"str : %@",strSubFolder);

    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    
    //1) Create "SUB" Dir => ex."/pdf" or "/image"
    NSString* makeDir = [DOCUMENTSPATH stringByAppendingFormat:@"/%@", strSubFolder];
    NSLog(@"makedir: %@",makeDir);
    BOOL success = [fileManager fileExistsAtPath:makeDir isDirectory:&isDir];
    if (success && isDir) {
    } else {
        
        bRet = [fileManager createDirectoryAtPath:makeDir withIntermediateDirectories:NO attributes:nil error:nil];
    }

    NSString* _fileName = [DOCUMENTSPATH stringByAppendingFormat:@"/%@/%@", strSubFolder, strFileName];
    
    bRet = [data writeToFile:_fileName atomically:NO];
    
    return bRet;
}

#pragma mark -  NSURLConnectionDelegate
//총 파일의 크기와 현재까지 업로드된 파일의 크기를 이 메소드를 통해서 알 수 있다. 적당히 계산해서 프로그레스바에 넣어준다.
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    NSLog(@"uploading %d    %d    %d",bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    float num = totalBytesWritten;
    float total = totalBytesExpectedToWrite;
    float percent = num/total;
    self.progressView.progress = percent;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	NSDictionary *allHeaders = [((NSHTTPURLResponse *)response) allHeaderFields];
	NSLog(@" %@", allHeaders);
    
	if ([response respondsToSelector:@selector(statusCode)]) 
	{
		int statusCode = [((NSHTTPURLResponse *)response) statusCode];
		NSLog(@"statusCode = %d", statusCode);
		
		// IF THE PAGE CANNOT BE FOUND CANCEL THE DOWNLOAD AND PRESENT A WARNING MESSAGE
        if (statusCode != 200)  
		{
			[connection cancel];
            [self.progressAlert dismissWithClickedButtonIndex:0 animated:YES];
            
			//NSString *errorMessage = [NSString stringWithFormat:@"Unable to download the prices file.  Prices shown may therefore not be current."];
            NSString *errorMessage = [NSString stringWithFormat:@"파일을 다운로드 할 수 없습니다."];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"다운로드 오류" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			alertView.tag = DOWNFAIL_ALERT_TAG;
			[alertView show];
			alertView = nil;
            
            // OTHERWISE CONTINUE WITH THE DOWNLOAD
		} else {
			if ( [response expectedContentLength] != NSURLResponseUnknownLength )
			{
                dataPDF        = [[NSMutableData alloc] init];
				numberFileSize = [NSNumber numberWithLong: [response expectedContentLength] ];
				NSLog(@"Length Avaialble = %d", [numberFileSize intValue]);
                _fTot = 0;
			}
			else
			{
				NSLog(@"Length NOT Avaialble");
			}
		}
    }
}

//파일 업로드 완료 되었을 때
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    _fTot += (float)[data length];
    float percent = _fTot/[numberFileSize floatValue];
    self.progressView.progress = percent;
    NSLog(@"didReceiveData == %d", [data length]);
    
    self.progressAlert.message = [NSString stringWithFormat:@"%d / %d KB\n   ", (int)_fTot/1024, [numberFileSize intValue]/1024];
    
    [dataPDF appendData:data];
}

//끝나면 프로그레스바가 있는 Alert을 닫아준다.
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"upload end");
    [self.progressAlert dismissWithClickedButtonIndex:0 animated:YES];   
    
    if ([dataPDF length] > 10000) 
    {
        //파일 저장
        [self SaveFileAtFolder:fileName TARGET:SAVE_PDF DATA:dataPDF];
        if ([[[GlobalValue sharedSingleton] value] isEqualToString:@"contents"]) {
            [delegate downloadImgChange];
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"다운로드 완료"
                                                        message:@"파일이 다운로드되었습니다.\n지금 바로 열어보시겠습니까?" 
                                                       delegate:self cancelButtonTitle:@"아니오" 
                                              otherButtonTitles:@"예", nil];
    
    alert.tag = FILEOPEN_ALERT_TAG;
        
    [alert show];
    
    
    
    self.dataPDF = nil;
}

//파일 다운로드 중 실패하였을 경우
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"upload fail");
    [self.progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"파일 다운로드를 실패하였습니다." 
                                                   delegate:self cancelButtonTitle:@"확인" 
                                          otherButtonTitles:nil];
    
    [alert show];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"clickedButtonAtIndex");
    NSLog(@"%i",buttonIndex);
    if (DOWN_ALERT_TAG == alertView.tag) //다운로드 여부 팝업
    {
        NSLog(@"다운로드 취소 처리를 하세요!!");
        [connection cancel];
    }
    else if (FILEOPEN_ALERT_TAG == alertView.tag) //다운로드 완료후 파일열기 여부 팝업
    {

        if (YES == buttonIndex) 
        {
            //사보파일 열기.
            [delegate contentManager:self didFinish:self.fileName];
        }
    }
    
}


#pragma mark -  static method
/*
 함수명 : MakeFolder
 설명   : 폴더를 생성한다.
 매개변수: strName - 생성하고자 하는 년도명(==폴더명)
 리턴값 : YES or NO
 */
+(BOOL)MakeFolder:(NSString*)strName
{
    //  DOCUMENTSPATH =>  /Users/jeonghuya/Library/Application Support/iPhone Simulator/4.3.2/Applications/2AB547CF-DA94-4168-A1E1-E3F933F0CA1E/Documents
    
    BOOL bRet = NO;
    NSString* makeDir = [DOCUMENTSPATH stringByAppendingFormat:@"/%@", strName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL success = [fileManager fileExistsAtPath:makeDir isDirectory:&isDir];
    if (success && isDir) {
    } else {
        bRet = [fileManager createDirectoryAtPath:makeDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    //pdf, image폴더
    
    return bRet;
}


/*
 함수명 : isExistLocalFile
 설명   : 파일의 존재유무를 리턴한다.
 매개변수: strYear    - 쿼리하고자 하는 년도폴더명
 nTarget    - 쿼리하고자 하는 서브폴더명 (0:"/image", 1:"/pdf")
 strFileName - 쿼리하고자 하는 파일명(==서버의 원본파일명)
 리턴값 : YES or NO
 */
+(BOOL)isExistLocalFile:strFileName TARGET:(int)nTarget
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString * strSubFolder;
    if (nTarget == SAVE_IMAGE)
        strSubFolder = [NSString stringWithFormat:@"%@", IMAGE_FOLDERNAME];
    else
        strSubFolder = [NSString stringWithFormat:@"%@", PDF_FOLDERNAME];
    
    NSString* fileName = [DOCUMENTSPATH stringByAppendingFormat:@"/%@/%@", strSubFolder, strFileName];
    
    BOOL isDir;
    BOOL bRet = [fileManager fileExistsAtPath:fileName isDirectory:&isDir];
    return bRet;
}


+(NSString*)getLocalFilePath:(NSString *)strFileName TARGET:(int)nTarget
{
    NSString * strSubFolder;
    if (nTarget == SAVE_IMAGE)
        strSubFolder = [NSString stringWithFormat:@"%@", IMAGE_FOLDERNAME];
    else
        strSubFolder = [NSString stringWithFormat:@"%@", PDF_FOLDERNAME];
    
    NSString * strLocalPDFFile = [DOCUMENTSPATH stringByAppendingFormat:@"/%@/%@", strSubFolder, strFileName];
    
    NSLog(@"strLocal : %@",strLocalPDFFile);
    
    return strLocalPDFFile;
}

/*
 함수명 : DeleteDir
 설명   : 사보폴더를 삭제한다.
 매개변수: strYear    - 해당년도
 리턴값 : YES or NO
 */
+(BOOL)DeleteDir:(int)nTarget
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSString * strSubFolder = @"";
    if (nTarget == SAVE_IMAGE)
        strSubFolder = [NSString stringWithFormat:@"%@", IMAGE_FOLDERNAME];
    else if(nTarget == SAVE_PDF)
        strSubFolder = [NSString stringWithFormat:@"%@", PDF_FOLDERNAME];
    NSLog(@"strsubfolder : %@",strSubFolder);
    
    NSString* delPath = [DOCUMENTSPATH stringByAppendingFormat:@"/%@", strSubFolder];
    
    NSLog(@"delete : %@",delPath);
    
    
    BOOL bRet = [fileManager removeItemAtPath:delPath error:NO];
    return bRet;
}

/*
 함수명 : DeletePDFFile
 설명   : 사보파일를 삭제한다.
 매개변수: strFileName    - 해당 파일
 nTarget    - 서브폴더 (0:"/image", 1:"/pdf")
 리턴값 : YES or NO
 */
+(BOOL)DeletePDFFile:(NSString*)strFileName TARGET:(int)nTarget
{
    //alert add
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSString * strSubFolder = @"";
    if (nTarget == SAVE_IMAGE)
        strSubFolder = [NSString stringWithFormat:@"%@", IMAGE_FOLDERNAME];
    else if(nTarget == SAVE_PDF)
        strSubFolder = [NSString stringWithFormat:@"%@", PDF_FOLDERNAME];
    NSLog(@"strsubfolder : %@",strSubFolder);
    
    NSString* delPath = [DOCUMENTSPATH stringByAppendingFormat:@"/%@/%@", strSubFolder, strFileName];
    
    NSLog(@"deletePath : %@",delPath);
    
    BOOL bRet = [fileManager removeItemAtPath:delPath error:NO];
    return bRet;
}


@end

