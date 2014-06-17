//====================================================================================================
// Author: Peter Chen
// Created: 6/9/14
// Copyright 2014 pchensoftware
//====================================================================================================

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PCSCoreDataManager : NSObject

@property (nonatomic, strong) NSString *modelFilebaseName; // exclude the file extension part (.xcdatamodeld)
@property (readonly, strong, nonatomic) NSManagedObjectContext *context;
@property (readonly, strong, nonatomic) NSManagedObjectModel *model;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (PCSCoreDataManager *)manager;
- (BOOL)saveContext;
- (NSManagedObject *)objectWithURIString:(NSString *)uriString;

- (int)executeRequestToCountNumberOfEntitiesWithName:(NSString *)entityName keyPath:(NSString *)keyPath;
- (NSDate *)executeRequestForEarliestDateOfEntitiesWithName:(NSString *)entityName keyPath:(NSString *)keyPath;
- (NSDate *)executeRequestForEarliestDateOfEntitiesWithName:(NSString *)entityName keyPath:(NSString *)keyPath predicate:(NSPredicate *)predicate;
- (NSDate *)executeRequestForLatestDateOfEntitiesWithName:(NSString *)entityName keyPath:(NSString *)keyPath;
- (NSDate *)executeRequestForLatestDateOfEntitiesWithName:(NSString *)entityName keyPath:(NSString *)keyPath predicate:(NSPredicate *)predicate;

@end
