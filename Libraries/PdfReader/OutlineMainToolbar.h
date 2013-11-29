//
//	OutlineMainToolbar.h
//	Reader v2.4.0
//
//	Created by Junghu Cho on 2011-09-01.
//
//

#import <UIKit/UIKit.h>

#import "UIXToolbarView.h"

@class OutlineMainToolbar;

@protocol OutlineMainToolbarDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInToolbar:(OutlineMainToolbar *)toolbar doneButton:(UIButton *)button;

- (void)tappedInToolbar:(OutlineMainToolbar *)toolbar showControl:(NSInteger)control;

@end

@interface OutlineMainToolbar : UIXToolbarView
{
@private // Instance variables
}

@property (nonatomic, assign, readwrite) id <OutlineMainToolbarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;

@end
