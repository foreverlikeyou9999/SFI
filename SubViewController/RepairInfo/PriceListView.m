//
//  PriceListView.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 16..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "PriceListView.h"
//
#import "NSData+AESAdditions.h"
#import "NSString+UrlEncoding.h"

@implementation PriceListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        sort1BtnArr = [[NSMutableArray alloc] init];
        sort2BtnArr = [[NSMutableArray alloc] init];
        sort3BtnArr = [[NSMutableArray alloc] init];
        sort2InfoArr = [[NSMutableArray alloc] init];
        sort3InfoArr = [[NSMutableArray alloc] init];
        listInfoArr = [[NSMutableArray alloc] init];
        
        UIView *sortBg = [[UIView alloc] initWithFrame:CGRectMake(12, 0, frame.size.width - 24, 300)];
        [sortBg setBackgroundColor:[UIColor clearColor]];
        [self addSubview:sortBg];
        
        UITableView *sort1View = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, (frame.size.width - 24)/3, 300)];
        [sort1View setDelegate:self];
        [sort1View setDataSource:self];
        [sort1View setTag:0];
        [sort1View setBackgroundColor:[UIColor clearColor]];
        [sort1View setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [sortBg addSubview:sort1View];
        
        sort2View = [[UITableView alloc] initWithFrame:CGRectMake((frame.size.width - 24)/3, 0, (frame.size.width - 24)/3, 300)];
        [sort2View setDelegate:self];
        [sort2View setDataSource:self];
        [sort2View setTag:1];
        [sort2View setBackgroundColor:[UIColor clearColor]];
        [sort2View setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [sortBg addSubview:sort2View];
        
        sort3View = [[UITableView alloc] initWithFrame:CGRectMake(((frame.size.width - 24)/3)*2, 0, (frame.size.width - 24)/3, 300)];
        [sort3View setDelegate:self];
        [sort3View setDataSource:self];
        [sort3View setTag:2];
        [sort3View setBackgroundColor:[UIColor clearColor]];
        [sort3View setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [sortBg addSubview:sort3View];
        
        infoListView = [[UITableView alloc] initWithFrame:CGRectMake(12, 350, frame.size.width - 24, frame.size.height - 350)];
        [infoListView setDelegate:self];
        [infoListView setDataSource:self];
        [infoListView setTag:3];
        [self addSubview:infoListView];
    }
    return self;
}

- (void)sort2ListResult:(NSString *)data {
    NSLog(@"sort2List result : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            sort2InfoArr = [resultsDictionary objectForKey:@"results"];
            
            [sort2View reloadData];
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

- (void)sort3ListResult:(NSString *)data {
    NSLog(@"sort3List result : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            sort3InfoArr = [resultsDictionary objectForKey:@"results"];
            
            [sort3View reloadData];
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

- (void)priceInfoListResult:(NSString *)data {
    NSLog(@"priceInfoList result : %@", data);
    
    NSError *error = nil;
    
    NSDictionary *resultsDictionary = [data objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error == nil) {
        NSString *result = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusCd"];
        NSString *resultMsg = [[resultsDictionary objectForKey:@"status"] objectForKey:@"statusMssage"];
        
        if ([result isEqualToString:@"200"]) {
            listInfoArr = [resultsDictionary objectForKey:@"list"];
            
            [infoListView reloadData];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView.tag == 0) {
        return 2;
    } else if (tableView.tag == 1) {
        return [sort2InfoArr count];
    } else if (tableView.tag == 2) {
        return [sort3InfoArr count];
    } else {
        return [listInfoArr count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = nil;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    if (tableView.tag == 0) {
        if (indexPath.row == 0) {
            [cell.textLabel setText:@"일반수선"];
        } else {
            [cell.textLabel setText:@"판매시점수선"];
        }
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    } else if (tableView.tag == 1) {
        [cell.textLabel setText:[[sort2InfoArr objectAtIndex:indexPath.row] objectForKey:@"rpairsGoodsNm"]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    } else if (tableView.tag == 2) {
        [cell.textLabel setText:[[sort3InfoArr objectAtIndex:indexPath.row] objectForKey:@"rpairsSpeciesNm"]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    } else {
        [cell.textLabel setText:[[listInfoArr objectAtIndex:indexPath.row] objectForKey:@"rpairsItem"]];
    }
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
    NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (tableView.tag == 0) {
        NSString *url = @"";
        if (indexPath.row == 0) {
            sort1Str = @"Y";
            
            url = [NSString stringWithFormat:@"%@%@?brandCd=%@&rpairsDivCd=%@&accessToken=%@&timestamp=%0.f"
                   , KHOST, LISTREPAIRGOODS
                   , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                   , sort1Str
                   , [temp hexadecimalString]
                   , timeInMiliseconds];
            
        } else {
            sort1Str = @"N";
            
            url = [NSString stringWithFormat:@"%@%@?brandCd=%@&rpairsDivCd=%@&accessToken=%@&timestamp=%0.f"
                   , KHOST, LISTREPAIRGOODS
                   , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                   , sort1Str
                   , [temp hexadecimalString]
                   , timeInMiliseconds];
            
        }
        
        httpRequest *_httpRequest = [[httpRequest alloc] init];
        [_httpRequest setDelegate:self selector:@selector(sort2ListResult:)];
        [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    } else if (tableView.tag == 1) {
        NSString *url = [NSString stringWithFormat:@"%@%@?brandCd=%@&rpairsGoodsCd=%@&accessToken=%@&timestamp=%0.f"
                               , KHOST, LISTREPAIRSPECIES
                               , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                               , [[sort2InfoArr objectAtIndex:indexPath.row] objectForKey:@"rpairsGoodsCd"]
                               , [temp hexadecimalString]
                               , timeInMiliseconds];
        
        
        httpRequest *_httpRequest = [[httpRequest alloc] init];
        [_httpRequest setDelegate:self selector:@selector(sort3ListResult:)];
        [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    } else if (tableView.tag == 2) {
        NSString *url = [NSString stringWithFormat:@"%@%@?currentPage=%d&maxResults=%d&maxLinks=%d&brandCd=%@&shopCd=%@&rpairsDivCd=%@&rpairsGoodsCd=%@&rpairsSpeciesCd=%@&accessToken=%@&timestamp=%0.f"
                         , KHOST, PAGEDREPAIRINFO
                         , 1
                         , 10
                         , 10
                         , [[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"]
                         , [[NSUserDefaults standardUserDefaults] objectForKey:@"shopCd"]
                         , sort1Str
                         , [[sort3InfoArr objectAtIndex:indexPath.row] objectForKey:@"rpairsGoodsCd"]
                         , [[sort3InfoArr objectAtIndex:indexPath.row] objectForKey:@"rpairsSpeciesCd"]
                         , [temp hexadecimalString]
                         , timeInMiliseconds];
        
        
        httpRequest *_httpRequest = [[httpRequest alloc] init];
        [_httpRequest setDelegate:self selector:@selector(priceInfoListResult:)];
        [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
    } else {
        
    }
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    if (![cell selectionStyle] == UITableViewCellSeparatorStyleNone) {
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
//        for (UIButton *btn in btnArr) {
//            if (btn.selected) {
//                NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970] * 1000;
//                NSString *accessToken = [NSString stringWithFormat:@"%@@%0.f", [[NSString alloc] initWithData:[CommonUtil searchKeychainCopyMatching:@"uuid"] encoding:NSUTF8StringEncoding], timeInMiliseconds];
//                NSData *temp = [CommonUtil transform:kCCEncrypt data:[accessToken dataUsingEncoding:NSUTF8StringEncoding]];
//
//                NSString *url = @"";
//                if (btn.tag == 0) {
//                    url = [NSString stringWithFormat:@"%@%@?currentPage=%d&maxResults=%d&maxLinks=%d&searchNm=%@&areaCd=%@&accessToken=%@&timestamp=%0.f"
//                           , KHOST, PAGEDLISTSHOPINFO
//                           , (indexPath.row/cellNum)+1
//                           , cellNum
//                           , cellNum
//                           , [searchTxt urlEncodeUsingEncoding:NSUTF8StringEncoding]
//                           , @""
//                           , [temp hexadecimalString]
//                           , timeInMiliseconds];
//                } else {
//                    url = [NSString stringWithFormat:@"%@%@?currentPage=%d&maxResults=%d&maxLinks=%d&searchNm=%@&areaCd=%d&accessToken=%@&timestamp=%0.f"
//                           , KHOST, PAGEDLISTSHOPINFO
//                           , (indexPath.row/cellNum)+1
//                           , cellNum
//                           , cellNum
//                           , [searchTxt urlEncodeUsingEncoding:NSUTF8StringEncoding]
//                           , btn.tag
//                           , [temp hexadecimalString]
//                           , timeInMiliseconds];
//                }
//                
//                httpRequest *_httpRequest = [[httpRequest alloc] init];
//                [_httpRequest setDelegate:self selector:@selector(areaListResult:)];
//                [_httpRequest performSelector:@selector(requestUrl:withRequestType:) withObject:url withObject:@"GET"];
//            }
//        }
//    }
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
