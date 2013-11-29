//
//  ProductCell.h
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 21..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductCell : UITableViewCell {

}

@property (nonatomic, strong) UIImageView *thumbnnailView;
@property (nonatomic, strong) UILabel *productCdLbl;
@property (nonatomic, strong) UILabel *productNameLbl;
@property (nonatomic, strong) UILabel *amountLbl;

@end
