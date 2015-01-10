//
//  WishList.h
//  CNMRC
//
//  Created by lambert on 2013. 11. 27..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WishList : NSManagedObject

@property (nonatomic, retain) NSString * assetID;
@property (nonatomic, retain) NSDate * date;

@end
