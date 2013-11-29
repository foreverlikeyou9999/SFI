//
//  ProductListView.m
//  SalesForce
//
//  Created by 여성현 on 13. 8. 29..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "ProductListView.h"
#import "AppDelegate.h"
#import "ProductCell.h"
#import "UIImageView+WebCache.h"
#import "ProductDetailView.h"

#define FIX_STATUS_BAR  20
#define FIX_TITLE_BAR   44

#define PRODUCT_LIST_WIDTH          282
#define PRODUCT_LIST_HEIGHT         (1024-FIX_TITLE_BAR)

#define PRODUCT_LIST_HEADER_HEIGHT  40

#define PRODUCT_BTN_WIDTH           36
#define PRODUCT_BTN_HEIGHT          150

#define START_POS_X         (768-(PRODUCT_LIST_WIDTH+PRODUCT_BTN_WIDTH))
#define START_POS_HIDE_X    (768-PRODUCT_BTN_WIDTH)
#define START_POS_Y         FIX_TITLE_BAR
#define START_POS_HIDE_Y    (1024-PRODUCT_LIST_HEADER_HEIGHT-FIX_STATUS_BAR)

#define HEIGHT            [CommonUtil osVersion]

@implementation ProductListView
@synthesize headerBtn;
@synthesize productListView;
@synthesize listData;
@synthesize delegate;

#pragma mark - Life cycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(START_POS_HIDE_X, START_POS_Y, PRODUCT_LIST_WIDTH+PRODUCT_BTN_WIDTH, PRODUCT_LIST_HEIGHT)];
    if (self) {
#if F_USE_DUMMY
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pdflst" ofType:@"json"];
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
        
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        NSLog(@"%@", jsonDict);
        
        self.listData = [jsonDict objectForKey:@"results"];
#endif
        //[self setAlpha:0.8];
        
        // Initialization code
        isShow = false;
        
        // index btn
        self.headerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [headerBtn setFrame:CGRectMake(0, HEIGHT, PRODUCT_BTN_WIDTH, PRODUCT_BTN_HEIGHT)];
        [headerBtn setImage:[UIImage imageNamed:@"PDF_ProductListTitle"] forState:UIControlStateNormal];
        [headerBtn addTarget:self action:@selector(clickIndex) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:headerBtn];
        
        // create view
        self.productListView = [[UITableView alloc] initWithFrame:CGRectMake(PRODUCT_BTN_WIDTH, HEIGHT, PRODUCT_LIST_WIDTH, PRODUCT_LIST_HEIGHT - HEIGHT)];
        productListView.backgroundColor = [UIColor clearColor];
        [productListView setAlpha:0.8f];
        [productListView setDelegate:self];
        [productListView setDataSource:self];
        [productListView setBackgroundColor:RGBCOLOR(38, 38, 38)];
        [productListView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        // table header -- start
//        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PRODUCT_LIST_WIDTH, PRODUCT_LIST_HEADER_HEIGHT)];
//        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, PRODUCT_LIST_WIDTH, PRODUCT_LIST_HEADER_HEIGHT)];
//        bgImageView.image = [UIImage imageNamed:@"PDF_ProductListTitle"];
//        [headerView addSubview:bgImageView];
//        productListView.tableHeaderView = headerView;
        // table header -- end
        
        [self addSubview:productListView];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProductListCell";
//    ProductCell *cell = (ProductCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    ProductCell *cell = nil;
    
    if (cell == nil) {
        cell = [[ProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSDictionary *item = [listData objectAtIndex:indexPath.row];
    
    if(item)
    {
        NSString *imgURL = [item objectForKey:@"thumbUrl"];
        NSString *productName = [item objectForKey:@"prductNm"];
        NSString *productCd = [item objectForKey:@"prductCd"];
        NSString *price = [CommonUtil makeComma:[item objectForKey:@"copr"]];
        NSString *amount = [CommonUtil makeComma:[item objectForKey:@"jegoTotqy"]];
        NSString *amountLbl = [NSString stringWithFormat:@"%@원 / 수량 %@", price, amount];
        
        UIView *noImageBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        [noImageBg setBackgroundColor:[UIColor clearColor]];
        UIImageView *noImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_NoImage"]];
        [noImageView setFrame:CGRectMake(40 - noImageView.image.size.width/2, 40 - noImageView.image.size.height/2, noImageView.image.size.width, noImageView.image.size.height)];
        [noImageBg addSubview:noImageView];

        [cell.thumbnnailView setImageWithURL:[NSURL URLWithString:imgURL]
                            placeholderImage:[CommonUtil imageWithView:noImageBg]];
        
        [cell.productNameLbl setText:productName];
        [cell.productCdLbl setText:productCd];
        [cell.amountLbl setText:amountLbl];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * productId = [[self.listData objectAtIndex:indexPath.row] objectForKey:@"prductCd"];
    [delegate productListView:self didSelectedID:productId];
}


#pragma mark - IBAction Method
- (void) clickIndex {
    if (isShow) {
        isShow = false;
        [self hideProductList];
    }
    else {
        isShow = true;
        [self showProductList];
    }
}

#pragma mark - private method
- (void)hideProductList
{   
    [UIView animateWithDuration:0.5 delay:0.0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void)
     {
         self.frame = CGRectMake(START_POS_HIDE_X, START_POS_Y, PRODUCT_LIST_WIDTH+PRODUCT_BTN_WIDTH, PRODUCT_LIST_HEIGHT);
         
     }
                     completion:^(BOOL finished)
     {
         [headerBtn setImage:[UIImage imageNamed:@"PDF_ProductListTitle"] forState:UIControlStateNormal];
     }
     ];
    
}

- (void)showProductList
{
    [UIView animateWithDuration:0.5 delay:0.0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void)
     {
         self.frame = CGRectMake(START_POS_X, START_POS_Y, PRODUCT_LIST_WIDTH+PRODUCT_BTN_WIDTH, PRODUCT_LIST_HEIGHT);
         
     }
                     completion:^(BOOL finished)
     {
         [headerBtn setImage:[UIImage imageNamed:@"PDF_ProductListTitle02"] forState:UIControlStateNormal];
     }
     ];
}

- (void)hideBar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if (self.hidden == NO)
	{
        // hide시 리스트도 숨김
        isShow = false;
        [self hideProductList];
        
		[UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             self.hidden = YES;
         }
         ];
	}
}

- (void)showBar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if (self.hidden == YES)
	{
        
		[UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.hidden = NO;
             self.alpha = 1.0f;
         }
                         completion:NULL
         ];
	}
}
@end
