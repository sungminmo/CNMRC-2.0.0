//
//  LPCoreDataManager.h
//  ActiveRecord
//
//  Created by Jong Pil Park on 12. 8. 23..
//  Copyright (c) 2012년 LambertPark. All rights reserved.
//

/**
 CoreData를 사용하기 위해 랩핑한 ActiveRecord를 관리하기 위한 싱클턴 클래스 이다.
 컨텍스트 관리가 목적이다.
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface LPCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 LPCoreDataManager 타입의 싱글턴 인스턴스를 반환한다.
 
 @return id CoreDataManager 타입의 싱글턴 인스턴스 반환.
 */
+ (id)instance;

/**
 NSManagedObjectContext 타입의 컨텍스트를 저장한다.
 
 @return YES/NO 반환.
 */
- (BOOL)saveContext;

/**
 앱의 문서 디렉토리를 반환한다.
 
 @return NSURL 타입의 문서 디렉토리 반환.
 */
- (NSURL *)applicationDocumentsDirectory;

/**
 앱의 문서 디렉토리를 반환한다.
 
 @return NSString 타입의 문서 디렉토리 반환.
 */
- (NSString *)applicationDocumentsDirectoryForString;

/**
 DB가 존재하는 지 확인(카테고리,  등의 사전 데이터 입력을 위해...)하여 데이터베이스를 복사한다.
 */
- (void)createEditableCopyOfDatabaseIfNeeded;

@end
