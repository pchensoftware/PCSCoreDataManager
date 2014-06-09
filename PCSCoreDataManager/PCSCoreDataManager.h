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

@end