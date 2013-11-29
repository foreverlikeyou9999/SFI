//
//  CustomCell.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 8. 22..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell {
    NSMutableArray *columns;
}

- (void)addColumn:(CGFloat)position;

@end
