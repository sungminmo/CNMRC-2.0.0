/*
Ê* Copyright 2012 Google Inc. All Rights Reserved.
Ê*
Ê* Licensed under the Apache License, Version 2.0 (the "License");
Ê* you may not use this file except in compliance with the License.
Ê* You may obtain a copy of the License at
Ê*
Ê* Ê Ê Êhttp://www.apache.org/licenses/LICENSE-2.0
Ê*
Ê* Unless required by applicable law or agreed to in writing, software
Ê* distributed under the License is distributed on an "AS IS" BASIS,
Ê* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
Ê* See the License for the specific language governing permissions and
Ê* limitations under the License.
Ê*/

#import "NSNetService+Additions.h"
#include <arpa/inet.h>


@implementation NSNetService(Remote)

- (BOOL)isResolved {
  return 0 < [[self addresses] count];
}

- (NSString *)addressAsStringAtIndex:(int)index {
  NSString *addressAsString = nil;
  NSArray *addresses = [self addresses];
  if (index < [addresses count]) {
    NSData *socketData = [addresses objectAtIndex:index];
    const struct sockaddr_in *socket =
        (const struct sockaddr_in *) [socketData bytes];
    if (socket) {
      char buffer[SOCK_MAXADDRLEN];
      const char *s = inet_ntop(
          socket->sin_family, &socket->sin_addr, buffer, sizeof(buffer));
      if (s) {
        addressAsString = [NSString stringWithFormat:@"%s", s];
      }
    }
  }
  return addressAsString;
}

- (NSArray *)addressesAsStrings {
  NSArray *addresses = [self addresses];
  NSMutableArray *addressesAsStrings =
      [NSMutableArray arrayWithCapacity:[addresses count]];
  for (int i = 0; i < [addresses count]; i++) {
    [addressesAsStrings addObject:[self addressAsStringAtIndex:i]];
  }
  return addressesAsStrings;
}

@end
