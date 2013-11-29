//
//  Define.h
//  kNewsletter
//
//  Created by 정후 조 on 11. 11. 1..
//  Copyright 2011 코롱베니트. All rights reserved.
//

//#ifdef DEBUG
//#else
//    #define  NSLog
//#endif

//#define  NSLog

enum MAIN_VIEWTYPE { BOOKCASE=0, COVERFLOW=1 };

enum CONFIG_TYPE {CONFIG =0,CONFIGYEAR =1,CONFIGMONTH =2};

#define DOCUMENTSPATH				[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#pragma mark Constants

#define DEMO_VIEW_CONTROLLER_PUSH FALSE

#define IMAGE_FOLDERNAME   @"image"
#define PDF_FOLDERNAME     @"pdf"

#define AUTO_ROTATE        YES
#define USE_MAIN_PAGEBAR   FALSE

#define IS_IPHONE_5 [[UIScreen mainScreen] bounds].size.height == 568 || [[UIScreen mainScreen] bounds].size.width == 568 ? YES : NO

