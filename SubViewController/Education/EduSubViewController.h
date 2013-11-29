//
//  EduSubViewController.h
//  SalesForce
//
//  Created by Wonpyo Hong on 13. 10. 4..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
//
#import "NavigationBar.h"

@protocol EduSubViewControllerDelegate <NSObject>

- (void)clickedButtonAtIndex:(NSInteger)buttonIndex;
//- (void)menuIndexConnect:(NSInteger)index;

@end

@interface EduSubViewController : UIViewController <NavigationBarDelegate, UITextViewDelegate> {
    id <EduSubViewControllerDelegate> __weak delegate;
    
    NSMutableArray *menuList;
    NSMutableArray *btnArr;
    
    NavigationBar *naviBar;
    UIScrollView *menuScroll;
    UIImageView *cntBgView;
    MPMoviePlayerController *moviePlayer;
    
    BOOL videoFullScreen;
}

@property (nonatomic, weak, readwrite) id <EduSubViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *thumbnailInfo;
@property int currentCtgryMenuIndex;

@end
