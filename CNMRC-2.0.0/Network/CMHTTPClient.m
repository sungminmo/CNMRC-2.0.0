//
//  CMHTTPClient.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 6. 25..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMHTTPClient.h"
#import "TBXML.h"
#import "CMParser.h"
#import "CMGenerator.h"
#import "UIDevice+IdentifierAddition.h"
#import "Setting.h"
#import "HTProgressHUD.h"
#import "DQAlertView.h"

@interface CMHTTPClient ()
{
    HTProgressHUD *_prgressHUD;
}

@property (strong, nonatomic) NSData *data;

// HUD
- (void)show;
- (void)hide;

// 파싱.
- (void)parseXML:(NSData *)data;

// 동기 데이터 요청.
- (void)requestSynchronous:(NSMutableURLRequest *)request;

// 서버 오류 얼럿.
- (void)serverErrorAlert;
@end

@implementation CMHTTPClient

+ (CMHTTPClient *)sharedCMHTTPClient
{
    static CMHTTPClient *sharedCMHTTPClient = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedCMHTTPClient = [[self alloc] init];
    });
    
    return sharedCMHTTPClient;
}

- (id)init
{
    if (self = [super init])
    {

    }
    return self;
}

#pragma makr - 프라이빗 메서드

- (void)parseXML:(NSData *)data
{
    if ([data length] == 0)
    {
        return;
    }
    
    DDLogDebug(@"Data length: %lu", (unsigned long)[data length]);
    // 서버 자체에 문제가 생겻을 경우 데이터가 없다.
    // TODO: 오류처리 방법 결정할 것.
    if ([NSString stringWithUTF8String:[data bytes]] == nil)
    {
        DDLogDebug(@"%@", [NSString stringWithUTF8String:[data bytes]]);
        [self serverErrorAlert];
        
        return;
    }
    
    // 전문 파싱.
    NSDictionary *dict = nil;
    NSError *error = nil;
    //TBXML *tbxml = [TBXML tbxmlWithXMLData:data error:&error];
    TBXML *tbxml = [TBXML newTBXMLWithXMLData:data error:&error];
    
    if (error == nil)
    {
        dict = [CMParser dictionaryWithXMLNode:tbxml.rootXMLElement->firstChild];
    }
    else
    {
        DDLogDebug(@"서버에 문제가 있습니다. 관리자에게 문의 바랍니다!");
        [self serverErrorAlert];
        
        return;
    }
    
    // 에러 처리: 데이터를 수신하는 화면단에서 직접 처리한다.
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(receiveData:)])
    {
        DDLogDebug(@"Received view controller: %@", NSStringFromClass([self.delegate class]));
        
        // 뷰컨트롤러에 NSDictionary 타입으로 전달.
        [self.delegate receiveData:dict];
    }
}

- (void)requestSynchronous:(NSMutableURLRequest *)request
{
    self.data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    //NSLog(@"%@", [NSString stringWithUTF8String:[data bytes]]);
    if (error == nil && response)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        [self parseXML:data];
        self.data = data;
    }
}

- (void)show
{
    if (_prgressHUD)
    {
        [_prgressHUD showInView:CMAppDelegate.window];
    }
    else
    {
        _prgressHUD = [[HTProgressHUD alloc] init];
        [_prgressHUD showInView:CMAppDelegate.window];
    }
}

- (void)hide
{
    [_prgressHUD hide];
}

- (void)serverErrorAlert
{
    DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알림"
                                                        message:@"서버에 문제가 있습니다. 관리자에게 문의 바랍니다!"
                                              cancelButtonTitle:nil
                                               otherButtonTitle:@"확인"];
    alertView.shouldDismissOnActionButtonClicked = YES;
    alertView.otherButtonAction = ^{
        DDLogDebug(@"OK Clicked");
    };
    
    [alertView show];
}

#pragma makr - 퍼블릭 메서드

- (void)requestWithURL:(NSURL *)url delegate:(id)obj sync:(BOOL)isSynchronous
{
    // 액티비티 인디게이터 시작.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self show];
    
    // 델리게이트 설정(최종 데이터를 받을 화면).
    self.delegate = obj;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    if (isSynchronous)
    {
        // 비동기.
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            // Perform long running process
            [self requestSynchronous:request];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                [self parseXML:self.data];
                [self hide];
            });
        });
    }
    else
    {
        // 동기.
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
}

- (void)requestWithURL:(NSURL *)url delegate:(id)obj andDictionary:(NSDictionary *)dict sync:(BOOL)isSynchronous
{
    DDLogDebug(@"\n Request url: %@ \n Request data: %@", url, dict);
    
    if (dict == nil)
    {
        [self requestWithURL:url delegate:obj sync:isSynchronous];
        return;
    }
    
    // 액티비티 인디게이터 시작.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self show];
    
    // 델리게이트 설정(최종 데이터를 받을 화면).
    self.delegate = obj;
    
    // 쿼리스트링 생성.
    NSString *queryString = [CMGenerator genQueryStringWithDictionary:dict];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[NSData dataWithBytes:[queryString UTF8String] length:[queryString length]]];
    
    if (isSynchronous)
    {
        // 비동기.
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            // Perform long running process
            [self requestSynchronous:request];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                [self parseXML:self.data];
                [self hide];
            });
        });
    }
    else
    {
        // 동기.
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DDLogDebug(@"네워쿼크 연결에 문제가 있습니다.");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self hide];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSArray *cookies;
    NSDictionary *headers;
    
    // 받은 header들을 dictionary형태로 받고
    headers = [(NSHTTPURLResponse *)response allHeaderFields];
    
    if (headers != nil)
    {
        // headers에 포함되어 있는 항목들 출력
        for (NSString *key in headers)
        {
            DDLogDebug(@"Header: %@ = %@", key, [headers objectForKey:key]);
        }
        
        // cookies에 포함되어 있는 항목들 출력
        cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:[response URL]];
        
        if (cookies != nil)
        {
            for (NSHTTPCookie *cookie in cookies)
            {
                DDLogDebug(@"Cookie: %@ = %@", [cookie name], [cookie value]);
                
                // 통신 상태 에러 처리.
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%@", [NSString stringWithUTF8String:[data bytes]]);

    // XML 파싱.
    [self parseXML:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 액티비티 인디케이터 중지.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self hide];
}

@end
