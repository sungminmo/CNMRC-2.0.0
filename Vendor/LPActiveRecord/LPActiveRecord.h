//
//  LPActiveRecord.h
//  ActiveRecord
//
//  Created by Jong Pil Park on 12. 8. 23..
//  Copyright (c) 2012년 LambertPark. All rights reserved.
//

/**
 CoreData를 사용하기 위해 랩핑한 LPActiveRecord.
 
 CoreData 사용을 위해 Ruby on Rails의 ActiveRecord 방식을 차용하였다.
 */

#import "NSManagedObject+ActiveRecord.h"

/**
 *[사용법]*
 
 1. 먼저 프로젝트명+.pch 파일에 "LPActiveRecord.h"를 임포트 한다.
 
 2. Xcode에 메인 메뉴에서 File > New > File...를 선택한 후, iOS 템플릿 중 Core Data > Data Model을 선택하여
 새로운 데이터 모델을 생성한다. 이후 엔티티 생성과 같은 내용은 애플의 CoreData 관련 문서 또는 과련 서적을 참고하라.
 [참고] http://developer.apple.com/library/mac/#documentation/cocoa/Conceptual/CoreData/cdProgrammingGuide.html
 
 3. 만약 Xcode에서 CoreData 사용 옵션을 선택하여  프로젝트 생성을 하지 않았다면 위에서 생성한 데이터 모델의 이름으로
 LPCoreDataManager.m 클래스의 CUSTOM_MODEL_NAME와 CUSTOM_DATABASE_NAME 상수를 설정한다.(기본값: nil)
 
 * 다음의 Peron은 데이터 모델의 Entity이름이며 또한 NSManagedObject를 상속한 모델 클래스 이다.
 * 예의 Person 모델은 age, isMember, firstName, lastName과 같은 4개의 프라퍼티를 갖고 있다.
 
 > 생성/저장/삭제
 Person *lambert = [Person create];
 lambert.age = @44; // XCode >= 4.4
 lambert.isMember = YES;
 lambert.firstName = @"Lambert";
 lambert.lastName = @"Park";
 [lambert save];
 [lambert delete];
 
 // XCode >= 4.4
 NSDictionary *attributes = @{
    @"age" : @44,
    @"isMember" : @YES,
    @"firstName" : @"Lambert",
    @"lastName" : @"Park"
 } 
 [Person create:attributes];

 -------------------------------------------------------------------------------
 > 조회
 -------------------------------------------------------------------------------
 NSArray *people = [Person all];
 NSArray *parks = [Person where:@"lastName == 'Park'"];
 Person *lambert = [Person where:@"firstName == 'Lambert' AND lastName = 'Park'"].first;
 
 // XCode >= 4.4
 NSArray *people = [Person where:@{ @"age" : @44 }];
 NSArray *people = [Person where:@{ @"age" : @44, @"isMember" : @YES}];
 -------------------------------------------------------------------------------
 
 -------------------------------------------------------------------------------
 > 사용자 컨텍스트 
 -------------------------------------------------------------------------------
 NSManagedObjectContext *newContext = [NSManagedObjectContext new];
 
 Person *lambert = [Person createInContext:newContext];
 Person *lambert = [Person where:@"firstName == 'Lambert'" inContext:newContext].first;
 NSArray *people = [Person allInContext:newContext];
 -------------------------------------------------------------------------------
 
 -------------------------------------------------------------------------------
 > NSArray+Accessors 카테고리 
 -------------------------------------------------------------------------------
 NSArray *array;
 [array each:^(id object) {
    NSLog(@"Object: %@", object);
 }];
 
 [array eachWithIndex:^(id object, int index) {
    NSLog(@"Object: %@ idx: %i", object, index);
 }];
 
 id object = array.first;
 id object = array.last;
 
 (사용 예)
 // 조회.
 [[Person all] each:^(Person *person) {
    person.isMember = @NO;
 }];
 
 for (Person *person in [Person all]) {
    person.isMember = @YES;
 }
 
 // 조회/삭제.
 [[Person where:@{ "isMember" : @NO }] each:^(Person *person) {
    [person delete];
 }];
 -------------------------------------------------------------------------------
 */
