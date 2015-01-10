//
//  LPCoreDataManager.m
//  ActiveRecord
//
//  Created by Jong Pil Park on 12. 8. 23..
//  Copyright (c) 2012년 LambertPark. All rights reserved.
//

#import "LPCoreDataManager.h"

#define CF_BUNDLE_NAME @"CFBundleName"
#define DATABASE_NAME_SUFFIX @".sqlite"
#define MODEL_NAME_EXTENSION @"momd"

static NSString *CUSTOM_MODEL_NAME = @"CNMRC";
static NSString *CUSTOM_DATABASE_NAME = @"CNMRC.sqlite";

@implementation LPCoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static LPCoreDataManager *singleton;

- (id)initForSingleton
{
    return [super init];
}

+ (id)instance
{
    static dispatch_once_t singletonToken;
    dispatch_once(&singletonToken, ^{
        singleton = [[self alloc] init];
    });
    
    return singleton;
}

#pragma mark - 프라이빗 메서드

- (NSString *)appName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:CF_BUNDLE_NAME];
}

- (NSString *)databaseName
{
    if (CUSTOM_DATABASE_NAME) return CUSTOM_DATABASE_NAME;
    return [[self appName] stringByAppendingString:DATABASE_NAME_SUFFIX];
}

- (NSString *)modelName
{
    if (CUSTOM_MODEL_NAME) return CUSTOM_MODEL_NAME;
    return [self appName];
}

#pragma mark - 퍼블릭 메서드

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) return _managedObjectContext;
    
    if (self.persistentStoreCoordinator)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) return _managedObjectModel;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[self modelName] withExtension:MODEL_NAME_EXTENSION];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (void)setUpPersistentStoreCoordinator
{    
    NSURL *storeURL = [self.applicationDocumentsDirectory URLByAppendingPathComponent:[self databaseName]];
    
    // DB 복사: 미리 입력된 데이터를 위해...-------------------------------------------
    //[self createEditableCopyOfDatabaseIfNeeded];
    // -------------------------------------------------------------------------
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // 마이그레이션을 위한 옵션.
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        NSLog(@"ERROR IN PERSISTENT STORE COORDINATOR! %@, %@", error, [error userInfo]);
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) return _persistentStoreCoordinator;
    
    [self setUpPersistentStoreCoordinator];
    return _persistentStoreCoordinator;
}

- (BOOL)saveContext
{
    if (self.managedObjectContext == nil) return NO;
    if (![self.managedObjectContext hasChanges])return NO;
    
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error in saving context! %@, %@", error, [error userInfo]);
        return NO;
    }
    
    return YES;
}

#pragma mark - 앱의 도큐먼트 디렉토리

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)applicationDocumentsDirectoryForString
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - DB가 존재하는 지 확인(카테고리,  등의 사전 데이터 입력을 위해...)

- (void)createEditableCopyOfDatabaseIfNeeded
{
	// DB가 존재하는 지 확인.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *documentDirectory = [self applicationDocumentsDirectoryForString];
	NSString *writableDBPath = [documentDirectory stringByAppendingPathComponent:[self databaseName]];
	
	BOOL dbexits = [fileManager fileExistsAtPath:writableDBPath];
    
	if (!dbexits)
    {
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[self databaseName]];
		
		NSError *error;
		BOOL success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		if (!success)
        {
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}
	}
}

@end
