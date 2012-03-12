//
//  RJSessionManager.h
//  PartyMix
//
//  Created by Roderic Campbell on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Device.h"

@interface RJSessionManager : NSObject <GKSessionDelegate> {
    //Server
    GKSession                   *session;
    
    id<GKSessionDelegate> _sessionDelegate;
}

+(RJSessionManager *)sharedInstance;

- (void)findServer;

- (NSError *)handleSessionRequestFrom:(Device *)device;
- (void)denySessionRequestFrom:(Device *)device;


/*
 * Change the state of the session object to listening or not
 */
- (void)toggleServerAvailabilty;

/* 
 * Returns true if this session is listening for connection requests from remote peers
 */
- (BOOL)isListening;

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

#pragma mark -
- (void)requestSongsFromServer;

- (void)sendSingleSongRequest:(MediaItem *)media;

- (NSError *)sendPayload:(NSData *)payload toDevice:(Device *)device;

- (Device *)currentServer;

@end
