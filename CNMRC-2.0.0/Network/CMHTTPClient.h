//
//  CMHTTPClient.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 6. 25..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMHTTPClientDelegate <NSObject>

@optional
/**
 수신한 데이트를 화면에서 사용하기 위한 CMHTTPClientDelegate 메서드.
 
 @param dict 서버에서 데이터를 수신된 데이터를 파싱한 NSDictionary 타입.
 */
- (void)receiveData:(NSDictionary *)dict;

@end


@interface CMHTTPClient : NSObject <NSURLConnectionDelegate>

/**
 CMHTTPClientDelegate
 */
@property (nonatomic, weak) id<CMHTTPClientDelegate> delegate;

/**
 SMApplicationServer 프로토콜 버전.
 */
@property (nonatomic, strong) NSString *version;

/**
 클라이언트의 고유 ID.
 */
@property (nonatomic, strong) NSString *terminalID;

/**
 SMApplicationServer 인증을 위한 키: 클라이언트 하나당 하나의 키가 발급된다.
 */
@property (nonatomic, strong) NSString *terminalKey;

/**
 CMHTTPClient 싱글턴 인스턴스를 생성한다.
 
 @return CMHTTPClient 반환.
 */
+ (CMHTTPClient *)sharedCMHTTPClient;

/**
  GET 방식으로 데이터를 요청한다.
 
 @param url 파라미터가 포함된 서버 URL
 @param obj 델리게이터 객체.
 @param sync 동기 여부.
 */
- (void)requestWithURL:(NSURL *)url delegate:(id)obj sync:(BOOL)isSynchronous;

/**
 POST 방식으로 데이터를 요청한다.
 
 @param url 서버 URL.
 @param obj 델리게이터 객체.
 @param dict 데이터 요청을 위한 전문의 키 = 값 형태의 NSDictionary.
 @param sync 동기 여부.
 */
- (void)requestWithURL:(NSURL *)url delegate:(id)obj andDictionary:(NSDictionary *)dict sync:(BOOL)isSynchronous;

@end
