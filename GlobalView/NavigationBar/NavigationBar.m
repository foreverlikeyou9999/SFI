//
//  NavigationBar.m
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 28..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "NavigationBar.h"
//
#import "AppDelegate.h"

@implementation NavigationBar
//@synthesize target;
@synthesize naviTitle = _naviTitle;
@synthesize delegate;
//@synthesize loadingView = _loadingView;

#define HEIGHT            [CommonUtil osVersion]

- (id)initWithFrame:(CGRect)frame
{
    UIImage *naviBg = [UIImage imageNamed:@"IM_TitleBarBG"];
    frame = CGRectMake(0, 0, naviBg.size.width, naviBg.size.height + HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        menuBtnArr = [[NSMutableArray alloc] init];
        
        UIView *bg = [[UIView alloc] initWithFrame:frame];
        [bg setBackgroundColor:[UIColor blackColor]];
        [self addSubview:bg];
        
//        self.loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20)];
//        [self addSubview:self.loadingView];
    }
    return self;
}

- (void)createComponents {
    if ([self.subviews count] > 1) {
        [[self.subviews objectAtIndex:1] removeFromSuperview];
    }
    
    menuList = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"mainmenulist"]];
    brandList = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"brandList"]];
    
    UIImageView *titleBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_TitleBarBG"]];
    [titleBarView setFrame:CGRectMake(0, HEIGHT, titleBarView.image.size.width, titleBarView.image.size.height)];
    [titleBarView setUserInteractionEnabled:YES];
    [self addSubview:titleBarView];
    
    UIButton *btn;
    UILabel *lbl;
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"IM_Sub_Btn_Menu_N"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"IM_Sub_Btn_Menu_O"] forState:UIControlStateSelected];
    [btn setFrame:CGRectMake(0, 0, 44, 44)];
    [btn setSelected:NO];
    [btn addTarget:self action:@selector(menuSelect:) forControlEvents:UIControlEventTouchUpInside];
    [titleBarView addSubview:btn];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 500, 44)];
    [lbl setText:_naviTitle];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setFont:[UIFont fontWithName:@"Roboto-Bold" size:20.0f]];
    [lbl setShadowColor:[UIColor blackColor]];
    [lbl setShadowOffset:CGSizeMake(1, 0)];
    [titleBarView addSubview:lbl];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"IM_Sub_Btn_Home_N"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - (44*3), 0, 44, 44)];
    [btn addTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
    [titleBarView addSubview:btn];

    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"IM_Sub_Btn_Brand_N"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"IM_Sub_Btn_Brand_O"] forState:UIControlStateSelected];
    [btn setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - (44*2), 0, 44, 44)];
    [btn addTarget:self action:@selector(brandSelect:) forControlEvents:UIControlEventTouchUpInside];
    [titleBarView addSubview:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"IM_Sub_Btn_Prev_N"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 44, 0, 44, 44)];
    [btn addTarget:self action:@selector(goPrev) forControlEvents:UIControlEventTouchUpInside];
    [titleBarView addSubview:btn];
    
    brandSelectView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Brand_BG"]];
    [brandSelectView setUserInteractionEnabled:YES];
    [brandSelectView setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - brandSelectView.image.size.width, 44 + HEIGHT, brandSelectView.image.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    [brandSelectView setAlpha:0];
    [self addSubview:brandSelectView];
    
    UIImageView *brandTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Brand_TitleBar02"]];
    [brandTop setFrame:CGRectMake(0, -4, brandTop.image.size.width, brandTop.image.size.height)];
    [brandSelectView addSubview:brandTop];

    menuSelectView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_GNB_BG"]];
    [menuSelectView setUserInteractionEnabled:YES];
    [menuSelectView setFrame:CGRectMake(0, 44 + HEIGHT, menuSelectView.image.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    [menuSelectView setAlpha:0];
    [self addSubview:menuSelectView];
    
    UIImageView *menuTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_GNB_Top"]];
    [menuTop setFrame:CGRectMake(0, -4, menuTop.image.size.width, menuTop.image.size.height)];
    [menuSelectView addSubview:menuTop];
}

- (void)createSubCntntsComponent {
    if ([self.subviews count] > 1) {
        [[self.subviews objectAtIndex:1] removeFromSuperview];
    }
    
    UIImageView *titleBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_TitleBarBG"]];
    [titleBarView setFrame:CGRectMake(0, HEIGHT, titleBarView.image.size.width, titleBarView.image.size.height)];
    [titleBarView setUserInteractionEnabled:YES];
    [self addSubview:titleBarView];
    
    UIButton *btn;
    UILabel *lbl;
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"PDF_Btn_Close_N"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 44, 0, 44, 44)];
    [btn addTarget:self action:@selector(goPrev) forControlEvents:UIControlEventTouchUpInside];
    [titleBarView addSubview:btn];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(titleBarView.image.size.width/2 - 100, 0, 200, 44)];
    [lbl setText:_naviTitle];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setShadowColor:[UIColor blackColor]];
    [lbl setShadowOffset:CGSizeMake(0, 1)];
    [lbl setFont:[UIFont fontWithName:@"Roboto-Regular" size:20.0f]];
    [titleBarView addSubview:lbl];
}

- (void)callLogin {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SalseForce" message:@"로그아웃 하시겠습니까?" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
    [alertView setTag:0];
    [alertView show];
}

- (void)brandSelect:(id)sender {
    if (brandSelectView.alpha == 0) {
        [((UIButton *)sender) setSelected:YES];
        
        UIScrollView *_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 28, brandSelectView.image.size.width, 928)];//메인메뉴
        [_scrollView setDelegate:self];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setContentSize:CGSizeMake(brandSelectView.image.size.width, 928)];
        [_scrollView setBackgroundColor:[UIColor clearColor]];
        [brandSelectView addSubview:_scrollView];
        
        UIButton *btn;
        
        for (int i = 0; i < [brandList count]; i++) {
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTag:i];
            [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_small", [[brandList objectAtIndex:i] objectForKey:@"brandCd"]]] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"IM_Brand_NormalBG"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"IM_Brand_SelectBG"] forState:UIControlStateSelected];
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"brandcd"] isEqualToString:[[brandList objectAtIndex:i] objectForKey:@"brandCd"]]) {
                [btn setSelected:YES];
                [btn setUserInteractionEnabled:NO];
            } else {
                [btn setSelected:NO];
                [btn setUserInteractionEnabled:YES];
            }
            [btn setFrame:CGRectMake(0, i * 42, btn.imageView.image.size.width, btn.imageView.image.size.height)];
            [_scrollView addSubview:btn];
        }
        
        [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [UIView animateWithDuration:0.5f animations:^{
            [brandSelectView setAlpha:1.0f];
        }];
    } else {
        [((UIButton *)sender) setSelected:NO];
        
        UIImage *naviBg = [UIImage imageNamed:@"IM_TitleBarBG"];
        [self setFrame:CGRectMake(0, 0, naviBg.size.width, naviBg.size.height)];
        [UIView animateWithDuration:0.5f animations:^{
            [brandSelectView setAlpha:0];
        }];
    }
}

- (void)menuSelect:(id)sender {
    if (menuSelectView.alpha == 0) {
        [((UIButton *)sender) setSelected:YES];
        
        UIImageView *icon;
        UILabel *btnLbl;
        UIButton *btn;
        
        UIScrollView *_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(3, 45, 146, [UIScreen mainScreen].bounds.size.height - 64 - 45)];//메인메뉴
        [_scrollView setDelegate:self];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setBackgroundColor:[UIColor clearColor]];
        [menuSelectView addSubview:_scrollView];
        
        for (int i = 0; i < [menuList count]; i++) {
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTag:i];
            [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"IM_Main_Menu0%d", (i % 4) + 1]] forState:UIControlStateNormal];
            [btn setFrame:CGRectMake(0, i * 148, btn.imageView.image.size.width, btn.imageView.image.size.height)];
            [btn setTitle:[[menuList objectAtIndex:i] objectForKey:@"ctgryDc"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(enterMenu:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:btn];
            
            icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"IM_Main_Icon0%d", (i % 4) + 1]]];
            [icon setFrame:CGRectMake(146/2 - icon.image.size.width/2, 146/2 - icon.image.size.height, icon.image.size.width, icon.image.size.height)];
            [btn addSubview:icon];
            
            btnLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 104, 146, 22)];
            [btnLbl setBackgroundColor:[UIColor clearColor]];
            [btnLbl setTextColor:[UIColor whiteColor]];
            [btnLbl setText:[[menuList objectAtIndex:i] objectForKey:@"ctgryDc"]];
            [btnLbl setFont:[UIFont fontWithName:@"Roboto-Medium" size:18.0f]];
            [btnLbl setShadowColor:[UIColor blackColor]];
            [btnLbl setShadowOffset:CGSizeMake(1, 0)];
            [btnLbl setTextAlignment:NSTextAlignmentCenter];
            [btn addSubview:btnLbl];
            
            [menuBtnArr addObject:btn];
        }
        
        NSArray *fixMenuList = [[NSArray alloc] initWithObjects:@"수선정보", @"매장정보", @"상품조회", @"멤버쉽 가입/조회", @"매장 STOP제", @"매장 CHECKLIST", nil];
        
        for (int i = [menuList count]; i < [menuList count] + [fixMenuList count]; i++) {
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTag:i];
            [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"IM_Main_Menu0%d", (i % 4) + 1]] forState:UIControlStateNormal];
            [btn setFrame:CGRectMake(0, i * 148, btn.imageView.image.size.width, btn.imageView.image.size.height)];
            [btn addTarget:self action:@selector(enterFixMenu:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:btn];
            
            icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"IM_Main_Icon0%d", (i % 4) + 1]]];
            [icon setFrame:CGRectMake(146/2 - icon.image.size.width/2, 146/2 - icon.image.size.height, icon.image.size.width, icon.image.size.height)];
            [btn addSubview:icon];
            
            btnLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 104, 146, 22)];
            [btnLbl setBackgroundColor:[UIColor clearColor]];
            [btnLbl setTextColor:[UIColor whiteColor]];
            [btnLbl setText:[fixMenuList objectAtIndex:i - [menuList count]]];
            [btnLbl setFont:[UIFont fontWithName:@"Roboto-Medium" size:18.0f]];
            [btnLbl setShadowColor:[UIColor blackColor]];
            [btnLbl setShadowOffset:CGSizeMake(1, 0)];
            [btnLbl setTextAlignment:NSTextAlignmentCenter];
            [btn addSubview:btnLbl];
            
            [menuBtnArr addObject:btn];
        }
        
        [_scrollView setContentSize:CGSizeMake(146, 148 * ([menuList count] + [fixMenuList count]))];
        
        [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [UIView animateWithDuration:0.5f animations:^{
            [menuSelectView setAlpha:1.0f];
        }];
        
        for (UIView *view in menuBtnArr) {
            if (((UIButton *)view).tag == [[GlobalValue sharedSingleton] menuIndex]) {
                [((UIButton *)view) setSelected:YES];
                [((UIButton *)view) setUserInteractionEnabled:NO];
            } else {
                [((UIButton *)view) setSelected:NO];
                [((UIButton *)view) setUserInteractionEnabled:YES];
            }
        }
        
    } else {
        [((UIButton *)sender) setSelected:NO];
        
        UIImage *naviBg = [UIImage imageNamed:@"IM_TitleBarBG"];
        [self setFrame:CGRectMake(0, 0, naviBg.size.width, naviBg.size.height)];
        [UIView animateWithDuration:0.5f animations:^{
            [menuSelectView setAlpha:0];
        } completion:^(BOOL finished) {
            for (UIView *view in menuSelectView.subviews) {
                if ([view isKindOfClass:[UIScrollView class]]) {
                    [view removeFromSuperview];
                }
            }
        }];
    }
}

- (void)menuAllClose {
    [menuSelectView setAlpha:0];
    [brandSelectView setAlpha:0];
    
    UIImage *naviBg = [UIImage imageNamed:@"IM_TitleBarBG"];
    [self setFrame:CGRectMake(0, 0, naviBg.size.width, naviBg.size.height)];
}

- (void)enterMenu:(id)sender {
    [[GlobalValue sharedSingleton] setMenuIndex:((UIButton *)sender).tag];
    
    for (UIView *view in menuBtnArr) {
        if (((UIButton *)view).tag == ((UIButton *)sender).tag) {
            [((UIButton *)view) setSelected:YES];
            [((UIButton *)view) setUserInteractionEnabled:NO];
        } else {
            [((UIButton *)view) setSelected:NO];
            [((UIButton *)view) setUserInteractionEnabled:YES];
        }
    }
    
    [delegate clickedMobileMenuBtnAtIndex:((UIButton *)sender).tag];
}

- (void)enterFixMenu:(id)sender {
    [[GlobalValue sharedSingleton] setMenuIndex:((UIButton *)sender).tag];
    
    for (UIView *view in menuBtnArr) {
        if (((UIButton *)view).tag == ((UIButton *)sender).tag) {
            [((UIButton *)view) setSelected:YES];
            [((UIButton *)view) setUserInteractionEnabled:NO];
        } else {
            [((UIButton *)view) setSelected:NO];
            [((UIButton *)view) setUserInteractionEnabled:YES];
        }
    }
    
    [delegate clickedFixedMenuBtnAtIndex:((UIButton *)sender).tag];
}

- (void)goPrev {
    [self menuAllClose];
    [delegate goPrev];
}

- (void)goHome {
    [self menuAllClose];
    [delegate goHome:self];
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
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    [cell.textLabel setText:[NSString stringWithFormat:@"%d", indexPath.row]];
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    
//    if (indexPath.row%2 == 0) {
//        [cell.thumbnnailView setImage:[UIImage imageNamed:@"IM_Img_ThumbSmall001"]];
//        [cell.thumbnnailView setFrame:CGRectMake(0, 0, cell.thumbnnailView.image.size.width, cell.thumbnnailView.image.size.height)];
//    } else {
//        [cell.thumbnnailView setImage:[UIImage imageNamed:@"IM_Img_ThumbSmall002"]];
//        [cell.thumbnnailView setFrame:CGRectMake(0, 0, cell.thumbnnailView.image.size.width, cell.thumbnnailView.image.size.height)];
//    }
//    
//    [cell.productNameLbl setText:@"EAGLE 프린트 라운드 티셔츠"];
//    [cell.amountLbl setText:@"52,000 원"];
//    
//    UIButton *btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//    [btn setTag:indexPath.row];
//    [btn setImage:[UIImage imageNamed:@"IM_Btn_ProductDetail"] forState:UIControlStateNormal];
//    [btn setFrame:CGRectMake(100, 50, btn.imageView.image.size.width, btn.imageView.image.size.height)];
//    [btn addTarget:self action:@selector(detailProduct:) forControlEvents:UIControlEventTouchUpInside];
//    [cell addSubview:btn];
//    [btn release];
    
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
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Navigation logic may go here. Create and push another view controller.
    //    if (indexPath.row == 0) {
    //        ADGalleryViewController *detailViewController = [[ADGalleryViewController alloc] init];
    // ...
    // Pass the selected object to the new view controller.
    //        [self.navigationController pushViewController:detailViewController animated:YES];
    //        [detailViewController release];
    //    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        if (buttonIndex != 0) {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app logout:@"yes"];
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
