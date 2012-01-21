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
#import "PayloadTranslator.h"

#define kEntityNameMediaItem                    @"MediaItem"
#define kEntityNameDevice                       @"Device"

#define kPartyMixCoreDataBackupTempFile         @"PartyMixBackupTemp"
#define kPartyMixCoreDataBackupFile             @"PartyMixBackup"
#define kPartyMixCoreDataFile					@"PartyMix"
#define kPartyMixCoreDataFileExtension			@"sqlite"


#define kSessionName                    @"com.rodericj.partymix.session"

#define unavailable                     @"Unavailable"

@interface DataModel ()
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator		*persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel				*managedObjectModel;

//Server
@property (nonatomic, retain)           GKSession                   *session;
@property (nonatomic, assign)           BOOL                      isServer;
@property (nonatomic, retain)           NSString                   *serverPeerId;
@property (nonatomic, assign)           id <GKSessionDelegate>      sessionDelegate;

@end


@implementation DataModel

static DataModel *_dataModel = nil;

//Server
@synthesize session         = _Session;
@synthesize isServer        = _isServer;
@synthesize serverPeerId    = _serverPeerId;
@synthesize sessionDelegate = _sessionDelegate;

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
- (Device *)fetchOrInsertDeviceWithPeerId:(NSString *)peerId {
    
	NSFetchRequest *theFetchRequest = [[NSFetchRequest alloc] init];	
    
	NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(peerId == %@) ", peerId];
    theFetchRequest.predicate = filterPredicate;

	theFetchRequest.sortDescriptors = [self sortBy:@"peerId"];
	theFetchRequest.fetchLimit = 1;
	theFetchRequest.entity =[self entityDescriptionWithName:kEntityNameDevice];
	
	NSFetchedResultsController *fetchedResults;
    fetchedResults = [[[NSFetchedResultsController alloc] initWithFetchRequest:theFetchRequest 
                                                          managedObjectContext:self.managedObjectContext 
                                                            sectionNameKeyPath:nil cacheName:nil] autorelease];	
	[theFetchRequest release];
	
	if([fetchedResults performFetch:nil]) {
		//If we have a result, return it
		if ([[fetchedResults fetchedObjects] count])
			return [[fetchedResults fetchedObjects] objectAtIndex:0];
		
		//If we don't have a result, create one and return it
		else {
			Device *device = [NSEntityDescription insertNewObjectForEntityForName:kEntityNameDevice
                                                           inManagedObjectContext:self.managedObjectContext];  
            device.peerId = peerId;
            return device;
        }
	}
	
	//Something has gone wrong with the fetch
	else
		NSLog(@"Error while fetching");
	
	return nil;
}

- (NSArray *)fetchConnectedPeers {
    NSFetchRequest *theFetchRequest = [[NSFetchRequest alloc] init];	
    
	NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(state == %d) ", GKPeerStateConnected];
    theFetchRequest.predicate = filterPredicate;
    
	theFetchRequest.sortDescriptors = [self sortBy:@"peerId"];
	theFetchRequest.entity =[self entityDescriptionWithName:kEntityNameDevice];
	
	NSFetchedResultsController *fetchedResults;
    fetchedResults = [[[NSFetchedResultsController alloc] initWithFetchRequest:theFetchRequest 
                                                          managedObjectContext:self.managedObjectContext 
                                                            sectionNameKeyPath:nil cacheName:nil] autorelease];	
	[theFetchRequest release];
	
	if([fetchedResults performFetch:nil]) {
        return [fetchedResults fetchedObjects];
    } else {
		NSLog(@"Error while fetching");
	}
	return nil;
}

#pragma mark -
- (void)toggleServerAvailabilty {
    
    // Tell the data Model that the server availability button was pressed
    
    //If we have no session at this point, then start server    
    if (!self.session) {
        self.session = [[[GKSession alloc] initWithSessionID:kSessionName 
                                                 displayName:nil 
                                                 sessionMode:GKSessionModeServer] autorelease];
        self.session.delegate = self;
        [self.session setDataReceiveHandler:self withContext:nil];
        self.isServer = YES;
    }
    
    self.session.available = !self.session.available;
}

-(void)handleConnected:(Device *) device {
    //TODO if we are not the server and we connect, describe the device that is the server (probably core data)
    //TODO turn off available if we are not the server
    if (!self.isServer && !self.serverPeerId) {
        //TODO I can't set the serverPeerId here. I get 2 connections here.
        self.session.available = NO;
    }
}

-(void)handleDisconnect:(Device *) device  {
    //If it was the server, nil the server variable
    if ([device.peerId isEqualToString:self.serverPeerId]) {
        self.serverPeerId = nil;
    }

    if (![[self fetchConnectedPeers] count]) {
        self.session = nil;
        self.serverPeerId = nil;
    }
    [self.managedObjectContext deleteObject:device];
    [self save];
}

- (void)handleUnavailable:(Device *) device {
    NSLog(@"the peer %@ is unavailable", device.peerId);
}

#pragma mark - GKSessionDelegate
/* Indicates a state change for the given peer.
 */
- (void)session:(GKSession *)aSession peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    NSLog(@"The session state changed %@ %d", [self.session displayNameForPeer:peerID], state);
    Device *device = [self fetchOrInsertDeviceWithPeerId:peerID];
    device.state = state;
    [self.managedObjectContext save:nil];
    
    switch (state) {
        case GKPeerStateAvailable: {
            
            //Handle an odd situation where the session returns nil for the peer
            NSString *displayName = [self.session displayNameForPeer:peerID];
            device.isServer = YES;
            if (!displayName) {
                NSAssert(false, @"I think this should never happen. no display name and available");
                return;
            }
            break;
        }
        case GKPeerStateConnected:
            [self handleConnected:device];
            NSLog(@"the session is now connected to: %@, %@ Do what you need to do.", aSession.displayName, peerID);
            break;
            
        case GKPeerStateDisconnected:
            [self handleDisconnect:device];
            break;
            
        case GKPeerStateConnecting:

            break;
            
        case GKPeerStateUnavailable:
            [self handleUnavailable:device];
            break;
        default:
            break;
    }
    // No need to send this data to the views, they have fetched results controllers for that
    //[self.sessionDelegate session:aSession peer:peerID didChangeState:state];
    
}

/* Indicates a connection request was received from another peer. 
 
 Accept by calling -acceptConnectionFromPeer:
 Deny by calling -denyConnectionFromPeer:
 */
- (void)session:(GKSession *)aSession didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    //TODO There may be a way to have this function notify the clients instead of the FetchedResultsController way
    NSLog(@"The session %@ didReceiveConnectionRequestFromPeer %@", aSession.displayName, peerID);
    NSString *displayName = [self.session displayNameForPeer:peerID];
    NSLog(@"displayName for peer: %@", displayName);
    NSAssert(displayName, @"Display name must not be nil");
}

#pragma mark Session Data
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    NSDictionary *dict = [PayloadTranslator extractDictionaryFromPayload:data];
    NSString *messageString = [dict objectForKey:@"message"];
    NSLog(@"we got some data %@", messageString);
    
    NSString *action = [dict objectForKey:@"action"];
    if (action) {
        [self performSelector:NSSelectorFromString([dict objectForKey:@"action"])];
    }
    
    //[self.sessionDelegate 
}

/* Indicates a connection error occurred with a peer, which includes connection request failures, or disconnects due to timeouts.
 */
- (void)session:(GKSession *)thisSession connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    NSLog(@"connectionWithPeerFailed %@, %@ %@", thisSession.displayName, peerID, error);
}

/* Indicates an error occurred with the session such as failing to make available.
 */
- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"GKSession didFailWithError %@", error);
}

- (BOOL)isSessionAvailable {
    return self.session.available;
}

- (void)findServer {
    //Do nothing if we are the server or have a session
    if (self.session) {
        return;
    }
    self.session = [[[GKSession alloc] initWithSessionID:kSessionName 
                                             displayName:nil 
                                             sessionMode:GKSessionModeClient] autorelease];
    self.session.delegate = self;
    self.session.available = YES;
    self.isServer = NO;
    [self.session setDataReceiveHandler:self withContext:nil];
}

- (void)disconnect {
    self.serverPeerId = nil;
    self.isServer = NO;
    [self.session disconnectFromAllPeers];
    self.session = nil;
    
    NSArray *connectedPeers = [self fetchConnectedPeers];
    for (Device *peer in connectedPeers) {
        peer.state = GKPeerStateDisconnected;
    }
    [self save];
}

#pragma mark SERVER
- (NSError *)handleSessionRequestFrom:(Device *)device {
    NSError *error = nil;
    [self.session acceptConnectionFromPeer:device.peerId
                                     error:&error];

    return error;
}

- (NSError *)sendPayload:(NSData *)payload {
    NSError *error = nil;
    if (self.isServer) {    
        [self.session sendDataToAllPeers:payload 
                            withDataMode:GKSendDataReliable 
                                   error:&error];
    }
    else {
        NSArray *peer = [NSArray arrayWithObject:self.serverPeerId];
        [self.session sendData:payload
                       toPeers:peer 
                  withDataMode:GKSendDataReliable error:&error];
    }
    
    return error;
}

- (NSString *)displayNameForPeer:(NSString *)peerId {
    
    NSString *displayName = [self.session displayNameForPeer:peerId];
    return displayName;
    
}

- (void)connectToPeer:(Device *)device {
    [self.session connectToPeer:device.peerId withTimeout:10];
}

- (void)save {
    [self.managedObjectContext save:nil];
}
//self.serverPeerId   = nil;

@end
