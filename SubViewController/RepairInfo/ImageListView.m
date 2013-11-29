//
//  ImageListView.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 16..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "ImageListView.h"
//
#import "NSData+AESAdditions.h"

@implementation ImageListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        sort1BtnArr = [[NSMutableArray alloc] init];
        sort2BtnArr = [[NSMutableArray alloc] init];
        sort1InfoArr = [[NSMutableArray alloc] init];
        sort2InfoArr = [[NSMutableArray alloc] init];
        sort3InfoArr = [[NSMutableArray alloc] init];
        
        NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
        NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
        NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&accessToken=%@&timestamp=%0.f"
                         , KHOST, LISTREPAIRIMAGESPECIES
                         , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                         , [temp hexadecimalString]
                         , timeInMiliseconds];
        
        httpRequest *_httpRequest = [[httpRequest alloc] init];
        [_httpRequest setDelegate:self selector:@selector(sort1ListResult:)];
        [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    }
    return self;
}

- (void)sort1ListResult:(NSString *)data {
    NSLog(@"sort1List result : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            sort1InfoArr = [resultsDictionary objectForKey:@"results"];
            
            UIScrollView *sort1View = [[UIScrollView alloc] initWithFrame:CGRectMake(12, 0, (self.frame.size.width - 24)/3, 120)];
            [sort1View setDelegate:self];
            [sort1View setTag:1];
            [sort1View setBackgroundColor:[UIColor clearColor]];
            [self addSubview:sort1View];
            
            if ([sort1InfoArr count] % 3 == 0) {
                [sort1View setContentSize:CGSizeMake((self.frame.size.width - 24)/3, 40 * ([sort1InfoArr count] / 3))];
            } else {
                [sort1View setContentSize:CGSizeMake((self.frame.size.width - 24)/3, 40 * (([sort1InfoArr count] / 3) + 1))];
            }
            
            UIButton *btn;
            for (int i = 0; i < [sort1InfoArr count]; i++) {
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setTag:i];
                [btn setFrame:CGRectMake(((i % 3) * ((self.frame.size.width - 24)/3)/3), (i / 3) * 40, ((self.frame.size.width - 24)/3)/3 - 1, 39)];
                [btn setTitle:[[sort1InfoArr objectAtIndex:i] objectForKey:@"rpairsSpeciesNm"] forState:UIControlStateNormal];
                [btn setBackgroundColor:[UIColor redColor]];
                [btn addTarget:self action:@selector(sort1Btn:) forControlEvents:UIControlEventTouchUpInside];
                [sort1BtnArr addObject:btn];
                [sort1View addSubview:btn];
                
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

- (void)sort1Btn:(id)sender {
    for (int i = 0; i < [sort1BtnArr count]; i++) {
        if (((UIButton *)sender) == ((UIButton *)[sort1BtnArr objectAtIndex:i])) {
            [((UIButton *)[sort1BtnArr objectAtIndex:i]) setSelected:YES];
            [(UIButton *)[sort1BtnArr objectAtIndex:i] setBackgroundColor:[UIColor blueColor]];
            [(UIButton *)[sort1BtnArr objectAtIndex:i] setUserInteractionEnabled:NO];
            
            NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
            NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
            NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&rpairsSpeciesCd=%@&accessToken=%@&timestamp=%0.f"
                             , KHOST, LISTREPAIRIMAGEITEM
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                             , [[sort1InfoArr objectAtIndex:i] objectForKey:@"rpairsSpeciesCd"]
                             , [temp hexadecimalString]
                             , timeInMiliseconds];
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(sort2ListResult:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        } else {
            [((UIButton *)[sort1BtnArr objectAtIndex:i]) setSelected:NO];
            [(UIButton *)[sort1BtnArr objectAtIndex:i] setBackgroundColor:[UIColor redColor]];
            [(UIButton *)[sort1BtnArr objectAtIndex:i] setUserInteractionEnabled:YES];
        }
    }
}

- (void)sort2ListResult:(NSString *)data {
    NSLog(@"sort2List result : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
//            sort2InfoArr = nil;
            [sort2BtnArr removeAllObjects];
            
            sort2InfoArr = [resultsDictionary objectForKey:@"results"];
            
            for (UIView *view in self.subviews) {
                if ([view isKindOfClass:[UIScrollView class]]) {
                    if (view.tag == 2) {
                        [view removeFromSuperview];
                    }
                }
            }
            
            UIScrollView *sort2View = [[UIScrollView alloc] initWithFrame:CGRectMake(13 + (self.frame.size.width - 24)/3, 0, ((self.frame.size.width - 24)/3)*2, 120)];
            [sort2View setDelegate:self];
            [sort2View setTag:2];
            [sort2View setBackgroundColor:[UIColor yellowColor]];
            [self addSubview:sort2View];
            
            if ([sort2InfoArr count] % 4 == 0) {
                [sort2View setContentSize:CGSizeMake(((self.frame.size.width - 24)/3)*2, 40 * ([sort2InfoArr count] / 4))];
            } else {
                [sort2View setContentSize:CGSizeMake(((self.frame.size.width - 24)/3)*2, 40 * (([sort2InfoArr count] / 4) + 1))];
            }
                        
            UIButton *btn;
            for (int i = 0; i < [sort2InfoArr count]; i++) {
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setTag:i];
                [btn setFrame:CGRectMake(((i % 4) * (((self.frame.size.width - 24)/3)*2)/4), (i / 4) * 40, (((self.frame.size.width - 24)/3)*2)/4 - 1, 39)];
                [btn setTitle:[[sort2InfoArr objectAtIndex:i] objectForKey:@"rpairsItemNm"] forState:UIControlStateNormal];
                [btn setBackgroundColor:[UIColor redColor]];
                [btn addTarget:self action:@selector(sort2Btn:) forControlEvents:UIControlEventTouchUpInside];
                [sort2BtnArr addObject:btn];
                [sort2View addSubview:btn];
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

- (void)sort2Btn:(id)sender {
    for (int i = 0; i < [sort2BtnArr count]; i++) {
        if (((UIButton *)sender) == ((UIButton *)[sort2BtnArr objectAtIndex:i])) {
            [((UIButton *)[sort2BtnArr objectAtIndex:i]) setSelected:YES];
            [(UIButton *)[sort2BtnArr objectAtIndex:i] setBackgroundColor:[UIColor blueColor]];
            [(UIButton *)[sort2BtnArr objectAtIndex:i] setUserInteractionEnabled:NO];
            
            NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
            NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
            NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSString *url = [NSString stringWithFormat:@"%@%@?currentPage=%d&maxResults=%d&maxLinks=%d&brandCd=%@&shopCd=%@&rpairsSpeciesCd=%@&rpairsItemCd=%@&accessToken=%@&timestamp=%0.f"
                             , KHOST, PAGEDREPAIRIMAGELIST
                             , 1
                             , 10
                             , 10
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                             , [[NSUserDefaults standardUserDefaults] objectForKey:@"shopCd"]
                             , [[sort2InfoArr objectAtIndex:i] objectForKey:@"rpairsSpeciesCd"]
                             , [[sort2InfoArr objectAtIndex:i] objectForKey:@"rpairsItemCd"]
                             , [temp hexadecimalString]
                             , timeInMiliseconds];
            
            httpRequest *_httpRequest = [[httpRequest alloc] init];
            [_httpRequest setDelegate:self selector:@selector(sort3ListResult:)];
            [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
        } else {
            [((UIButton *)[sort2BtnArr objectAtIndex:i]) setSelected:NO];
            [(UIButton *)[sort2BtnArr objectAtIndex:i] setBackgroundColor:[UIColor redColor]];
            [(UIButton *)[sort2BtnArr objectAtIndex:i] setUserInteractionEnabled:YES];
        }
    }
}

- (void)sort3ListResult:(NSString *)data {
    NSLog(@"sort3List result : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
//            sort3InfoArr = 
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
