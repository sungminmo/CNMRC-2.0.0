//
//  Setting.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 8..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Setting : NSManagedObject

@property (nonatomic, retain) NSNumber * isSound;
@property (nonatomic, retain) NSNumber * isUpdateVODAlarm;
@property (nonatomic, retain) NSNumber * isVibration;
@property (nonatomic, retain) NSNumber * isWatchReservationAlarm;
@property (nonatomic, retain) NSString * terminalID;
@property (nonatomic, retain) NSString * terminalKey;
@property (nonatomic, retain) NSNumber * touchSensitivity;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSString * areaCode;
@property (nonatomic, retain) NSString * areaName;
@property (nonatomic, retain) NSString * productCode;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSNumber * isAutoAuthAdult;

@end
