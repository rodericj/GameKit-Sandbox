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
    NSString                *_PendingPeerId;
    
    BOOL                    _isServer;
    NSString                *_serverPeerId;
        
    NSMutableArray          *_peersConnected;

    id<GKSessionDelegate> _sessionDelegate;
}

+ (DataModel*)sharedInstance;
- (NSArray *)insertArrayOfMPMediaItems:(NSArray *)mediaItems;
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

/*
 * Given a device, attempt to make a connection to it's session
 */
- (void)connectToPeer:(Device *)device;


- (NSError *)sendPayload:(NSData *)payload;

- (void)save;
#if TARGET_IPHONE_SIMULATOR
- (NSArray *)insertDummyMediaItems;
#endif
@end
