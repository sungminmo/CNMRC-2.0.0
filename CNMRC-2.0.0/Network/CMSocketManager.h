//
//  CMSocketManager.h
//  CNMRC
//
//  Created by lambert on 2013. 11. 7..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;
@class AsyncSocket;
@class CMTRParser;

@interface CMSocketManager : NSObject
{
    AsyncSocket *_asyncSocket;
    
    int _dataLength;                // 데이터 크기.
	NSMutableData *_rxBuffer;       // 버퍼 크기.
    NSTimer *_timer;                // 타이머.
    
    // 네트워크 상태.
    Reachability *_serverReach;     // RQ/RP 서버.
    Reachability *_internetReach;   // 인터넷.
    Reachability *_wifiReach;       // 로컬 WiFi.
}

@property (assign, nonatomic) BOOL isHandshake;     // 핸드세이크 여부.
@property (strong, nonatomic) CMTRParser *parser;
@property (strong, nonatomic) NSString *serverAddress;
@property (assign, nonatomic) UInt16 serverPort;

+ (CMSocketManager *)sharedCMSocketManager;

// 소켓.
- (BOOL)callbackIsForThisInstance:(AsyncSocket *)sock;
- (BOOL)openSocket;
- (BOOL)openSocketWithAddress:(NSString *)address andPort:(UInt16)port;
- (void)closeSocket;
- (void)reconnect;

// 네트워크 상태 체크.
- (void)hasConnection;
- (void)updateInterfaceWithReachability:(Reachability *)curReach;
//- (void)alertNetworkStauts:(Reachability *)curReach;

// 데이터 전송.
- (void)sendData:(NSString *)stringData;
- (void)receiveData:(NSData *)data;

@end
