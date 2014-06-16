//====================================================================================================
// Author: Peter Chen
// Created: 6/9/14
// Copyright 2014 pchensoftware
//====================================================================================================

#import "PCSCoreDataManager.h"

@interface PCSCoreDataManager()

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSManagedObjectModel *model;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation PCSCoreDataManager

+ (PCSCoreDataManager *)manager {
   static PCSCoreDataManager *_manager = nil;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      _manager = [[PCSCoreDataManager alloc] init];
   });
   return _manager;
}

- (id)init {
   if ((self = [super init])) {
   }
   return self;
}

- (BOOL)saveContext {
   NSError *error = nil;
   NSManagedObjectContext *context = self.context;
   if (context != nil) {
      if ([context hasChanges] && ! [context save:&error]) {
         //NSLog(@"ERROR Couldn't save core data context -\nerror:\n%@\nuserInfo:\n%@", error, [error userInfo]);
         
#if TARGET_IPHONE_SIMULATOR
         abort();
#else
         
#endif
         return NO;
      }
   }
   return YES;
}

- (NSManagedObjectContext *)context {
   if (_context != nil) {
      return _context;
   }
   
   NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
   if (coordinator != nil) {
      _context = [[NSManagedObjectContext alloc] init];
      [_context setPersistentStoreCoordinator:coordinator];
   }
   return _context;
}

- (NSManagedObjectModel *)model {
   if (_model != nil) {
      return _model;
   }
   NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelFilebaseName withExtension:@"momd"];
   _model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
   return _model;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
   if (_persistentStoreCoordinator != nil) {
      return _persistentStoreCoordinator;
   }
   
   NSURL *documentsDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
   NSURL *storeURL = [documentsDirectoryURL URLByAppendingPathComponent:[self.modelFilebaseName stringByAppendingString:@".sqlite"]];
   NSError *error = nil;
   
   // Lightweight migration
   NSDictionary *migrateOptions = @{ NSMigratePersistentStoresAutomaticallyOption : @YES,
                                     NSInferMappingModelAutomaticallyOption : @YES };
   
   _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
   if (! [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:migrateOptions error:&error]) {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
       
       Typical reasons for an error here include:
       * The persistent store is not accessible;
       * The schema for the persistent store is incompatible with current managed object model.
       Check the error message to determine what the actual problem was.
       
       
       If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
       
       If you encounter schema incompatibility errors during development, you can reduce their frequency by:
       * Simply deleting the existing store:
       [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
       
       * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
       @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
       
       Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
       
       */
      
      //NSLog(@"ERROR Couldn't create persistent store coordinator - %@, %@", error, [error userInfo]);
      
#if TARGET_IPHONE_SIMULATOR
      abort();
#else
      
#endif
   }
   
   return _persistentStoreCoordinator;
}

- (NSManagedObject *)objectWithURIString:(NSString *)uriString {
   NSURL *url = [NSURL URLWithString:uriString];
   NSManagedObjectID *managedObjectID = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:url];
   NSManagedObject *managedObject = [self.context objectWithID:managedObjectID];
   return managedObject;
}

- (int)executeRequestToCountNumberOfEntitiesWithName:(NSString *)entityName keyPath:(NSString *)keyPath {
   NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:keyPath];
   NSExpression *countExpression = [NSExpression expressionForFunction:@"count:" arguments:@[ keyPathExpression ]];
   NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
   expressionDescription.name = @"fieldName";
   expressionDescription.expression = countExpression;
   expressionDescription.expressionResultType = NSInteger32AttributeType;
   
   NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
   request.propertiesToFetch = @[ expressionDescription ];
   request.resultType = NSDictionaryResultType;
   
   NSError *error = nil;
   NSArray *results = [[PCSCoreDataManager manager].context executeFetchRequest:request error:&error];
   if (! results) {
      NSLog(@"ERROR Couldn't fetch - %@", error);
      return 0;
   }
   
   return [[results firstObject][@"fieldName"] intValue];
}

- (NSDate *)executeRequestForEarliestDateOfEntitiesWithName:(NSString *)entityName keyPath:(NSString *)keyPath {
   return [self _executeRequestForDateWithFunctionName:@"min:" ofEntitiesWithName:entityName keyPath:keyPath];
}

- (NSDate *)executeRequestForLatestDateOfEntitiesWithName:(NSString *)entityName keyPath:(NSString *)keyPath {
   return [self _executeRequestForDateWithFunctionName:@"max:" ofEntitiesWithName:entityName keyPath:keyPath];
}

- (NSDate *)_executeRequestForDateWithFunctionName:(NSString *)functionName ofEntitiesWithName:(NSString *)entityName keyPath:(NSString *)keyPath {
   NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:keyPath];
   NSExpression *functionExpression = [NSExpression expressionForFunction:functionName arguments:@[ keyPathExpression ]];
   NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
   expressionDescription.name = @"fieldName";
   expressionDescription.expression = functionExpression;
   expressionDescription.expressionResultType = NSDateAttributeType;
   
   NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
   request.propertiesToFetch = @[ expressionDescription ];
   request.resultType = NSDictionaryResultType;
   
   NSError *error = nil;
   NSArray *results = [[PCSCoreDataManager manager].context executeFetchRequest:request error:&error];
   if (! results) {
      NSLog(@"ERROR Couldn't fetch - %@", error);
      return 0;
   }
   
   return [results firstObject][@"fieldName"];
}

@end
