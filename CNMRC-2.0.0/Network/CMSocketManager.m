//
//  CMSocketManager.m
//  CNMRC
//
//  Created by lambert on 2013. 11. 7..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMSocketManager.h"
#import "Reachability.h"
#import "AsyncSocket.h"
#import "NSData+Helper.h"
#import "CMTRParser.h"
#import "CMTRGenerator.h"

// 소켓 관련.
#define MAX_LENGTH 1024 * 12
#define READ_TAG 0
#define WRIGHT_TAG 1
#define READ_HEADER_TAG 2
#define KEEP_ALIVE_TIMEOUT 60   // 접속유지.

// 전문 관련.
#define SIZE_LENGTH 4
#define TR_NO_LENGTH 4

@implementation CMSocketManager

+ (CMSocketManager *)sharedCMSocketManager
{
    static CMSocketManager *sharedCMSocketManager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedCMSocketManager = [[self alloc] init];
    });
    
    return sharedCMSocketManager;
}

// 초기화.
- (id)init
{
	if ((self = [super init]))
    {
        // 버퍼.
		_rxBuffer = [[NSMutableData alloc] initWithCapacity:MAX_LENGTH];
        
        // 파서.
        _parser = [[CMTRParser alloc] init];
        
        // 소켓 생성 및 서버 접속.
        _asyncSocket = [[AsyncSocket alloc] init];
        _asyncSocket.delegate = self;
        
//        self.serverAddress = @"192.168.0.10";
//        self.serverPort = 5555;
//        
//        [self openSocket];
		
        // 서버 접속 유지.
//        _timer = nil;
//        _timer = [NSTimer scheduledTimerWithTimeInterval:KEEP_ALIVE_TIMEOUT target:self selector:@selector(keepAlive:) userInfo:nil repeats:YES];
	}
	
	return self;
}

#pragma mark - AsyncSocket Delegate Methods

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	if ([self callbackIsForThisInstance:sock])
    {
		NSLog(@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]);
		NSLog(@"willDisconnectWithError %@", [err localizedDescription]);
	}
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	if ([self callbackIsForThisInstance:sock])
    {
		NSLog(@"didDisconnect");

        // 서버 재접속.
        [self reconnect];
	}
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	if ([self callbackIsForThisInstance:sock])
    {
		NSLog(@"didConnectToHost %@:%i", host, port);
		NSLog(@"Client started on %@:%hu", [sock localHost], [sock localPort]);
		
        // 최초 전문의 데이터크기(size)만큼 데이터를 읽는다.
		//[sock readDataToLength:SIZE_LENGTH withTimeout:-1 tag:READ_HEADER_TAG];
	}
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	if ([self callbackIsForThisInstance:sock])
    {
		if (tag == READ_HEADER_TAG)
        {
            // 읽어야 할 전문 길이 확인.
			_dataLength = [self dataLength:data];
			Debug(@"Data length: %d", _dataLength);
			
            // 버퍼에 헤더의 데이터크기(size) 추가.
			[_rxBuffer appendData:data];
            
            // 데이터에서 데이터크기(size)를 뺀 길이 만큼의 데이터 읽음.
			[sock readDataToLength:(_dataLength - SIZE_LENGTH) withTimeout:-1 tag:READ_TAG];
		}
        else if (tag == READ_TAG)
        {
            // 버퍼에 데이터 추가(데이터크기(size) 길이 제외한 공통헤더 + 데이터).
            [_rxBuffer appendData:data];
            
            // 데이터 전달.
            [self receiveData:_rxBuffer];
            
            // 버퍼 초기화 및 데이터크기(size) 만큼 데이터 읽기.
            [_rxBuffer setLength:0];
			[sock readDataToLength:SIZE_LENGTH withTimeout:-1 tag:READ_HEADER_TAG];
        }
	}
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	if ([self callbackIsForThisInstance:sock]) {}
}

#pragma mark - 소켓 접속 관련 메서드

// 인스턴스 확인.
- (BOOL)callbackIsForThisInstance:(AsyncSocket *)sock
{
	BOOL isForMe = (sock == _asyncSocket);
	return isForMe;
}

// 소켓 열기.
- (BOOL)openSocket
{
	NSError	*err;
	_asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
    
    BOOL result	= [_asyncSocket connectToHost:self.serverAddress onPort:self.serverPort error:&err];
    
	if (!result)
		NSLog(@"openSocket(ERROR) %@", [err localizedDescription]);
    
    // 네트워크 상태 체크.
    //[self hasConnection];
	
	return result;
}

// 해당 주소로 소켓 열기.
- (BOOL)openSocketWithAddress:(NSString *)address andPort:(UInt16)port
{
    self.serverAddress = address;
    self.serverPort = port;
    
    return [self openSocket];
}

// 소켓 닫기.
- (void)closeSocket
{
	[_asyncSocket disconnect];
}

// 재접속.
- (void)reconnect
{
    if (!_asyncSocket.isConnected)
    {
        _asyncSocket = nil;
        [_timer invalidate];
        
        [self openSocket];
        
        // 서버 접속 유지.
        _timer = nil;
        _timer = [NSTimer scheduledTimerWithTimeInterval:KEEP_ALIVE_TIMEOUT target:self selector:@selector(keepAlive:) userInfo:nil repeats:YES];
    }
}

// 서버 접속 유지.
- (void)keepAlive:(NSTimer *)timer
{
    // TODO: 서버 확인 후, 구현 유무 결정할 것!
}

#pragma mark - 데이터 전송 및 수신 메서드

// 데이터 덤프.
- (void)dumpData:(NSData *)data
{
    Debug(@"\n-----------------------------------------------------------------------\
          \nData length: [%d]\
          \n-----------------------------------------------------------------------\
          \n%@\
          \n-----------------------------------------------------------------------", [data length], [data hexDump]);
}

// 데이터 전송: NSString.
- (void)sendData:(NSString *)stringData
{
    //Debug(@"Send data: %@", stringData);
    
    NSData *data = [self castStringToData:stringData];
    
    // 데이터에서 전문번호 확인.
    //NSString *trNo = [self trNo:data];

    // 메시지 덤프.
    //[self dumpData:data];
    
    [_asyncSocket writeData:data withTimeout:-1 tag:WRIGHT_TAG];
    [_asyncSocket readDataToLength:SIZE_LENGTH withTimeout:-1 tag:READ_HEADER_TAG];
}

// TODO: 에러처리 방법 결정 할 것.
// 데이터 수신: 데이터 필터링 및 푸시.
- (void)receiveData:(NSData *)data
{
    // 소켓을 닫는다.
    [self closeSocket];
    
    // 메시지 덤프.
    //[self dumpData:data];
    
    NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Debug(@"Receive data: %@", stringData);
    
    // 데이터에서 전문번호(!: 파서에 전달할 클래스 이름) 확인.
    NSString *trNo = [self trNo:data];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    // 응답 문자열로부터 딕셔너리 획득.
    NSDictionary *dict = [_parser parseData:data withClass:trNo];
    
    // trNo에 따른 데이터 노티피케이션.
    [nc postNotificationName:trNo object:self userInfo:dict];
}

#pragma mark - 데이터 필터링.

// NSData -> NSString 형변환.
- (NSString *)castDataToString:(NSData *)data
{
	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

// NSString -> NSData 형변환.
- (NSData *)castStringToData:(NSString *)string
{
	return [string dataUsingEncoding:NSUTF8StringEncoding];
}

// 전문 길이 확인.
- (int)dataLength:(NSData *)data
{
	NSData *truncatedData = [data subdataWithRange:NSMakeRange(0, SIZE_LENGTH)];
	return [[self castDataToString:truncatedData] intValue];
}

// 전문번호.
- (NSString *)trNo:(NSData *)data
{
    NSData *trNo = [data subdataWithRange:NSMakeRange(SIZE_LENGTH, TR_NO_LENGTH)];
    return [self castDataToString:trNo];
}

@end
