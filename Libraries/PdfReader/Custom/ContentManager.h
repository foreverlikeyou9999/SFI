//
//  ContentManager.h
//  kNewsletter
//
//  Created by 정후 조 on 11. 11. 1..
//  Copyright 2011 코롱베니트. All rights reserved.
//

#import <Foundation/Foundation.h>

enum SAVE_TARGET {SAVE_IMAGE = 0, SAVE_PDF};

@class ContentManager;

@protocol ContentManagerDelegate <NSObject>

@required // Delegate protocols

- (void)contentManager:(ContentManager*)contentMgr didFinish:(NSString*) fileName;
- (void)downloadImgChange;

@end


@interface ContentManager : NSObject <NSURLConnectionDelegate, UIAlertViewDelegate>
{
    NSURLConnection *connection;
    NSMutableData  * dataPDF;
    UIProgressView * progressView;
    UIAlertView    * progressAlert;
    NSNumber       * numberFileSize;
    float          _fTot;
    
    NSString  *fileName;
    NSString  *fileURL;
    
    id <ContentManagerDelegate> __weak delegate;
}
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData  * dataPDF;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIAlertView *progressAlert;
@property (nonatomic, strong) NSNumber       * numberFileSize;

@property (nonatomic, strong) NSString  *fileName;
@property (nonatomic, strong) NSString  *fileURL;

@property (nonatomic, weak) id <ContentManagerDelegate> delegate;

// URL로 부터 파일 다운로드
-(NSData*)DownloadServerFile:(NSString*)strURL;
//폴더에 이미지 저장
-(BOOL)SaveFileAtFolder:(NSString*)strFileName TARGET:(int)nTarget DATA:(NSData*)data;


//폴더 생성
+(BOOL)MakeFolder:(NSString*)strYear;
//로컬폴더에 데이터가 존재하는지 검사
+(BOOL)isExistLocalFile:(NSString *)strFileName TARGET:(int)nTarget;
//풀패스를 리턴
+(NSString*)getLocalFilePath:(NSString *)strFileName TARGET:(int)nTarget;

//폴더를 삭제
+(BOOL)DeleteDir:(int)nTarget;
+(BOOL)DeletePDFFile:(NSString*)strFileName TARGET:(int)nTarget;
@end
