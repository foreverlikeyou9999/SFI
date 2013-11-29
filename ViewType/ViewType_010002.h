//
//  ViewType_010002.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 9. 1..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>
//

@interface ViewType_010002 : UIView

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

- (void)setDelegate:(id)aTarget selector:(SEL)aSelector;
- (void)clickPDFView;

@end
