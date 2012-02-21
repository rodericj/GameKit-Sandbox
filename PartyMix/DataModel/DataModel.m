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
#import "NSArray+PageableArray.h"

#define kEntityNameMediaItem                    @"MediaItem"
#define kEntityNamePlaylistItem                 @"PlaylistItem"
#define kEntityNamePlaylist                     @"Playlist"
#define kEntityNameDevice                       @"Device"


#define kPartyMixCoreDataBackupTempFile         @"PartyMixBackupTemp"
#define kPartyMixCoreDataBackupFile             @"PartyMixBackup"
#define kPartyMixCoreDataFile					@"PartyMix"
#define kPartyMixCoreDataFileExtension			@"sqlite"

@interface DataModel ()
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator		*persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel				*managedObjectModel;
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

#pragma mark - core data setup
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

#pragma mark - Set up of the singleton
+(DataModel*)sharedInstance {
    if (_dataModel == nil) {
        _dataModel = [[super allocWithZone:NULL] init];
    }
    return _dataModel;
}

#pragma mark - insertion of NSManagedObjects
- (NSManagedObject *)insertNewObjectOfType:(NSString *)entityName {
    return (NSManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:self.managedObjectContext];
}

- (MediaItem *)insertNewMediaItem:(MediaItem *)mediaItem toDevice:(Device *)device {
    MediaItem *newEntity = (MediaItem *)[self insertNewObjectOfType:kEntityNameMediaItem];
    
    newEntity.title = mediaItem.title;
    newEntity.persistentID = mediaItem.persistentID;
    newEntity.deviceHome = device;
    return newEntity;
}

- (MediaItem *)insertNewMPMediaItem:(MPMediaItem *)mpMediaItem device:(Device *)device{
    MediaItem *newEntity = (MediaItem *)[self insertNewObjectOfType:kEntityNameMediaItem];
    

    newEntity.title = [mpMediaItem valueForProperty:MPMediaItemPropertyTitle];
    newEntity.persistentID = [mpMediaItem valueForProperty:MPMediaItemPropertyPersistentID];
    newEntity.deviceHome = device;

    //TODO I'm not actually storing the media item here
    //newEntity.transientMediaItem = mpMediaItem;
    return newEntity;
}

- (NSArray *)insertArrayOfMPMediaItems:(NSArray *)mediaItems device:(Device *)device{
        
    NSMutableArray *managedMediaItems = [NSMutableArray arrayWithCapacity:[mediaItems count]];
 
    for (MPMediaItem *song in mediaItems) {
        MediaItem *item = [self insertNewMPMediaItem:song device:device];
        [managedMediaItems addObject:item];
    }
    [self save];
    //save the managed object context
    return managedMediaItems;
}

- (void)updateMediaItemCollectionWithPlaylist:(Playlist *)playlist {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    NSLog(@"update media item collection. pressed %@", musicPlayer);

    NSUInteger currentlyPlayingIndex = [musicPlayer indexOfNowPlayingItem];
    NSLog(@"the currently playing song is %d", currentlyPlayingIndex);
    
   // NSMutableArray *mediaItems = [NSMutableArray arrayWithCapacity:[playlist.playlistItem count]];
    
    //TODO At this point we need to extract the media items that are in the playlist by the MPMediaItemPropertyPersistentID
    if ([playlist.playlistItem count]) {
        MPMediaQuery *query = [MPMediaQuery songsQuery];

        //TODO we need to only take the playlistItem at the current position and add this to the media player
        for (PlaylistItem *playlistItem in playlist.playlistItem) {
            NSLog(@"mediaItem %@", playlistItem.mediaItem.persistentID);
            NSNumber *persistentID = playlistItem.mediaItem.persistentID;
            MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:persistentID 
                                                                                   forProperty:MPMediaItemPropertyPersistentID];
            
            [query addFilterPredicate:predicate];
            NSArray *songs = [query items];
            NSLog(@"the items are %@", songs);

        }
        
        //query.filterPredicates = filters;
        //TODO we need to set up the playlist so that it updates to the currently playing position when we add
        // (see here: http://iphonedevelopment.blogspot.com/2009/11/update-to-mpmediaitemcollection.html )
        
        NSArray *queriedItems = [query items];
        NSLog(@"queried items %@", queriedItems);
        MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:queriedItems];
        [musicPlayer setQueueWithItemCollection:collection];
        //[musicPlayer play];
        [collection release];
        //[query release];
    }
}

/*
 * Insert an individual PlaylistItem for a given server.
 */
- (PlaylistItem *)insertNewPlaylistItem:(MediaItem *)mediaItem fromDevice:(Device *)device toPlaylist:(Playlist *)playlist {
    PlaylistItem *newPlaylistItem = (PlaylistItem *)[self insertNewObjectOfType:kEntityNamePlaylistItem];
    newPlaylistItem.device = device;
    newPlaylistItem.playlist = playlist;
    newPlaylistItem.mediaItem = mediaItem;
    newPlaylistItem.addedDate = [NSDate date];
    
    if (playlist.isCurrent) {
        [self updateMediaItemCollectionWithPlaylist:playlist];
    }
    
    return newPlaylistItem;
}

/*
 * Insert an individual Playlist with a title
 */
- (Playlist *)insertNewPlaylistWithTitle:(NSString *)title {
    Playlist *playlist = (Playlist *)[self insertNewObjectOfType:kEntityNamePlaylist];
    playlist.title = title;
    [self save];
    return playlist;
}

#if TARGET_IPHONE_SIMULATOR
- (NSArray *)insertDummyMediaItems {
    NSMutableArray *tmp = [NSMutableArray array];
    MediaItem *newEntity = (MediaItem *)[NSEntityDescription insertNewObjectForEntityForName:kEntityNameMediaItem
                                                                      inManagedObjectContext:self.managedObjectContext];
    
    newEntity.title = @"song title 1";
    newEntity.persistentID = 1;
    [tmp addObject:newEntity];
    
    
    newEntity = (MediaItem *)[NSEntityDescription insertNewObjectForEntityForName:kEntityNameMediaItem
                                                                      inManagedObjectContext:self.managedObjectContext];
    
    newEntity.title = @"song title 2";
    newEntity.persistentID = 2;
    [tmp addObject:newEntity];

    [self save];
    return tmp;
}
#endif

- (NSArray *)sortBy:(NSString *)sortBy {
    NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:sortBy
                                                         ascending:YES] autorelease];
    return [NSArray arrayWithObject:sort];
}

- (NSEntityDescription *)entityDescriptionWithName:name {
    NSEntityDescription *entity = [NSEntityDescription entityForName:name
											  inManagedObjectContext:self.managedObjectContext];
    return entity;
}

#pragma mark - Fetching of NSManagedObjects
- (NSFetchRequest *)fetchRequestForEntity:(NSString *)entity where:(NSPredicate *)predicate orderBy:(NSString *)sort {
    NSFetchRequest *theFetchRequest = [[NSFetchRequest alloc] init];	
    theFetchRequest.entity = [self entityDescriptionWithName:entity];
    theFetchRequest.predicate = predicate;
    
    if (sort) {
        theFetchRequest.sortDescriptors = [self sortBy:sort];
    }
    
    return [theFetchRequest autorelease];
}

- (Device *)fetchOrInsertLocalHostDevice {
    NSFetchRequest *theFetchRequest = [self fetchRequestForEntity:kEntityNameDevice
                                                            where:[NSPredicate predicateWithFormat:@"(isLocalHost == YES) "]
                                                          orderBy:nil];
    
	theFetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:theFetchRequest error:&error];
	
    if (error) {
        NSLog(@"There was an error when fetching %@", [error localizedDescription]);
        return nil;
    }
    
    //If we have a result, return it
    if ([results count]) {
        NSAssert([results count] == 1, @"We should only have 1 device that matches this query in Core Data");
        Device *device = [results objectAtIndex:0];
        return device;
    }
    
    //If we don't have a result, create one and return it
    Device *device = [NSEntityDescription insertNewObjectForEntityForName:kEntityNameDevice
                                                   inManagedObjectContext:self.managedObjectContext];  
    device.isLocalHost = YES;
    [self save];
    return device;
}

- (Device *)fetchOrInsertDeviceWithPeerId:(NSString *)peerId {
    
	NSFetchRequest *theFetchRequest = [self fetchRequestForEntity:kEntityNameDevice
                                                            where:[NSPredicate predicateWithFormat:@"(peerId == %@) ", peerId]
                                                          orderBy:nil];
    
	theFetchRequest.fetchLimit = 1;

    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:theFetchRequest error:&error];
	
    if (error) {
        NSLog(@"There was an error when fetching %@", [error localizedDescription]);
        return nil;
    }
    
    //If we have a result, return it
    if ([results count]) {
        return [results objectAtIndex:0];
    }
    
    //If we don't have a result, create one and return it
    Device *device = [NSEntityDescription insertNewObjectForEntityForName:kEntityNameDevice
                                                   inManagedObjectContext:self.managedObjectContext];  
    device.peerId = peerId;
    device.isLocalHost = NO;
    //device.cachedName = [self.session displayNameForPeer:peerId]; 

    [self save];
    return device;
}

- (Device *)currentServerWithState:(NSUInteger)state {
    
    NSFetchRequest *theFetchRequest = [self fetchRequestForEntity:kEntityNameDevice
                                                            where:[NSPredicate predicateWithFormat:@"(state == %d) AND (isServer == YES)", state]
                                                          orderBy:nil];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:theFetchRequest error:&error];
	
    if (error) {
        NSLog(@"There was an error when fetching %@", [error localizedDescription]);
        return nil;
    }
    
    //If we have a result, return it
    if ([results count]) {
        return [results objectAtIndex:0];
    }
    
    return nil;
}

- (Device *)localDevice {
    return [self fetchOrInsertLocalHostDevice];
}

- (NSArray *)fetchPeersWithState:(NSUInteger)state {
    NSFetchRequest *theFetchRequest = [self fetchRequestForEntity:kEntityNameDevice
                                                            where:[NSPredicate predicateWithFormat:@"(state == %d) ", state]
                                                          orderBy:nil];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:theFetchRequest error:&error];
	
    if (error) {
        NSLog(@"There was an error when fetching %@", [error localizedDescription]);
        return nil;
    }
    
    return results;
}

- (NSArray *)fetchAllLocalMedia {
    NSFetchRequest *theFetchRequest = [self fetchRequestForEntity:kEntityNameMediaItem
                                                            where:[NSPredicate predicateWithFormat:@"(deviceHome.peerId == %@) ", nil]
                                                          orderBy:@"title"];	
    
    	
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:theFetchRequest error:&error];
	
    if (error) {
        NSLog(@"There was an error when fetching %@", [error localizedDescription]);
        return nil;
    }
    
    return results;    
}

- (Playlist *)currentPlaylist {
    NSFetchRequest *theFetchRequest = [self fetchRequestForEntity:kEntityNamePlaylist
                                                            where:[NSPredicate predicateWithFormat:@"(isCurrent == YES)"]
                                                          orderBy:nil];	
    
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:theFetchRequest error:&error];
	
    if (error) {
        NSLog(@"There was an error when fetching %@", [error localizedDescription]);
        return nil;
    }
    if ([results count] == 1) {
        return [results objectAtIndex:0];
    }
    return nil;    
    
}

- (void)setCurrentPlaylist:(Playlist *)playlist {
    
    Playlist *oldCurrent = [self currentPlaylist];
    oldCurrent.isCurrent = NO;
    playlist.isCurrent = YES;
    [self updateMediaItemCollectionWithPlaylist:playlist];
}


- (Device *)deviceWithPeerId:(NSString *)peerId {
    return [self fetchOrInsertDeviceWithPeerId:peerId];
}

#pragma mark - probably should not be moved to Session code
- (void)deleteDevice:(Device *) device{
    [self.managedObjectContext deleteObject:device];
}

- (void)save {
    [self.managedObjectContext save:nil];
}

@end
