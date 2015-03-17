//
//  CMBoxFinder.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 24..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMBoxFinder.h"
#import "NSNetService+Additions.h"  // gidCompare: 메서드를 위해...

// mDNS 서비스 이름.
static NSString* const kBoxServiceType = @"_anymote._tcp";

@implementation CMBoxFinder

- (id)init {
    if ((self = [super init]))
    {
        _unresolvedAddresses = [[NSMutableArray alloc] init];
        _boxes = [[NSMutableArray alloc] init];
        _browser = [[NSNetServiceBrowser alloc] init];
        [_browser setDelegate:self];
    }
    return self;
}

#pragma mark - 퍼블릭 메서드

- (void)searchForBoxes
{
    if (_isSearching)
    {
        return;
    }
    
    [_unresolvedAddresses removeAllObjects];
    [_boxes removeAllObjects];
    [_delegate didChangeBoxList:_boxes];
    [_browser searchForServicesOfType:kBoxServiceType inDomain:@""];
    _isSearching = YES;
}

- (void)stopSearching
{
    if (!_isSearching)
    {
        return;
    }
    [_browser stop];
    _isSearching = NO;
}

- (int)count
{
    return (int)[_boxes count];
}

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    [_unresolvedAddresses removeObject:service];

    // 주소가 해석된 것으로 박스들이 구성된다.
    if ([service isResolved])
    {
        [_boxes removeObject:[CMBoxService boxServiceFromNetService:service]];
    }
    [_delegate didChangeBoxList:_boxes];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    [_unresolvedAddresses addObject:service];
    [service setDelegate:self];
    [service resolveWithTimeout:0.0];
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceDidResolveAddress:(NSNetService *)service
{
    [_boxes addObject:[CMBoxService boxServiceFromNetService:service]];
    [_boxes sortUsingSelector:@selector(gidCompare:)];
    [_unresolvedAddresses removeObject:service];
    [_delegate didChangeBoxList:_boxes];
}

@end
