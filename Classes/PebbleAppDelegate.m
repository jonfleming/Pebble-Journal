//
//  PebbleAppDelegate.m
//  Pebble
//
//  Created by techion on 6/23/10.
//  Copyright Jon Fleming 2010. All rights reserved.
//

#import "PebbleAppDelegate.h"


#import "RootViewController.h"
#import "DetailViewController.h"
#import "constants.h"

@interface PebbleAppDelegate (CoreDataPrivate)
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (NSString *)applicationDocumentsDirectory;
@end


@implementation PebbleAppDelegate

@synthesize window, splitViewController, rootViewController, detailViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	rootViewController.protect = [defaults boolForKey:@"passwordProtect"];
	NSString *password = [defaults stringForKey:@"password"];
		
	if ([password length] == 0) {
		rootViewController.protect = FALSE;
	}
	
	rootViewController.managedObjectContext = self.managedObjectContext;

	// Add the split view controller's view to the window and display.
	[window addSubview:splitViewController.view];
	[window makeKeyAndVisible];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Resource" ofType:@"plist"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path]) {
		NSArray *thisArray = [[NSArray alloc] initWithContentsOfFile:path];
		DebugLog(D_FINER, @"The array count: %i", [thisArray count]);
		
		rootViewController.resourceArray = thisArray;
	}	

	if (rootViewController.protect) {
		rootViewController.postPasswordAction = @selector(performSearch);
		[rootViewController performSelector:@selector(promptForPassword:) withObject:PasswordPebble afterDelay:0.3];
	}
	
	return YES;
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	NSError *error = nil;
    if (managedObjectContext != nil) {
		DebugLog(D_FINER, @"--- Saving on Exit");
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			DebugLog(D_ERROR, @"*** Unresolved error %@, %@", error, [error userInfo]);
			DebugBreak();
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return managedObjectModel;
}

- (void)reportEntities {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	NSManagedObjectModel *aModel = [self managedObjectModel];
	for (NSEntityDescription *entity in aModel) {
		DebugLog(D_TRACE, @"%@", entity);
	}
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

	
	// default code to create persistentStoreCoordinator 
	if (FALSE) {		
		NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Pebble.sqlite"]];
	
		NSError *error = nil;
		persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
		[persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
		
		if (error) {
			DebugLog(D_TRACE, @"Unresolved error %@, %@", error, [error userInfo]);
			[self reportEntities];
			DebugBreak();
		}
		return persistentStoreCoordinator;
	}
		
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Pebble.sqlite"];
	DebugLog(D_TRACE, @"storePath: %@", storePath);
	
	/*
	 Provide a pre-populated default store.
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Pebble" ofType:@"sqlite"];
		if (defaultStorePath) {
			DebugLog(D_TRACE, @"Copying default database: %@", defaultStorePath);
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	// Core Data Model Versioning - Light weight migration options
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
	NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:nil URL:storeUrl error:&error];
	
	if (sourceMetadata == nil) {
		DebugLog(D_TRACE, @"sourceMetadata is nil");
	}
	
	NSString *configuration = nil; // name of configuration, or nil
	NSManagedObjectModel *destination = [persistentStoreCoordinator managedObjectModel];
	
	// Check for compatibility
	BOOL pscCompatibile = [destination isConfiguration:configuration compatibleWithStoreMetadata:sourceMetadata];
	
	if (!pscCompatibile) {
		DebugLog(D_TRACE, @"no compatible store found");
	}
	
	// no need to migrate
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 DebugBreak() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		DebugLog(D_TRACE, @"Unresolved error %@, %@", error, [error userInfo]);
		
		DebugBreak();
	}    
		
	// Create mapping model
	/*
	 NSArray *bundlesForSourceModel = nil; // an array of bundles, or nil for the main bundle
	 NSManagedObjectModel *source =[NSManagedObjectModel mergedModelFromBundles:bundlesForSourceModel forStoreMetadata:sourceMetadata];
	 
	 if (source == nil) {
	 // deal with error
	 DebugLog(D_TRACE, @"Error getting source model");
	 DebugBreak();
	 }
	 
	 //NSMappingModel *model = [NSMappingModel inferredMappingModelForSourceModel:source destinationModel:destination error:&error];				
	 //NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:source destinationModel:destination];		
	 */	
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);

	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);

	[managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[splitViewController release];
	[rootViewController release];
	[detailViewController release];

	[window release];
	[super dealloc];
}


@end

