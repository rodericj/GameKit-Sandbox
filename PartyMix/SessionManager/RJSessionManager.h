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
#import "SessionManagerDataModelDelegate.h"

#define actionkey                          @"action"   
#define messagekey                          @"message"   

@interface RJSessionManager : NSObject <GKSessionDelegate> {
    //Server
    GKSession                   *session;
    
    id<GKSessionDelegate> _sessionDelegate;
    id<SessionManagerDataModelDelegate> _dataModel;
}

@property (nonatomic, retain)           GKSession                   *session;

- (void)findServer;

- (NSError *)handleSessionRequestFrom:(NSString *)devicePeerId;
- (void)denySessionRequestFrom:(Device *)device;
- (void)sendMessageToAll:(NSString *)message;


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
- (void)connectToPeer:(NSString *)devicePeerId;

#pragma mark -

- (NSError *)sendPayload:(NSData *)payload toDevice:(NSString *)device;

- (Device *)currentServer;

@end
