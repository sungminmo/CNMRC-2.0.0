//
//  SearchHistory.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 6..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SearchHistory : NSManagedObject

@property (nonatomic, retain) NSString * keyword;
@property (nonatomic, retain) NSDate * searchDate;

@end
