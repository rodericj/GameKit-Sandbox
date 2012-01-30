//
//  DataModel.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Device.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Playlist.h"
#import "PlaylistItem.h"

@protocol MessageRecipient <NSObject>

@required
-(void)newMessage:(NSDictionary *)data;
@end

@interface DataModel : NSObject <GKSessionDelegate> {
	NSPersistentStoreCoordinator        *_persistentStoreCoordinator;
	NSManagedObjectModel                *_managedObjectModel;
	NSManagedObjectContext              *_managedObjectContext;	
    
    //Server
    GKSession                   *session;
    
    BOOL                    _isServer;
    NSString                *_serverPeerId;
    id<GKSessionDelegate> _sessionDelegate;
}

+ (DataModel*)sharedInstance;

- (Playlist *)currentPlaylist;

- (void)setCurrentPlaylist:(Playlist *)playlist;
/* 
 * Given the array of MPMediaItems, insert these into CoreData 
 * Attach to the passed in device.
 * If the device is nil, we can assume the owner is self
 */
- (NSArray *)insertArrayOfMPMediaItems:(NSArray *)mediaItems device:(Device *)device;

/*
 * Insert an individual MPMediaItem for a given server. Used with insertArrayOfMPMediaItems:device:
 */
- (MediaItem *)insertNewMPMediaItem:(MPMediaItem *)mpMediaItem device:(Device *)device;

/*
 * Insert an individual PlaylistItem for a given server.
 */
- (PlaylistItem *)insertNewPlaylistItem:(MediaItem *)mediaItem fromDevice:(Device *)device toPlaylist:(Playlist *)playlist;

/*
 * Insert an individual Playlist with a title
 */
- (Playlist *)insertNewPlaylistWithTitle:(NSString *)playlistItem;

/*
 * Fetch the current server that this device is connected to
 */
- (Device *)currentServer;

/*
 * The device object representing the current device
 */
- (Device *)localDevice;
    
- (void)findServer;
- (NSError *)handleSessionRequestFrom:(Device *)device;

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/*
 * Change the state of the session object to listening or not
 */
- (void)toggleServerAvailabilty;


- (BOOL)isSessionAvailable;

/*
 * Disconnect
 */
- (void)disconnect;

/*
 * Given the encryptic peerId of a device, convert this to 
 * a more human readable device name.
 */
- (NSString *)displayNameForPeer:(NSString *)peerId;

- (Device *)deviceWithPeerId:(NSString *)peerId;

/*
 * Given a device, attempt to make a connection to it's session
 */
- (void)connectToPeer:(Device *)device;

#pragma mark -
- (void)requestSongsFromServer;

- (void)sendSingleSongRequest:(MediaItem *)media;

- (NSError *)sendPayload:(NSData *)payload toDevice:(Device *)device;

- (void)save;
#if TARGET_IPHONE_SIMULATOR
- (NSArray *)insertDummyMediaItems;
#endif
@end
