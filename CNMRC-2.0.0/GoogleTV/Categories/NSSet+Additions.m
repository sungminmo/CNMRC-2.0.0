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

#import "NSSet+Additions.h"


@implementation NSSet (Additions)

+ (NSSet *)tv_setWithInts:(int)count, ... {
  va_list args;
  va_start(args, count);
  NSMutableSet *set = [NSMutableSet set];
  for (int i = 0; i < count; i++) {
    int integer = va_arg(args, int);
    [set addObject:[NSNumber numberWithInt:integer]];
  }
  va_end(args);
  return set;
}

@end
