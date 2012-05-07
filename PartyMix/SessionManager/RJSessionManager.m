//
//  RJSessionManager.m
//  PartyMix
//
//  Created by Roderic Campbell on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RJSessionManager.h"
#import "DataModel.h"
#import "PayloadTranslator.h"

//commands

#define kSessionName                    @"com.rodericj.partymix.session"

#define unavailable                     @"Unavailable"


@interface RJSessionManager ()
//Server
@property (nonatomic, assign)           id <GKSessionDelegate>      sessionDelegate;

@end

@implementation RJSessionManager

//Server
@synthesize session         = _Session;
@synthesize sessionDelegate = _sessionDelegate;

//+(RJSessionManager *)sharedInstance {
//    NSAssert(FALSE, @"RJSessionManager should not be called");
//    if (_sessionManager == nil) {
//        _sessionManager = [[super allocWithZone:NULL] init];
//    }
//    return _sessionManager;
//}


#pragma mark -

- (void)toggleServerAvailabilty {
    [self disconnect];
    
    // Tell the data Model that the server availability button was pressed
    //If we have no session at this point, then start server    
    if (!self.session) {
        NSString *displayName = nil;
#if TARGET_IPHONE_SIMULATOR
        displayName = @"John Doe's iPhone Simulator";
#endif
        self.session = [[[GKSession alloc] initWithSessionID:kSessionName 
                                                 displayName:displayName 
                                                 sessionMode:GKSessionModeServer] autorelease];
        self.session.delegate = self;
        [self.session setDataReceiveHandler:self withContext:nil];
        [DataModel sharedInstance].localDevice.isServer = [NSNumber numberWithBool:YES];

    }
    BOOL available = self.session.available;
    self.session.available = !available;
}

-(void)handleConnected:(Device *) device {
    NSLog(@"handle connected not implemented");
}

-(void)handleDisconnect:(Device *) device  {
    device.isServer = [NSNumber numberWithBool:NO];
}

- (void)handleUnavailable:(Device *) device {
    NSLog(@"the peer %@ is unavailable", device.deviceName);
    device.state = [NSNumber numberWithInt:GKPeerStateUnavailable];
}

#pragma mark -

#pragma mark - GKSessionDelegate
/* Indicates a state change for the given peer.
 */
- (void)session:(GKSession *)aSession peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    NSLog(@"The session state changed %@ %@ %d", peerID, [self.session displayNameForPeer:peerID], state);
    NSString *deviceName = [aSession displayNameForPeer:peerID];
    Device *device = [[DataModel sharedInstance] fetchOrInsertDeviceWithPeerId:peerID
                                                                    deviceName:deviceName];
    NSLog(@"We had %@, now we have %@", peerID, device.peerId);
    device.state = [NSNumber numberWithInt:state];
    [[DataModel sharedInstance] save];
    
    switch (state) {
        case GKPeerStateAvailable: {
            
            //Handle an odd situation where the session returns nil for the peer
            NSString *displayName = [self.session displayNameForPeer:peerID];
            NSLog(@"a new peer is available %@", displayName);
            device.isServer = [NSNumber numberWithInt:YES];
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
    NSAssert(displayName, @"Display name must not be nil if we got a connection request from them");
}

#pragma mark - protocol calls



#pragma mark - remoteFetchAllSongsByArtistCall: Client call



#pragma mark remoteFetchAllSongsByArtistCall: Server call

#pragma mark Session Data


/* Indicates a connection error occurred with a peer, which includes connection request failures, or disconnects due to timeouts.
 */
- (void)session:(GKSession *)thisSession connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    NSLog(@"connectionWithPeerFailed %@, %@ %@", thisSession.displayName, peerID, error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Connecting"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok" 
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

/* Indicates an error occurred with the session such as failing to make available.
 */
- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"GKSession didFailWithError %@", error);
}

#pragma  mark - private methods
- (BOOL)isListening {
    return (self.session.available && (self.session.sessionMode == GKSessionModeServer));
}

- (void)findServer {
    //Do nothing if we are the server or have a session
    if (self.session) {
        [self disconnect];
    }
    NSString *displayName = nil;
#if TARGET_IPHONE_SIMULATOR
    displayName = @"John Doe's iPhone Simulator";
#endif

    self.session = [[[GKSession alloc] initWithSessionID:kSessionName 
                                             displayName:displayName 
                                             sessionMode:GKSessionModeClient] autorelease];
    self.session.delegate = self;
    self.session.available = YES;
    [DataModel sharedInstance].localDevice.isServer = [NSNumber numberWithBool:NO];
    [self.session setDataReceiveHandler:self 
                            withContext:nil];
}
#pragma  mark -
- (Device *)currentServer {
    return [[DataModel sharedInstance] currentServerWithState:GKPeerStateConnected];
}

- (void)disconnect {
    [DataModel sharedInstance].localDevice.isServer = [NSNumber numberWithBool:NO];
    self.session.available = NO;
    self.session.delegate = nil;
    [self.session disconnectFromAllPeers];
    self.session = nil;
    
    NSArray *connectedPeers = [[DataModel sharedInstance] fetchPeersWithState:GKPeerStateConnected];
    for (Device *peer in connectedPeers) {
        peer.state = [NSNumber numberWithInt:GKPeerStateDisconnected];
        peer.isServer = [NSNumber numberWithBool:NO];
    }
    [[DataModel sharedInstance] save];
}

- (void)denySessionRequestFrom:(Device *)device {
    NSString *peerId = device.peerId;
    [self.session denyConnectionFromPeer:peerId];
    device.state = [NSNumber numberWithInt:GKPeerStateDisconnected];
}

- (NSError *)handleSessionRequestFrom:(Device *)device {
    NSError *error = nil;
    [self.session acceptConnectionFromPeer:device.peerId
                                     error:&error];
    
    return error;
}

- (NSError *)sendPayload:(NSData *)payload toDevice:(Device *)device{
    NSError *error = nil;
//    if ([DataModel sharedInstance].localDevice.isServer) {    
//        [self.session sendDataToAllPeers:payload 
//                            withDataMode:GKSendDataReliable 
//                                   error:&error];
//    }
//    else {
    NSArray *peer = [NSArray arrayWithObject:device.peerId];
    [self.session sendData:payload
                   toPeers:peer 
              withDataMode:GKSendDataReliable error:&error];
    //}
    
    return error;
}

- (NSString *)displayNameForPeer:(NSString *)peerId {
    //NSLog(@"DisplayNameForPeer: peerId is %@ display name for peer is %@", peerId, [self.session displayNameForPeer:peerId]);
    NSString *displayName = [self.session displayNameForPeer:peerId];
    
    return displayName;
}

- (void)connectToPeer:(Device *)device {
    [self.session connectToPeer:device.peerId withTimeout:10];
}


@end
