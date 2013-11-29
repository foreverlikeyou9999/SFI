//
//  ThumbnailView.h
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 16..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import <UIKit/UIKit.h>
//

@class ThumbnailView;

@protocol ThumbnanilViewDelegate <NSObject>

- (void)clickedThumbnail:(ThumbnailView*)view;
- (void)thumbnailTouchOnOff:(NSString *)onoff;

@end

@interface ThumbnailView : UIView <UIAlertViewDelegate> {
    NSRange selectorRange;
}

@property (nonatomic, strong) UIButton *thumbnailImgBtn;
@property (nonatomic, strong) UIImageView *tagView;
@property (nonatomic, strong) UILabel *tagName;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) NSDictionary *thumbnailDic;   // 썸네일 정보
@property (nonatomic, strong) NSString *subDir;
@property (nonatomic, strong) NSString *currentScrinTyCd;
@property (nonatomic, strong) UIImageView *pdfDownloadImg;
@property int thumbTag;
@property int selectedTag;

- (void)setDelegate:(id)aTarget selector:(SEL)aSelector;
//- (void)createComponents;
- (void)dnThumbImg:(NSString *)directory;
- (void)dnCntImg:(NSString *)directory;
- (void)typeSort;

@end


