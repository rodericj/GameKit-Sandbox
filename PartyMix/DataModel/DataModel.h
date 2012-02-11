//
//  DataModel.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Playlist.h"
#import "PlaylistItem.h"

@protocol MessageRecipient <NSObject>

@required
-(void)newMessage:(NSDictionary *)data;
@end

@interface DataModel : NSObject  {
	NSPersistentStoreCoordinator        *_persistentStoreCoordinator;
	NSManagedObjectModel                *_managedObjectModel;
	NSManagedObjectContext              *_managedObjectContext;	

}

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (Device *)deviceWithPeerId:(NSString *)peerId;

- (NSArray *)fetchPeersWithState:(NSUInteger)state;

- (Device *)fetchOrInsertDeviceWithPeerId:(NSString *)peerId;

- (NSArray *)fetchAllLocalMedia;

+ (DataModel*)sharedInstance;

- (Playlist *)currentPlaylist;

- (void)setCurrentPlaylist:(Playlist *)playlist;
/* 
 * Given the array of MPMediaItems, insert these into CoreData 
 * Attach to the passed in device.
 * If the device is nil, we can assume the owner is self
 */
- (NSArray *)insertArrayOfMPMediaItems:(NSArray *)mediaItems device:(Device *)device;

- (MediaItem *)insertNewMediaItem:(MediaItem *)mediaItem toDevice:(Device *)device;

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
- (Device *)currentServerWithState:(NSUInteger)state;

/*
 * The device object representing the current device
 */
- (Device *)localDevice;
    
- (void)deleteDevice:(Device *)device;

- (void)save;
#if TARGET_IPHONE_SIMULATOR
- (NSArray *)insertDummyMediaItems;
#endif
@end
