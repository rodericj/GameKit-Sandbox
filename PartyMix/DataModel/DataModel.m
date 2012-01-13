//
//  DataModel.m
//  PartyMix
//
//  Created by Roderic Campbell on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>

#import "DataModel.h"
#import "MediaItem.h"

#define kEntityNameMediaItem                    @"MediaItem"

#define kPartyMixCoreDataBackupTempFile         @"PartyMixBackupTemp"
#define kPartyMixCoreDataBackupFile             @"PartyMixBackup"
#define kPartyMixCoreDataFile					@"PartyMix"
#define kPartyMixCoreDataFileExtension			@"sqlite"

@interface DataModel ()
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator		*persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel				*managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext				*managedObjectContext;

@end


@implementation DataModel

static DataModel *_dataModel = nil;

//NSString *const MPMediaItemPropertyPersistentID;            // filterable
//NSString *const MPMediaItemPropertyAlbumPersistentID;       // filterable
//NSString *const MPMediaItemPropertyArtistPersistentID;      // filterable
//NSString *const MPMediaItemPropertyAlbumArtistPersistentID; // filterable
//NSString *const MPMediaItemPropertyGenrePersistentID;       // filterable
//NSString *const MPMediaItemPropertyComposerPersistentID;    // filterable
//NSString *const MPMediaItemPropertyPodcastPersistentID;     // filterable
//NSString *const MPMediaItemPropertyMediaType;               // filterable
//NSString *const MPMediaItemPropertyTitle;                   // filterable
//NSString *const MPMediaItemPropertyAlbumTitle;              // filterable
//NSString *const MPMediaItemPropertyArtist;                  // filterable
//NSString *const MPMediaItemPropertyAlbumArtist;             // filterable
//NSString *const MPMediaItemPropertyGenre;                   // filterable
//NSString *const MPMediaItemPropertyComposer;                // filterable
//NSString *const MPMediaItemPropertyPlaybackDuration;
//NSString *const MPMediaItemPropertyAlbumTrackNumber;
//NSString *const MPMediaItemPropertyAlbumTrackCount;
//NSString *const MPMediaItemPropertyDiscNumber;
//NSString *const MPMediaItemPropertyDiscCount;
//NSString *const MPMediaItemPropertyArtwork;
//NSString *const MPMediaItemPropertyLyrics;
//NSString *const MPMediaItemPropertyIsCompilation;           // filterable
//NSString *const MPMediaItemPropertyReleaseDate;
//NSString *const MPMediaItemPropertyBeatsPerMinute;
//NSString *const MPMediaItemPropertyComments;
//NSString *const MPMediaItemPropertyAssetURL;

+ (NSString *)getDocumentsDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];	
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
	if (_managedObjectContext) {
		return _managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
	if (coordinator != nil) {
		_managedObjectContext = [[NSManagedObjectContext alloc] init];
		[_managedObjectContext setPersistentStoreCoordinator:coordinator];
        [_managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }
	return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
	if (_managedObjectModel != nil) {
		return _managedObjectModel;
	}
	_managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];	
	NSLog(@"After mergedModelFromBundles: entityVersionHashesByName: %@", [_managedObjectModel entityVersionHashesByName]);
	return _managedObjectModel;
}

/**
 Returns the URL of the Armstrong Core Data persistent store.
 */
- (NSURL *)coreDataPersistentStoreURL {    ;
	NSString *path = [DataModel getDocumentsDirectory];	
	return [NSURL fileURLWithPath:[path
								   stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",
																   kPartyMixCoreDataFile,
																   kPartyMixCoreDataFileExtension]]];
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
	if (_persistentStoreCoordinator) {
		return _persistentStoreCoordinator;
	}
    
	NSURL *storeUrl = [self coreDataPersistentStoreURL];
    
	NSError *addPersistentStoreError;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&addPersistentStoreError]) {
        
        /*
         We could not successfully add a new store to the coordinator. The most likely reason for this is that lightweight migration failed
         or the source model could not be found (NSMigrationMissingSourceModelError = 134130). If 134130 happens during development, it is 
         because the data model has changed at least twice since a model version was added - and we are trying to migrate from an intermediate 
         (dev-only) model.  This should not happen when migrating from databases generated by official App Store releases.
         */
        
        // TODO - should we remove the backing up of the old store?
        
        NSLog(@"Could not add a store to the coordinator. Error code = %d (%@). Backing up the old store and creating a new one.", 
                  [addPersistentStoreError code], [addPersistentStoreError localizedDescription]);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSURL *backupStoreUrl = [NSURL fileURLWithPath: [[DataModel getDocumentsDirectory]
                                                         stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",
                                                                                         kPartyMixCoreDataBackupFile,
                                                                                         kPartyMixCoreDataFileExtension]]];
        
        NSURL *tempBackupStoreUrl = [NSURL fileURLWithPath:[[DataModel getDocumentsDirectory]
                                                            stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",
                                                                                            kPartyMixCoreDataBackupTempFile,
                                                                                            kPartyMixCoreDataFileExtension]]];
        
        // Delete any lingering temporary backup store.
        NSString *tempBackupStorePath = [tempBackupStoreUrl path];
        if ([fileManager fileExistsAtPath:tempBackupStorePath]) {
            NSLog(@"Removing lingering temporary store backup at '%@'.", tempBackupStorePath);
            NSError *removeError;
            if (![fileManager removeItemAtURL:tempBackupStoreUrl error:&removeError]) {
                NSLog(@"FATAL: Could not remove lingering temporary store backup. Error code = %d (%@)", [removeError code], [removeError localizedDescription]);
                abort();
            }
        }
        
        // Move the current store to the temporary store backup.
        NSLog(@"Moving store to temporary store backup '%@'.", tempBackupStorePath);
        NSError	*moveError1;
        if (![fileManager moveItemAtURL:storeUrl toURL:tempBackupStoreUrl error:&moveError1]) {
            NSLog(@"FATAL: Could not move store to temporary store backup. Error code = %d (%@)", [moveError1 code], [moveError1 localizedDescription]);
            abort();
        }
        
        // Delete the store backup if one exists. One would not exist at first.
        NSString *backupStorePath = [backupStoreUrl path];
        if ([fileManager fileExistsAtPath:backupStorePath]) {
            NSLog(@"Removing store backup at '%@'.", backupStorePath);
            NSError *removeBackupError;
            if (![fileManager removeItemAtURL:backupStoreUrl error:&removeBackupError]) {
                NSLog(@"FATAL: Could not remove store backup. Error code = %d (%@)", [removeBackupError code], [removeBackupError localizedDescription]);
                abort();
            }
        }
        
        // Move the temporary store backup to the store backup.
        NSLog(@"Moving temporary store backup to store backup '%@'.", [backupStoreUrl path]);
        NSError	*moveError2;
        if (![fileManager moveItemAtURL:tempBackupStoreUrl toURL:backupStoreUrl error:&moveError2]) {
            NSLog(@"FATAL: Could not move temporary store backup to store backup. Error code = %d (%@)", [moveError2 code], [moveError2 localizedDescription]);
            abort();
        }
        
        NSLog(@"Previous store backed up, creating new empty store.");
        // The original store file was saved off, try again to add a store to the coordinator, this time that should create a new empty store.
        if ([_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&addPersistentStoreError]) {
            NSLog(@"New empty store created.");
            // A fresh store was created, we're in good shape and ready to use it with Core Data.
#if 0
            // In the development build, we show an alert indicating that we created a new store.
            
            JBAlertViewManager *alertViewManager = [[JBAlertViewManager alloc] initWithAlertViewManagerDelegate:self];
            alertViewManager.hasCancelButton = NO;
            [alertViewManager addButtonWithTitle:kLocaleOK command:kJBAlertViewCommandCancel];
            [alertViewManager showAlertViewWithTitle:@"Schema incompatibility" message:@"The schema of the previous database is different from the schema in use by this version of the app. Your database was backed up and a new empty one was created."];
            [alertViewManager release];
#endif
            
        } else {
            // We could not even create a new empty store using the current schema, something is really wrong.
            NSLog(@"FATAL: Even after backing up the original store, a new empty store could not be added to the coordinator. Error code = %d (%@)", [addPersistentStoreError code], [addPersistentStoreError localizedDescription]);
            abort();
        }
	}	
    
	return _persistentStoreCoordinator;
}

+(DataModel*)sharedInstance {
    if (_dataModel == nil) {
        _dataModel = [[super allocWithZone:NULL] init];
    }
    return _dataModel;
}

-(MediaItem *)insertNewMediaItem:(MPMediaItem *)mpMediaItem {
    
    MediaItem *newEntity = (MediaItem *)[NSEntityDescription insertNewObjectForEntityForName:kEntityNameMediaItem
                                                                      inManagedObjectContext:self.managedObjectContext];

    newEntity.title = [mpMediaItem valueForProperty:MPMediaItemPropertyTitle];
    newEntity.persistentID = [mpMediaItem valueForProperty:MPMediaItemPropertyPersistentID];
    return newEntity;
}

-(NSArray *)insertArrayOfMPMediaItems:(NSArray *)mediaItems {
        
    NSMutableArray *managedMediaItems = [NSMutableArray arrayWithCapacity:[mediaItems count]];
 
    for (MPMediaItem *song in mediaItems) {
        //Get the keys we care about
        MediaItem *item = [self insertNewMediaItem:song];
        [managedMediaItems addObject:item];
    }
    
    //save the managed object context
    return managedMediaItems;
}

#if TARGET_IPHONE_SIMULATOR
-(NSArray *)insertDummyMediaItems {
    NSMutableArray *tmp = [NSMutableArray array];
    MediaItem *newEntity = (MediaItem *)[NSEntityDescription insertNewObjectForEntityForName:kEntityNameMediaItem
                                                                      inManagedObjectContext:self.managedObjectContext];
    
    newEntity.title = @"song title 1";
    newEntity.persistentID = [NSNumber numberWithInt:1];
    [tmp addObject:newEntity];
    
    
    newEntity = (MediaItem *)[NSEntityDescription insertNewObjectForEntityForName:kEntityNameMediaItem
                                                                      inManagedObjectContext:self.managedObjectContext];
    
    newEntity.title = @"song title 2";
    newEntity.persistentID = [NSNumber numberWithInt:2];
    [tmp addObject:newEntity];

    [self.managedObjectContext save:nil];
    return tmp;
}
#endif

@end
