//
//  NSManagedObject+ActiveRecord.h
//  ActiveRecord
//
//  Created by Jong Pil Park on 12. 8. 23..
//  Copyright (c) 2012년 LambertPark. All rights reserved.
//

/**
 LPActiveRecord를 이용해 객체를 저장/조회/생성/삭제 등의 기능을 제공하는 카테고리 이다.
 */

#import <CoreData/CoreData.h>
#import "LPCoreDataManager.h"
#import "NSArray+Accessors.h"

@interface NSManagedObjectContext (ActiveRecord)
/**
 NSManagedObjectContext 타입의 기본 컨텍스트를 반환 한다.
 */
+ (NSManagedObjectContext *)defaultContext;
@end

@interface NSManagedObject (ActiveRecord)

#pragma mark - 기본 컨텍스트

/**
 DB에 객체를 저장한다.
 
 @warning ActiveRecord에서 언급하는 객체는 데이터모델의 Entity(실제로는 Entity와 1:1로 매핑되는 모델 클래스이다.)를 의미한다.
 @return YES/NO 반환.
 */
- (BOOL)save;

/**
 DB에서 객체를 삭제한다.
 
 @warning ActiveRecord에서 언급하는 객체는 데이터모델의 Entity(실제로는 Entity와 1:1로 매핑되는 모델 클래스이다.)를 의미한다.
 */
- (void)delete;

/**
 DB의 모든 객체를 삭제한다.
 
 @warning ActiveRecord에서 언급하는 객체는 데이터모델의 Entity(실제로는 Entity와 1:1로 매핑되는 모델 클래스이다.)를 의미한다.
 */
+ (void)deleteAll;

/**
 DB에 객체를 생성(삽입)한다.
 
 @warning ActiveRecord에서 언급하는 객체는 데이터모델의 Entity(실제로는 Entity와 1:1로 매핑되는 모델 클래스이다.)를 의미한다.
 @return id 데이터모델 객체 반환.
 */
+ (id)create;

/**
 DB예 속성을 생성(삽입)한다.
 
 @param attributes NSDictionary 타입의 속성.
 @warning ActiveRecord에서 언급하는 객체는 데이터모델의 Entity(실제로는 Entity와 1:1로 매핑되는 모델 클래스이다.)를 의미한다.
 @return id 데이터모델 객체 반환.
 */
+ (id)create:(NSDictionary *)attributes;

/**
 DB의 모든 객체를 반환한다.
 
 @warning ActiveRecord에서 언급하는 객체는 데이터모델의 Entity(실제로는 Entity와 1:1로 매핑되는 모델 클래스이다.)를 의미한다.
 @return NSArray 데이터모델 객체의 배열 반환.
 */
+ (NSArray *)all;

/**
 특정 조건으로 객체를 조회한다. SQL 구분의 WHERE 절과 동일한 역할을 한다.
 
 @param condition 조건.
 @warning ActiveRecord에서 언급하는 객체는 데이터모델의 Entity(실제로는 Entity와 1:1로 매핑되는 모델 클래스이다.)를 의미한다.
 @return NSArray 데이터모델 객체의 배열 반환.
 */
+ (NSArray *)where:(id)condition;

/**
 특정 조건으로 객체를 조회한 후 정렬을 한다.
 
 @param condition 조건.
 @param descriptor 소트 디스크립터.
 @warning ActiveRecord에서 언급하는 객체는 데이터모델의 Entity(실제로는 Entity와 1:1로 매핑되는 모델 클래스이다.)를 의미한다.
 @return NSArray 데이터모델 객체의 배열 반환.
 */
+ (NSArray *)where:(id)condition sortDescriptor:(id)descriptor;

/**
 특정 조건으로 객체를 정렬한 후 제한된 갯수만큼 조회한 한다.
 
 @param condition 조건.
 @param descriptor 소트 디스크립터.
 @param fetchLimit 조회 갯수 지정.
 @warning ActiveRecord에서 언급하는 객체는 데이터모델의 Entity(실제로는 Entity와 1:1로 매핑되는 모델 클래스이다.)를 의미한다.
 @return NSArray 데이터모델 객체의 배열 반환.
 */
+ (NSArray *)where:(id)condition sortDescriptor:(id)descriptor fetchLimit:(NSInteger)fetchLimit;

#pragma mark - 사용자 컨텍스트

/**
 새로운 사용자 컨택스트를 생성한다.
 
 @param context NSManagedObjectContext 타입의 사용자 컨텍스트.
 @return id.
 */
+ (id)createInContext:(NSManagedObjectContext *)context;

/**
 새로운 사용자 컨택스트를 생성한다.
 
 @param attributes NSDictionary 타입의 속성.
 @param context NSManagedObjectContext 타입의 사용자 컨텍스트.
 @return id.
 */
+ (id)create:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context;

/**
 컨텍스트 내의 모든 객체를 삭제한다.
 
 @param context NSManagedObjectContext 타입의 컨텍스트.
 */
+ (void)deleteAllInContext:(NSManagedObjectContext *)context;

/**
 컨텍스트 내의 모든 객체를 반환한다.
 
 @param context NSManagedObjectContext 타입의 컨텍스트.
 @return NSArray 데이터모델 객체의 배열 반환.
 */
+ (NSArray *)allInContext:(NSManagedObjectContext *)context;

/**
 특정 조건에 부합하는 모든 객체를 삭제한다.
 
 @param condition 객체의 조회 조건.
 @param descriptor 소트 디스크립터.
 @param context NSManagedObjectContext 타입의 컨텍스트.
 @return NSArray 데이터모델 객체의 배열 반환.
 */
+ (NSArray *)where:(id)condition sortDescriptor:(id)descriptor inContext:(NSManagedObjectContext *)context;

/**
 특정 조건에 부합하는 모든 객체를 삭제한다.
 
 @param condition 객체의 조회 조건.
 @param context NSManagedObjectContext 타입의 컨텍스트.
 @return NSArray 데이터모델 객체의 배열 반환.
 */
+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context;

/**
 객체의 PK키를 반환한다.

 @return NSInteger 관리객체의 PK 반환.
 */
- (NSInteger)objectPK;

/**
 NSFetchedResultsController를 반환한다.
 
 @param entityName 엔티티 이름.
 @param sortBy 정렬 키 이름.
 @param ascending  내림차순 여부.
 @param predicateString NSString 타입의 pedicate.
 @return NSFetchedResultsController 반환.
 */
- (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString *)entityName
                                                          orderBy:(NSString *)sortBy
                                                        ascending:(BOOL)ascending
                                                        predicate:(NSString *)predicateString, ...;

/**
 NSFetchedResultsController를 반환한다.
 
 @param entityName 엔티티 이름.
 @param sortBy 정렬 키 이름.
 @param ascending  내림차순 여부.
 @return NSFetchedResultsController 반환.
 */
- (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString *)entityName
                                                          orderBy:(NSString *)sortBy
                                                        ascending:(BOOL)ascending;

@end
