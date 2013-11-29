//
//  ThumbnailView.m
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 16..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "ThumbnailView.h"
//
#import "ContentManager.h"
//
#import "httpRequest.h"
#import "downloadRequest.h"
#import "NSData+AESAdditions.h"

@implementation ThumbnailView
@synthesize thumbnailImgBtn = _thumbnailImgBtn;
@synthesize tagView = _tagView;
@synthesize tagName = _tagName;
@synthesize target;
@synthesize selector;
@synthesize thumbnailDic;
@synthesize subDir = _subDir;
@synthesize currentScrinTyCd = _currentScrinTyCd;
@synthesize pdfDownloadImg = _pdfDownloadImg;
@synthesize thumbTag = _thumbTag;
@synthesize selectedTag = _selectedTag;

#pragma mark - Life Cycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.selectedTag = 0;
        
    }
    return self;
}

- (void) dealloc
{
    ;
    ;
}

#pragma mark - public method
- (void)setDelegate:(id)aTarget selector:(SEL)aSelector {
    self.target = aTarget;
    self.selector = aSelector;
    
    if (aSelector == nil) {
        
    } else {
        selectorRange = [[NSString stringWithUTF8String:sel_getName(aSelector)] rangeOfString:@"withInfoArr"];
    }
}

- (void)dnThumbImg:(NSString *)directory {
    self.subDir = directory;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *dirPath = [NSString stringWithFormat:@"%@/salesforce/%@/%@/%@"
                         , cachesDirectory
                         , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                         , self.subDir
                         , [thumbnailDic objectForKey:@"cntntsId"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/%@/%@/%@"
                                                                           , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                                                           , self.subDir
                                                                           , [thumbnailDic objectForKey:@"cntntsId"]
                                                                           , [thumbnailDic objectForKey:@"thumbFileLc"]]];
    
    BOOL fileExistsAtPath = [fileManager fileExistsAtPath:cachePath];
    if (fileExistsAtPath) {
        UIImageView *baseView;
//        if (self.bounds.size.width == 187) {
//            baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_ThumbBG"]];
//            [baseView setUserInteractionEnabled:YES];
//            [baseView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//            [self addSubview:baseView];
//        } else if (self.bounds.size.width == 148) {
//            baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LBK_ThumbBG"]];
//            [baseView setUserInteractionEnabled:YES];
//            [baseView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//            [self addSubview:baseView];
//        } else if (self.bounds.size.width == 361) {
//            baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_PR_ThumbBG"]];
//            [baseView setUserInteractionEnabled:YES];
//            [baseView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//            [self addSubview:baseView];
//        }
        
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void) {
            dispatch_async( dispatch_get_main_queue(), ^(void){
                [self createComponents:baseView];
            });
        });
    } else {
        UIImageView *baseView;
//        if (self.bounds.size.width == 187) {
//            baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_ThumbBG"]];
//            [baseView setUserInteractionEnabled:YES];
//            [baseView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//            [self addSubview:baseView];
//        } else if (self.bounds.size.width == 148) {
//            baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_LBK_ThumbBG"]];
//            [baseView setUserInteractionEnabled:YES];
//            [baseView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//            [self addSubview:baseView];
//        } else if (self.bounds.size.width == 361) {
//            baseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_PR_ThumbBG"]];
//            [baseView setUserInteractionEnabled:YES];
//            [baseView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//            [self addSubview:baseView];
//        }
        
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[thumbnailDic objectForKey:@"dwldThumbPath"]]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            NSData *temp = [NSData dataWithData:UIImagePNGRepresentation([UIImage imageWithData:data])];
            
            BOOL success = [temp writeToFile:cachePath atomically:YES];
            if (success) {
                [self createComponents:baseView];
            }
        }];
    }
}

#pragma mark - private method
- (void)dnCntImg:(NSString *)directory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *dirPath = [NSString stringWithFormat:@"%@/salesforce/%@/%@/%@"
                         , cachesDirectory
                         , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                         , directory
                         , [thumbnailDic objectForKey:@"cntntsId"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/%@/%@/%@"
                                                                           , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                                                           , directory
                                                                           , [thumbnailDic objectForKey:@"cntntsId"]
                                                                           , [thumbnailDic objectForKey:@"cntntsFileLc"]]];
    
    BOOL fileExistsAtPath = [fileManager fileExistsAtPath:cachePath];
    if (fileExistsAtPath) {
#if NOT_USED
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void) {
            dispatch_async( dispatch_get_main_queue(), ^(void){
                if (self.thumbIndex == 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"imgdownok" object:nil];
                }
            });
        });
#endif
    } else {
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[thumbnailDic objectForKey:@"dwldCntntsPath"]]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            NSData *temp = [NSData dataWithData:UIImagePNGRepresentation([UIImage imageWithData:data])];
            
            [temp writeToFile:cachePath atomically:YES];
        }];
    }
}

- (void)createComponents:(UIImageView *)baseView {    
    if (self.bounds.size.width == 187) {//AD GALLERY, e-Catalog
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDirectory = [paths objectAtIndex:0];
        NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/%@/%@/%@"
                                                                               , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                                                               , self.subDir
                                                                               , [thumbnailDic objectForKey:@"cntntsId"]
                                                                               , [thumbnailDic objectForKey:@"thumbFileLc"]]];
        
        UIImageView *thumbImg = [[UIImageView alloc] initWithImage:[self resizedImage:[UIImage imageWithContentsOfFile:cachePath] inRect:CGRectMake(2, 1, self.bounds.size.width - 4, 129)]];
        [self addSubview:thumbImg];
        
        self.thumbnailImgBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
        [self.thumbnailImgBtn setImage:[self resizedImage:[UIImage imageWithContentsOfFile:cachePath] inRect:CGRectMake(0, 0, self.bounds.size.width - 4, 129)] forState:UIControlStateNormal];
        [self.thumbnailImgBtn setImage:[UIImage imageNamed:@"IM_Sub_ThumbSelect"] forState:UIControlStateHighlighted];
        [self.thumbnailImgBtn setFrame:CGRectMake(2, 1, self.thumbnailImgBtn.imageView.image.size.width, self.thumbnailImgBtn.imageView.image.size.height)];
        [self.thumbnailImgBtn addTarget:self action:@selector(typeSort) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.thumbnailImgBtn];
        
        self.tagView = [[UIImageView alloc] init];
        [self addSubview:self.tagView];
        
        UIImageView *tagImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_ThumbTagBG"]];
        [tagImg setFrame:CGRectMake(0, self.thumbnailImgBtn.imageView.image.size.height - tagImg.image.size.height, tagImg.image.size.width, tagImg.image.size.height)];
        [self.thumbnailImgBtn addSubview:tagImg];
        
        if ([[thumbnailDic objectForKey:@"cntntsTyNm"] isEqualToString:@"PDF"]) {
            self.pdfDownloadImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_PDF_Down_Before"] highlightedImage:[UIImage imageNamed:@"IM_PDF_Down_After"]];
            [self.pdfDownloadImg setFrame:CGRectMake(tagImg.image.size.width - self.pdfDownloadImg.image.size.width, 0, self.pdfDownloadImg.image.size.width, self.pdfDownloadImg.image.size.height)];
            
            NSString *fileDownURL = [thumbnailDic objectForKey:@"dwldCntntsPath"];
            NSString *fileName = [[fileDownURL componentsSeparatedByString:@"/"] lastObject];
            
//            NSLog(@"fileDownURL : %@",fileDownURL);
            
            BOOL bExistFile = [ContentManager isExistLocalFile:fileName TARGET:SAVE_PDF];
            if (bExistFile) {
                [self.pdfDownloadImg setHighlighted:YES];
            } else {
                [self.pdfDownloadImg setHighlighted:NO];
            }
            
            [tagImg addSubview:self.pdfDownloadImg];
        }
        
        UILabel *tagLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 3, tagImg.image.size.width - 20, 12)];
        [tagLbl setBackgroundColor:[UIColor clearColor]];
        [tagLbl setText:[thumbnailDic objectForKey:@"ctgryNm"]];
        [tagLbl setFont:[UIFont fontWithName:@"Roboto-Black" size:10.0f]];
        [tagLbl setTextColor:[UIColor whiteColor]];
        [tagLbl setShadowColor:[UIColor blackColor]];
        [tagLbl setShadowOffset:CGSizeMake(1, 0)];
        [tagImg addSubview:tagLbl];
        
        self.tagName = [[UILabel alloc] initWithFrame:CGRectMake(9, 133, 167, 38)];
        [self.tagName setText:[NSString stringWithFormat:@"%@\n ", [thumbnailDic objectForKey:@"cntntsNm"]]];
        [self.tagName setNumberOfLines:0];
        [self.tagName setLineBreakMode:NSLineBreakByCharWrapping];
        [self.tagName setBackgroundColor:[UIColor clearColor]];
        [self.tagName setTextColor:[UIColor whiteColor]];
        [self.tagName setTextAlignment:NSTextAlignmentLeft];
        [self.tagName setFont:[UIFont systemFontOfSize:11.0f]];
        [self addSubview:self.tagName];
    } else if (self.bounds.size.width == 148) {//LOOK BOOK
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDirectory = [paths objectAtIndex:0];
        NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/%@/%@/%@"
                                                                               , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                                                               , self.subDir
                                                                               , [thumbnailDic objectForKey:@"cntntsId"]
                                                                               , [thumbnailDic objectForKey:@"thumbFileLc"]]];
        
        
        self.thumbnailImgBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
        [self.thumbnailImgBtn setImage:[self resizedImage:[UIImage imageWithContentsOfFile:cachePath] inRect:CGRectMake(0, 0, self.bounds.size.width - 4, self.bounds.size.height - 4)] forState:UIControlStateNormal];
        [self.thumbnailImgBtn setFrame:CGRectMake(2, 0, self.thumbnailImgBtn.imageView.image.size.width, self.thumbnailImgBtn.imageView.image.size.height)];
        [self.thumbnailImgBtn addTarget:self action:@selector(typeSort) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.thumbnailImgBtn];
    } else if (self.bounds.size.width == 361) {//PROMOTION        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDirectory = [paths objectAtIndex:0];
        NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/%@/%@/%@"
                                                                               , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                                                               , self.subDir
                                                                               , [thumbnailDic objectForKey:@"cntntsId"]
                                                                               , [thumbnailDic objectForKey:@"thumbFileLc"]]];
        UIImageView *thumbImg = [[UIImageView alloc] initWithImage:[self resizedImage:[UIImage imageWithContentsOfFile:cachePath] inRect:CGRectMake(2, 0, self.bounds.size.width, 145)]];
        [self addSubview:thumbImg];

        self.thumbnailImgBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
        [self.thumbnailImgBtn setImage:[self resizedImage:[UIImage imageWithContentsOfFile:cachePath] inRect:CGRectMake(0, 0, self.bounds.size.width, 145)] forState:UIControlStateNormal];
        [self.thumbnailImgBtn setFrame:CGRectMake(2, 0, self.thumbnailImgBtn.imageView.image.size.width, self.thumbnailImgBtn.imageView.image.size.height)];
        [self.thumbnailImgBtn addTarget:self action:@selector(typeSort) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.thumbnailImgBtn];
        
        if ([thumbnailDic objectForKey:@"linkUrl"] != [NSNull null]) {
            UIImageView *linkImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_PROMO_Link"]];
            [linkImg setFrame:CGRectMake(self.thumbnailImgBtn.frame.size.width - linkImg.image.size.width, self.thumbnailImgBtn.frame.size.height - linkImg.image.size.height, linkImg.image.size.width, linkImg.image.size.height)];
            [self.thumbnailImgBtn addSubview:linkImg];
        }
        
        self.tagName = [[UILabel alloc] initWithFrame:CGRectMake(10, 152, 359, 13)];
        [self.tagName setText:[NSString stringWithFormat:@"%@", [thumbnailDic objectForKey:@"cntntsNm"]]];
        [self.tagName setNumberOfLines:0];
        [self.tagName setLineBreakMode:NSLineBreakByWordWrapping];
        [self.tagName setBackgroundColor:[UIColor clearColor]];
        [self.tagName setTextColor:[UIColor whiteColor]];
        [self.tagName setTextAlignment:NSTextAlignmentLeft];
        [self.tagName setFont:[UIFont systemFontOfSize:12.0f]];
        
        UILabel *tagLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 171, 359, 13)];
        [tagLbl setBackgroundColor:[UIColor clearColor]];
        [tagLbl setText:[NSString stringWithFormat:@"%@-%@-%@ ~ %@-%@-%@"
                         , [[thumbnailDic objectForKey:@"bgnDt"] substringWithRange:NSMakeRange(0, 4)]
                         , [[thumbnailDic objectForKey:@"bgnDt"] substringWithRange:NSMakeRange(4, 2)]
                         , [[thumbnailDic objectForKey:@"bgnDt"] substringWithRange:NSMakeRange(6, 2)]
                         , [[thumbnailDic objectForKey:@"endDt"] substringWithRange:NSMakeRange(0, 4)]
                         , [[thumbnailDic objectForKey:@"endDt"] substringWithRange:NSMakeRange(4, 2)]
                         , [[thumbnailDic objectForKey:@"endDt"] substringWithRange:NSMakeRange(6, 2)]]];
        [tagLbl setFont:[UIFont systemFontOfSize:12.0f]];
        [tagLbl setTextColor:[UIColor whiteColor]];
        [tagLbl setShadowColor:[UIColor blackColor]];
        [tagLbl setShadowOffset:CGSizeMake(1, 0)];
        [self addSubview:tagLbl];
        
        [self addSubview:self.tagName];
    } else {

    }
}

-(UIImage *)resizedImage:(UIImage*)inImage  inRect:(CGRect)thumbRect {
    // Creates a bitmap-based graphics context and makes it the current context.
    UIGraphicsBeginImageContext(thumbRect.size);
    [inImage drawInRect:thumbRect];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (void)doNetworkErrorProcess {
    NSLog(@"error");
}

- (void)result:(NSString *)data {
    NSLog(@"result data : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            if ([[[resultsDictionary objectForKey:@"result"] objectForKey:@"hasPrduct"] intValue] == 1) {
                NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&cntntsId=%@&shopCd=%@&accessToken=%@&timestamp=%0.f"
                                 , KHOST
                                 , LISTPRODUCT
                                 , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                                 , [thumbnailDic objectForKey:@"cntntsId"]
                                 , [[NSUserDefaults standardUserDefaults] objectForKey:@"shopCd"]
                                 , [temp hexadecimalString]
                                 , timeInMiliseconds];
                
                
                httpRequest *_httpRequest = [[httpRequest alloc] init];
                [_httpRequest setDelegate:self selector:@selector(productListResult:)];
                [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
            } else {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"productslist"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if ([thumbnailDic objectForKey:@"linkUrl"] != [NSNull null]) {
                    NSRange mp4Search = [[thumbnailDic objectForKey:@"linkUrl"] rangeOfString:@".mp4"];
                    
                    if (mp4Search.location == NSNotFound) {
                        NSString *embedHTML = [NSString stringWithFormat:@"\
                                               <html>\
                                               <head>\
                                               <script src=\"http://www.youtube.com/player_api\"></script>\
                                               <style type=\"text/css\">\
                                               body, div {\
                                               margin: 0px;\
                                               padding: 0px;\
                                               }\
                                               </style>\
                                               </head>\
                                               <body>\
                                               <div id=\"media_area\"></div>\
                                               </body>\
                                               <script>\
                                               var ytPlayer = null;\
                                               function onYouTubePlayerAPIReady() {\
                                               ytPlayer = new YT.Player('media_area', {height: '420', width: '746', videoId: \'%@\',\
                                               events: {'onReady': onPlayerReady, 'onStateChange': onPlayerStateChange},\
                                               playerVars: {showinfo: 0, rel: 0}\
                                               });\
                                               }\
                                               function onPlayerReady(e) {\
                                               e.target.playVideo();\
                                               }\
                                               function onPlayerStateChange(e) {\
                                               if(e.data === 0) {\
                                               e.target.playVideo();\
                                               }\
                                               }\
                                               </script>\
                                               </html>", [[[thumbnailDic objectForKey:@"linkUrl"] componentsSeparatedByString:@"/embed/"] objectAtIndex:1]];
                        
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                        NSString *cachesDirectory = [paths objectAtIndex:0];
                        NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/YT_Player.html"
                                                                                               , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]]];
                        
                        BOOL success = [embedHTML writeToFile:cachePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                        if (success) {
                            [target clickedThumbnail:self];
                        }
                    } else {
                        [target clickedThumbnail:self];
                    }
                } else {
                    [target clickedThumbnail:self];
                }
            }
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
            
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app logout:@"yes"];
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
        
    }
}

- (void)productListResult:(NSString *)data {
    NSLog(@"productlist data : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[resultsDictionary objectForKey:@"results"]] forKey:@"productslist"];
            [[NSUserDefaults standardUserDefaults] synchronize];
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
            
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app logout:@"yes"];
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
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"productslist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([thumbnailDic objectForKey:@"linkUrl"] != [NSNull null]) {
        NSRange mp4Search = [[thumbnailDic objectForKey:@"linkUrl"] rangeOfString:@".mp4"];
        
        if (mp4Search.location == NSNotFound) {
            NSString *embedHTML = [NSString stringWithFormat:@"\
                                   <html>\
                                   <head>\
                                   <script src=\"http://www.youtube.com/player_api\"></script>\
                                   <style type=\"text/css\">\
                                   body, div {\
                                   margin: 0px;\
                                   padding: 0px;\
                                   }\
                                   </style>\
                                   </head>\
                                   <body>\
                                   <div id=\"media_area\"></div>\
                                   </body>\
                                   <script>\
                                   var ytPlayer = null;\
                                   function onYouTubePlayerAPIReady() {\
                                   ytPlayer = new YT.Player('media_area', {height: '420', width: '746', videoId: \'%@\',\
                                   events: {'onReady': onPlayerReady, 'onStateChange': onPlayerStateChange},\
                                   playerVars: {showinfo: 0, rel: 0}\
                                   });\
                                   }\
                                   function onPlayerReady(e) {\
                                   e.target.playVideo();\
                                   }\
                                   function onPlayerStateChange(e) {\
                                   if(e.data === 0) {\
                                   e.target.playVideo();\
                                   }\
                                   }\
                                   </script>\
                                   </html>", [[[thumbnailDic objectForKey:@"linkUrl"] componentsSeparatedByString:@"/embed/"] objectAtIndex:1]];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDirectory = [paths objectAtIndex:0];
            NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/YT_Player.html"
                                                                                   , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]]];
            
            BOOL success = [embedHTML writeToFile:cachePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            if (success) {
                [target clickedThumbnail:self];
            }
        } else {
            [target clickedThumbnail:self];
        }
    } else {
        [target clickedThumbnail:self];
    }
}

#pragma mark - IBAction Method
// 썸네일 버튼 선택시 호출
- (void)typeSort {
    NSLog(@"type sort");
    
    self.selectedTag = self.thumbTag;
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    if ([[thumbnailDic objectForKey:@"cntntsTyCd"] isEqualToString:@"008001"]) {
        [target thumbnailTouchOnOff:@"off"];
        NSLog(@"8001");
        
        if ([[thumbnailDic objectForKey:@"hasPrduct"] intValue] == 1) {
            NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&cntntsId=%@&accessToken=%@&timestamp=%0.f"
                             , KHOST
                             , GETCNTNTSINFO
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                             , [thumbnailDic objectForKey:@"cntntsId"]
                             , [temp hexadecimalString]
                             , timeInMiliseconds];
            
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(result:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        } else {
            [target clickedThumbnail:self];
        }
    } else if ([[thumbnailDic objectForKey:@"cntntsTyCd"] isEqualToString:@"008002"]) {
        [target thumbnailTouchOnOff:@"off"];
        NSLog(@"8002");
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDirectory = [paths objectAtIndex:0];
        NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/YT_Player.html"
                                                                               , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        [fileManager removeItemAtPath:cachePath error:nil];
        
        if ([[thumbnailDic objectForKey:@"hasPrduct"] intValue] == 1) {
            NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&cntntsId=%@&accessToken=%@&timestamp=%0.f"
                             , KHOST
                             , GETCNTNTSINFO
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                             , [thumbnailDic objectForKey:@"cntntsId"]
                             , [temp hexadecimalString]
                             , timeInMiliseconds];
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(result:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        } else {
            if ([thumbnailDic objectForKey:@"linkUrl"] != [NSNull null]) {
                NSRange mp4Search = [[thumbnailDic objectForKey:@"linkUrl"] rangeOfString:@".mp4"];
                
                if (mp4Search.location == NSNotFound) {
                    NSString *embedHTML = [NSString stringWithFormat:@"\
                                           <html>\
                                           <head>\
                                           <script src=\"http://www.youtube.com/player_api\"></script>\
                                           <style type=\"text/css\">\
                                           body, div {\
                                           margin: 0px;\
                                           padding: 0px;\
                                           }\
                                           </style>\
                                           </head>\
                                           <body>\
                                           <div id=\"media_area\"></div>\
                                           </body>\
                                           <script>\
                                           var ytPlayer = null;\
                                           function onYouTubePlayerAPIReady() {\
                                           ytPlayer = new YT.Player('media_area', {height: '420', width: '746', videoId: \'%@\',\
                                           events: {'onReady': onPlayerReady, 'onStateChange': onPlayerStateChange},\
                                           playerVars: {showinfo: 0, rel: 0}\
                                           });\
                                           }\
                                           function onPlayerReady(e) {\
                                           e.target.playVideo();\
                                           }\
                                           function onPlayerStateChange(e) {\
                                           if(e.data === 0) {\
                                           e.target.playVideo();\
                                           }\
                                           }\
                                           </script>\
                                           </html>", [[[thumbnailDic objectForKey:@"linkUrl"] componentsSeparatedByString:@"/embed/"] objectAtIndex:1]];
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSString *cachesDirectory = [paths objectAtIndex:0];
                    NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/salesforce/%@/YT_Player.html"
                                                                                           , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]]];
                    
                    BOOL success = [embedHTML writeToFile:cachePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    if (success) {
                        [target clickedThumbnail:self];
                    }
                } else {
                    [target clickedThumbnail:self];
                }
            } else {
                [target clickedThumbnail:self];
            }
        }
    } else if ([[thumbnailDic objectForKey:@"cntntsTyCd"] isEqualToString:@"008003"] || [[thumbnailDic objectForKey:@"cntntsTyCd"] isEqualToString:@"009002"]) {
        NSLog(@"8003, 9002");
        [target clickedThumbnail:self];
    } else if ([[thumbnailDic objectForKey:@"cntntsTyCd"] isEqualToString:@"008004"]) {
        
    } else if ([[thumbnailDic objectForKey:@"cntntsTyCd"] isEqualToString:@"008005"]) {
        [target thumbnailTouchOnOff:@"off"];
        [target clickedThumbnail:self];
    } else if ([[thumbnailDic objectForKey:@"cntntsTyCd"] isEqualToString:@"009001"]) {
        [target thumbnailTouchOnOff:@"off"];
        [target clickedThumbnail:self];
    }
}
#pragma mark - UIAlertView Controller

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if(target) {
            //            if (selectorRange.location == NSNotFound) {
            //                [target performSelector:selector withObject:[thumbnailDicobjectForKey:@"linkUrl"] withObject:[thumbnailDicobjectForKey:@"cntntsNm"]];
            //            } else {
            //                NSMutableArray *tempArr = [[NSMutableArray alloc] initWithObjects:[thumbnailDicobjectForKey:@"cntntsNm"], [thumbnailDicobjectForKey:@"cntntsTyCd"], nil];
            
//            [target performSelector:selector withObject:[thumbnailDic objectForKey:@"linkUrl"] withObject:thumbnailDic];
            [target clickedThumbnail:self];
            
            //                [tempArr release];
            //            }
        }
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
