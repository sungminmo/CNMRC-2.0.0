/*
�* Copyright 2012 Google Inc. All Rights Reserved.
�*
�* Licensed under the Apache License, Version 2.0 (the "License");
�* you may not use this file except in compliance with the License.
�* You may obtain a copy of the License at
�*
�* � � �http://www.apache.org/licenses/LICENSE-2.0
�*
�* Unless required by applicable law or agreed to in writing, software
�* distributed under the License is distributed on an "AS IS" BASIS,
�* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
�* See the License for the specific language governing permissions and
�* limitations under the License.
�*/

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
