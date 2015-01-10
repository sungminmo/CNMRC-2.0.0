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

#import <Foundation/Foundation.h>

// BoxListController shows an NSArray of these, created by BoxFinder.
// This allows th UITableViewCell to show the IP address, and keeps these sorted.
@interface NSNetService(Remote)

- (BOOL)isResolved;

// Returns nil if no addresses, or index out of bounds.
- (NSString *)addressAsStringAtIndex:(int)index;

// Returns addresses formatted as NSStrings.
- (NSArray *)addressesAsStrings;

@end
