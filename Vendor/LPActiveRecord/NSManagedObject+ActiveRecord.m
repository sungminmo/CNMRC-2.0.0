//
//  NSManagedObject+ActiveRecord.m
//  ActiveRecord
//
//  Created by Jong Pil Park on 12. 8. 23..
//  Copyright (c) 2012년 LambertPark. All rights reserved.
//

#import "NSManagedObject+ActiveRecord.h"

@implementation NSManagedObjectContext (ActiveRecord)

+ (NSManagedObjectContext *)defaultContext
{
    return [[LPCoreDataManager instance] managedObjectContext];
}

@end

@implementation NSManagedObject (ActiveRecord)

#pragma mark - 조회

+ (NSArray *)all
{
    return [self allInContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)allInContext:(NSManagedObjectContext *)context
{
    return [self fetchWithPredicate:nil inContext:context];
}

+ (NSArray *)where:(id)condition
{
    return [self where:condition inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context
{
    return [self fetchWithPredicate:[self predicateFromStringOrDict:condition] inContext:context];
}

+ (NSArray *)where:(id)condition sortDescriptor:(id)descriptor
{
    return [self where:condition sortDescriptor:descriptor inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)where:(id)condition sortDescriptor:(id)descriptor fetchLimit:(NSInteger)fetchLimit
{
    return [self where:condition sortDescriptor:descriptor fetchLimit:fetchLimit inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSArray *)where:(id)condition sortDescriptor:(id)descriptor inContext:(NSManagedObjectContext *)context
{
    return [self fetchWithPredicate:[self predicateFromStringOrDict:condition] andSortDescriptor:descriptor inContext:context];
}

+ (NSArray *)where:(id)condition sortDescriptor:(id)descriptor fetchLimit:(NSInteger)fetchLimit inContext:(NSManagedObjectContext *)context
{
    return [self fetchWithPredicate:[self predicateFromStringOrDict:condition] andSortDescriptor:descriptor fetchLimit:(NSInteger)fetchLimit inContext:context];
}

- (NSInteger)objectPK
{
    return [[[[[[self objectID] URIRepresentation] absoluteString] lastPathComponent] substringFromIndex:1] intValue];
}

#pragma mark - 생성 / 삭제

+ (id)create
{
    return [self createInContext:[NSManagedObjectContext defaultContext]];
}

+ (id)create:(NSDictionary *)attributes
{
    return [self create:attributes inContext:[NSManagedObjectContext defaultContext]];
}

+ (id)create:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context
{
    NSManagedObject *newEntity = [self createInContext:context];
    
    [newEntity setValuesForKeysWithDictionary:attributes];
    return newEntity;
}

+ (id)createInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

- (BOOL)save
{
    return [self saveTheContext];
}

- (void)delete
{
    [self.managedObjectContext deleteObject:self];
    [self saveTheContext];
}

+ (void)deleteAll
{
    
    [self deleteAllInContext:[NSManagedObjectContext defaultContext]];
}

+ (void)deleteAllInContext:(NSManagedObjectContext *)context
{
    [[self allInContext:context] each:^(id object) {
        [object delete];
    }];
}

#pragma Fetched Results Controller

- (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString *)entityName
                                                          orderBy:(NSString *)sortBy
                                                        ascending:(BOOL)ascending
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:[NSManagedObjectContext defaultContext]];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortBy
                                                                   ascending:ascending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // 키 이름과 캐시 이름은 필요할 경우 적절히 수정한다.
    // 섹션이름의 nil일 경우 섹션을 사용안함을 의미한다.
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext defaultContext] sectionNameKeyPath:nil cacheName:nil];
    
    
    NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error])
    {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString *)entityName
                                                          orderBy:(NSString *)sortBy
                                                        ascending:(BOOL)ascending
                                                        predicate:(NSString *)predicateString, ...
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:[NSManagedObjectContext defaultContext]];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate;
    va_list variadicArguments;
    va_start(variadicArguments, predicateString);
    predicate = [NSPredicate predicateWithFormat:predicateString arguments:variadicArguments];
    va_end(variadicArguments);
    
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortBy
                                                                   ascending:ascending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // 키 이름과 캐시 이름은 필요할 경우 적절히 수정한다.
    // 섹션이름의 nil일 경우 섹션을 사용안함을 의미한다.
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext defaultContext] sectionNameKeyPath:nil cacheName:nil];
    
    
    
    NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error])
    {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return aFetchedResultsController;
}

#pragma mark - 프라이빗 메서드

+ (NSString *)queryStringFromDictionary:(NSDictionary *)conditions
{
    NSMutableString *queryString = [NSMutableString new];
    
    [conditions.allKeys each:^(id attribute) {
        [queryString appendFormat:@"%@ == '%@'",
         attribute, [conditions valueForKey:attribute]];
        if (attribute == conditions.allKeys.last) return;
        [queryString appendString:@" AND "];
    }];
    
    return queryString;
}

+ (NSPredicate *)predicateFromStringOrDict:(id)condition
{
    if ([condition isKindOfClass:[NSString class]])
        return [NSPredicate predicateWithFormat:condition];
    
    else if ([condition isKindOfClass:[NSDictionary class]])
        return [NSPredicate predicateWithFormat:[self queryStringFromDictionary:condition]];
    
    else if ([condition isKindOfClass:[NSPredicate class]])
        return condition;
    
    return nil;
}

+ (NSFetchRequest *)createFetchRequestInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
    [request setEntity:entity];
    return request;
}

+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPredicate:predicate];
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
    if (fetchedObjects.count > 0) return fetchedObjects;
    return nil;
}

+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate andSortDescriptor:(id)descriptor inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPredicate:predicate];
    
    if ([descriptor isKindOfClass:[NSSortDescriptor class]])
    {
        [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    }
    else if ([descriptor isKindOfClass:[NSArray class]])
    {
        [request setSortDescriptors:descriptor];
    }
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
    if (fetchedObjects.count > 0) return fetchedObjects;
    return nil;
}

+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate andSortDescriptor:(id)descriptor fetchLimit:(NSInteger)fetchLimit inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPredicate:predicate];
    [request setFetchLimit:fetchLimit];
    
    if ([descriptor isKindOfClass:[NSSortDescriptor class]])
    {
        [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    }
    else if ([descriptor isKindOfClass:[NSArray class]])
    {
        [request setSortDescriptors:descriptor];
    }
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
    if (fetchedObjects.count > 0) return fetchedObjects;
    return nil;
}

- (BOOL)saveTheContext
{
    if (self.managedObjectContext == nil ||
        ![self.managedObjectContext hasChanges]) return YES;
    
    NSError *error = nil;
    BOOL save = [self.managedObjectContext save:&error];
    
    if (!save || error)
    {
        NSLog(@"Unresolved error in saving context for entity: %@!\n Error:%@", self, error);
        
        return NO;
    }
    
    return YES;
}

@end
