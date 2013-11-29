//
//  MyClass.h
//  mPlusSign
//
//  Created by 정후 조 on 11. 5. 24..
//  Modified by yuil jung
//  Copyright 2011 코롱베니트. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 UpdateManager
 @brief 코오롱 아이캔 앱 다운로드 메니저
 */

@interface UpdateManager : NSObject {
    
}


+ (UpdateManager *) getInstance;        ///< 매니저 인스턴스 가져오기

-(BOOL) isNetworkReachable;     ///< 네트워크 상태 체크

- (NSString*)getBundleVersion;  ///< 앱(클라이언트) 버전 가져오기
- (NSString*)getNetVersion;     ///< 앱(서버단) 버전 가져오기
- (BOOL)isUpdateSalesForce;     ///< 업데이트가 이루어 졌는지 여부
- (void)goUpdateWebSite;        ///< 업데이트 페이지로 이동


- (BOOL)isInstallKolonApps;     ///< 앱 설치 여부 체크 (사용안함)
- (void)runKolonApps;           ///< 코오롱 아이캔 앱 실행 (사용안함)

@end
