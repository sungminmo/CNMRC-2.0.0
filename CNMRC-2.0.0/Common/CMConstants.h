//
//  CMConstants.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 6. 25..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

// 메뉴 타입.
typedef NS_ENUM(NSInteger, CMMenuType) {
    CMMenuTypePrevious = 0,
    CMMenuTypeGreen,
    CMMenuTypeYellow,
    CMMenuTypeOut,
    CMMenuTypeCircle,
    CMMenuTypeOnOff,
    CMMenuTypeHome,
    CMMenuTypeVOD,
    CMMenuTypeChannel,
    CMMenuTypeSearch,
    CMMenuTypeSettings,
    CMMenuTypeSetProduct,
    CMMenuTypeAuthAdult
};

// 네이버 검색API 키.
#define NAVER_SEARCH_API_KEY @"31729f057816ab77e60e685b29260460"

// 네이버 검색API(웹문서) 서버 URL.
#define NAVER_SEARCH_API_SERVER_URL @"http://openapi.naver.com/search?"

// C&M SMApplicationSever openAPI 서버 IP.
#define CNM_OPEN_API_SERVER_URL @"http://58.143.243.91/SMApplicationServer/"

// C&M SMApplicationSever openAPI 프로토콜 버전.
#define CNM_OPEN_API_VERSION @"SmartMobile_v1.0.0"

// 테스트용 터미널Key.
#define CNM_TEST_TERMINAL_KEY @"MjAxMS0wNC0xNl8yMTk0NDY4Nl9Dbk1UZXN0QXBwXyAg"

// 뷰 컨트롤러 닫기 노티피케이션.
#define CLOSE_VIEW_CONTROLLER @"clsoeViewController"

// 기본 정보(지역코드, 상품코드)
#define CNM_DEFAULT_AREA_CODE @"12"
#define CNM_DEFAULT_PRODUCT_CODE @"12"

// 3.5', 4'에 따른 컨트롤 패드의 프레임.
#define CM_PAD_FRAME CGRectMake(0.0, 55.0, 320.0, 270.0)
#define CM_PAD_FIVE_FRAME CGRectMake(0.0, 55.0, 320.0, 355.0)
#define CM_PAD_SEVEN_FRAME CGRectMake(0.0, 75.0, 320.0, 270.0)
#define CM_PAD_SEVEN_FIVE_FRAME CGRectMake(0.0, 75.0, 320.0, 355.0)

// ----------------------------------------------------------------------------------
// 미러TV 에러 메시지.
// ----------------------------------------------------------------------------------

#define MIRRORTV_ERROR_MSG_INTRO_2 @"해당 채널은 미러TV가 지원되지 않습니다.\n※ 지상파 등 일부 채널은 지원되지 않습니다.\n※ 채널 전환 시, 화면 전송이 지연될 수 있습니다."
#define MIRRORTV_ERROR_MSG_INTRO @"지상파 채널등 일부 채널은\n미러TV가 지원되지 않습니다."
#define MIRRORTV_ERROR_MSG_VOD @"TV는 채널 상태일 경우에만 미러TV가 실행됩니다."
#define MIRRORTV_ERROR_MSG_OTHERS @"TV가 채널 상태일 경우에만 미러TV가 실행됩니다."
#define MIRRORTV_ERROR_MSG_BLOCKING_CHANNEL @"셋탑박스에서 성인인증 또는 구매 완료 후\n 다시 이용해 주세요."
#define MIRRORTV_ERROR_MSG_STANBY @"셋탑박스 전원이 꺼져있습니다.\n전원을 켜신 후 이용바랍니다."
#define MIRRORTV_ERROR @"미러TV 영상이 지연되고 있습니다.\n잠시 후 다시 이용해 주십시오."

// ----------------------------------------------------------------------------------
// C&M SMApplicationSever openAPI Parameter Key.
// ----------------------------------------------------------------------------------

// version
#define CNM_OPEN_API_VERSION_KEY @"version"

// terminalID
#define CNM_OPEN_API_TERMINAL_ID_KEY @"terminalId"

// terminalKey
#define CNM_OPEN_API_TERMINAL_KEY_KEY @"terminalKey"

// transactionID
#define CNM_OPEN_API_TRANSACTION_ID_KEY @"transactionId"

// areaCode
#define CNM_OPEN_API_AREA_CODE_KEY @"aredCode"

// produceCode
#define CNM_OPEN_API_PRODUCE_CODE_KEY @"produceCode"

// resultCode
#define CNM_OPEN_API_RESULT_CODE_KEY @"resultCode"

// resultCode 100(성공)
#define CNM_OPEN_API_RESULT_CODE_SUCCESS_KEY @"100"

// 사용자 정보.
#define CNM_OPEN_API_USER_INFO_KEY @"UserInfo"

// errorString
#define CNM_OPEN_API_RESULT_ERROR_STRING_KEY @"errorString"
#define CNM_OPEN_API_RESULT_ERR_STRING_KEY @"errString"

// ----------------------------------------------------------------------------------
// C&M SMApplicationSever openAPI 인터페이스.
// * Record 관련 인터페이스만 제외됨(TODO: 사용 유무 확인할 것!)
// ----------------------------------------------------------------------------------

// 1. Authenticate
// AuthenticateClient.
#define CNM_OPEN_API_INTERFACE_AuthenticateClient @"AuthenticateClient"

// GetAppVersionInfo
#define CNM_OPEN_API_INTERFACE_GetAppVersionInfo @"GetAppVersionInfo"

// GetAppContentVersion
#define CNM_OPEN_API_INTERFACE_GetAppContentVersion @"GetAppContentVersion"

// ClientSetTopBoxRegist
#define CNM_OPEN_API_INTERFACE_ClientSetTopBoxRegist @"ClientSetTopBoxRegist"

// CheckRegistUser
#define CNM_OPEN_API_INTERFACE_CheckRegistUser @"CheckRegistUser"

// AuthenticateAdult
#define CNM_OPEN_API_INTERFACE_AuthenticateAdult @"AuthenticateAdult"

// RequestAuthCode
#define CNM_OPEN_API_INTERFACE_RequestAuthCode @"RequestAuthCode"

// 2. Channel
// GetChannelGenre
#define CNM_OPEN_API_INTERFACE_GetChannelGenre @"GetChannelGenre"

// GetChannelProduct
#define CNM_OPEN_API_INTERFACE_GetChannelProduct @"GetChannelProduct"

// GetChannelArea
#define CNM_OPEN_API_INTERFACE_GetChannelArea @"GetChannelArea"

// GetChannelList
#define CNM_OPEN_API_INTERFACE_GetChannelList @"GetChannelList"

// GetChannelSchedule
#define CNM_OPEN_API_INTERFACE_GetChannelSchedule @"GetChannelSchedule"

// GetChannelMyList
#define CNM_OPEN_API_INTERFACE_GetChannelMyList @"GetChannelMyList"

// SetMyChannel
#define CNM_OPEN_API_INTERFACE_SetMyChannel @"SetMyChannel"

// SetMyHiddenChannel
#define CNM_OPEN_API_INTERFACE_SetMyHiddenChannel @"SetMyHiddenChannel"

// SetMySchedule
#define CNM_OPEN_API_INTERFACE_SetMySchedule @"SetMySchedule"

// 3. RemoteController & Message
// SetRemoteChannelControl
#define CNM_OPEN_API_INTERFACE_SetRemoteChannelControl @"SetRemoteChannelControl"

// SetRemoteVolumeControl
#define CNM_OPEN_API_INTERFACE_SetRemoteVolumeControl @"SetRemoteVolumeControl"

// SetRemotePowerControl
#define CNM_OPEN_API_INTERFACE_SetRemotePowerControl @"SetRemotePowerControl"

// SetRemoteMessage
#define CNM_OPEN_API_INTERFACE_SetRemoteMessage @"SetRemoteMessage"

// 4. VOD
// GetVodGenre
#define CNM_OPEN_API_INTERFACE_GetVodGenre @"GetVodGenre"

// GetVodGenreInfo
#define CNM_OPEN_API_INTERFACE_GetVodGenreInfo @"GetVodGenreInfo"

// GetVodMovie
#define CNM_OPEN_API_INTERFACE_GetVodMovie @"GetVodMovie"

// GetVodTv
#define CNM_OPEN_API_INTERFACE_GetVodTv @"GetVodTv"

// GetVodTag
#define CNM_OPEN_API_INTERFACE_GetVodTag @"GetVodTag"

// GetVodTrailer
#define CNM_OPEN_API_INTERFACE_GetVodTrailer @"GetVodTrailer"

// GetVodMyList
#define CNM_OPEN_API_INTERFACE_GetVodMyList @"GetVodMyList"

// SetMyVOD
#define CNM_OPEN_API_INTERFACE_SetMyVOD @"SetMyVOD"

// SetVodSetTopDisplayInfo
#define CNM_OPEN_API_INTERFACE_SetVodSetTopDisplayInfo @"SetVodSetTopDisplayInfo"

// Notification
#define CNM_OPEN_API_INTERFACE_Notification @"Notification"

// 5. Search
// SearchChannel
#define CNM_OPEN_API_INTERFACE_SearchChannel @"SearchChannel"

// SearchProgram
#define CNM_OPEN_API_INTERFACE_SearchProgram @"SearchProgram"

// SearchVod
#define CNM_OPEN_API_INTERFACE_SearchVod @"SearchVod"

// 6.Service
// GetGuideCategory
#define CNM_OPEN_API_INTERFACE_GetGuideCategory @"GetGuideCategory"

// GetServiceGuideList
#define CNM_OPEN_API_INTERFACE_GetServiceGuideList @"GetServiceGuideList"

// GetServiceGuideInfo
#define CNM_OPEN_API_INTERFACE_GetServiceGuideInfo @"GetServiceGuideInfo"

// GetServiceGuideImage
#define CNM_OPEN_API_INTERFACE_GetServiceGuideImage @"GetServiceGuideImage"

// GetServiceJoinNList
#define CNM_OPEN_API_INTERFACE_GetServiceJoinNList @"GetServiceJoinNList"

// GetServiceJoinNInfo
#define CNM_OPEN_API_INTERFACE_GetServiceJoinNInfo @"GetServiceJoinNInfo"

// GetServiceNoticeInfo
#define CNM_OPEN_API_INTERFACE_GetServiceNoticeInfo @"GetServiceNoticeInfo"