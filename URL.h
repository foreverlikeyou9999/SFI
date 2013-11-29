//
//  URL.h
//  kolon_project
//
//  Created by Wonpyo Hong on 13. 8. 19..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

//#define KHOST           @"http://203.225.253.171:8080"
//#define KHOST           @"http://msalesforce.kolon.com"
#define KHOST           @"http://203.225.255.146:8081/BenitFnc"


//#define LISTBASECNTNTSMENU    @"/rest/cntntsmgmt/listBaseCntntsMenu"       //GET, 기본 컨텐츠메뉴 목록조회
#define LISTCNTNTSMENU          @"/rest/cntntsmgmt/listCntntsMenu"              //GET, 전체 컨텐츠메뉴 목록조회
#define ADDLISTMENUHIST        @"/rest/devicemgmt/addListMenuHist"           //POST, 메뉴 조회 리스트 히스토리 등록
#define ADDMENUHIST               @"/rest/devicemgmt/addMenuHist"                //POST, 메뉴 조회 히스토리 등록
#define DWLDTHUMBFILE           @"/rest/cntntsmgmt/dwldThumbFile"             //GET, 썸네일 파일 다운로드
#define LISTCTGYINFODATA        @"/rest/cntntsmgmt/listCtgryInfoData"           //GET, 카테고리 목록조회

//Login
#define GETHEDOFCLOGININFO         @"/rest/loginaction/getHedOfcLoginInfo"  //GET, 본사로그인
#define GETSHOPLOGININFO        @"/rest/loginaction/getShopLoginInfo"      //GET, 매장로그인

//최초 디바이스 등록
#define ADDSHOPDEVICEINFO     @"/rest/devicemgmt/addShopDeviceInfo"       //POST, 매장 최초 디바이스 등록
#define ADDHEDOFCDEVICEINFO     @"/rest/devicemgmt/addHedOfcDeviceInfo"    //POST, 본사 최초 디바이스 등록
#define MODIFYFADEVICEINFO      @"/rest/devicemgmt/modifyFaDeviceInfo"      //PUT, 매장 최초등록시 FA 정보수정

// 메인
#define DWLDMAINLOGOFILE      @"/rest/cntntsmgmt/dwldMainLogoFile"        //GET, 메인 로고파일 다운로드
#define GETMAININFO         @"/rest/cntntsmgmt/getMainInfo"             //GET, 메인 정보 조회
#define DWLDMAINCNTNTSFILE    @"/rest/cntntsmgmt/dwldMainCntntsFile"        //GET, 메인 파일 다운로드

// 서버 공통코드 정의
#define DOWNLOAD_FLAG_YES   @"011001"
#define DOWNLOAD_FLAG_NO    @"011002"

// 교육관련
#define LISTEDCMENU         @"/rest/cntntsmgmt/listEdcMenu"             //GET, 교육 컨텐츠메뉴 목록조회
#define ADDLISTEDCHISTINFO      @"/rest/devicemgmt/addListEdcHistInfo"       //POST, 교육자료 조회 리스트 히스토리 등록
#define ADDEDCHISTINFO       @"/rest/devicemgmt/addEdcHistInfo"          //POST, 교육자료 조회 히스토리 등록

// 컨텐츠 관련
#define GETCNTNTSINFO           @"/rest/cntntsmgmt/getCntntsInfo"           //GET, 콘텐츠 정보 조회
#define GETCNTNTSINFOWITHPRDUCT @"/rest/cntntsmgmt/getCntntsInfoWithPrduct"   //GET, 콘텐츠 정보 조회(제품목록 포함)
#define LISTCNTNTSMENU          @"/rest/cntntsmgmt/listCntntsMenu"          //GET, 콘텐츠 메뉴목록 조회(전체메뉴)
#define DWLDCNTNTSFILE          @"/rest/cntntsmgmt/dwldCntntsFile"          //GET, 콘텐츠 파일 다운로드
#define PAGEDLISTCNTNTSINFO       @"/rest/cntntsmgmt/pagedListCntntsInfo"     //GET, 콘텐츠 페이징 목록조회
#define PAGEDLISTALLCNTNTSINFO      @"/rest/cntntsmgmt/pagedListAllCntntsInfo"     //GET, 콘텐츠 페이지 전체 목록조회

// 제품 관련
#define LISTPRODUCT         @"/rest/shopinfo/listPrduct"               //GET, 제품 목록 조회
#define GETPRODUCT          @"/rest/shopinfo/getPrduct"              //GET, 제품 정보조회

// 매장정보 관련
#define LISTAREA            @"/rest/shopinfo/listArea"              //GET, 매장 지역 목록
#define PAGEDLISTSHOPINFO        @"/rest/shopinfo/pagedListShopInfo"     //GET, 매장 지역 상세

// 수선정보 관련
#define LISTREPAIRGOODS         @"/rest/repairinfo/listRepairGoods"         //GET, 수선 상품 조회
#define LISTREPAIRSPECIES       @"/rest/repairinfo/listRepairSpecies"       //GET, 수선 품종 조회
#define PAGEDREPAIRINFO         @"/rest/repairinfo/pagedRepairInfo"         //GET, 수선 단가표 리스트 조회
#define LISTREPAIRIMAGESPECIES      @"/rest/repairinfo/listRepairImageSpecies"      //GET, 전후 이미지 품종 조회
#define LISTREPAIRIMAGEITEM     @"/rest/repairinfo/listRepairImageItem"         //GET, 전후 이미지 항목 조회
#define PAGEDREPAIRIMAGELIST    @"/rest/repairinfo/pagedRepairImageList"        //GET, 전후 이미지 리스트 조회