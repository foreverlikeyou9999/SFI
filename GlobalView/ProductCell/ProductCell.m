//
//  ProductCell.m
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 21..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "ProductCell.h"

@implementation ProductCell
@synthesize thumbnnailView = _thumbnnailView;
@synthesize productNameLbl = _productNameLbl;
@synthesize productCdLbl = _productCdLbl;
@synthesize amountLbl = _amountLbl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImageView *cellBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_ProductLayerBG"]];
        [cellBg setUserInteractionEnabled:YES];
        [cellBg setFrame:CGRectMake(0, 0, cellBg.image.size.width, cellBg.image.size.height)];
        [self addSubview:cellBg];

        self.thumbnnailView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 80, 80)];
        
        self.productNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(95, 8, 150, 12)];
        [self.productNameLbl setBackgroundColor:[UIColor clearColor]];
        [self.productNameLbl setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [self.productNameLbl setTextColor:[UIColor whiteColor]];
        [self.productNameLbl setTextAlignment:NSTextAlignmentLeft];
        
        self.productCdLbl = [[UILabel alloc] initWithFrame:CGRectMake(95, 28, 150, 12)];
        [self.productCdLbl setBackgroundColor:[UIColor clearColor]];
        [self.productCdLbl setFont:[UIFont systemFontOfSize:12.0f]];
        [self.productCdLbl setTextColor:[UIColor colorWithRed:137/255.0f green:189/255.0f blue:80/255.0f alpha:1]];
        [self.productCdLbl setTextAlignment:NSTextAlignmentLeft];

        self.amountLbl = [[UILabel alloc] initWithFrame:CGRectMake(95, 48, 150, 12)];
        [self.amountLbl setBackgroundColor:[UIColor clearColor]];
        [self.amountLbl setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [self.amountLbl setTextColor:[UIColor whiteColor]];
        [self.amountLbl setTextAlignment:NSTextAlignmentLeft];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self addSubview:self.thumbnnailView];
    [self addSubview:self.productNameLbl];
    [self addSubview:self.productCdLbl];
    [self addSubview:self.amountLbl];
    
    UIImageView *productBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IM_Sub_ProductBox"]];
    [productBox setFrame:CGRectMake(5, 5, productBox.image.size.width, productBox.image.size.height)];
    [self addSubview:productBox];
}

@end
