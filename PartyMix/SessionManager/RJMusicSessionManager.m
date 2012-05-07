//
//  RJMusicSessionManager.m
//  PartyMix
//
//  Created by roderic campbell on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RJMusicSessionManager.h"
#import "PayloadTranslator.h"
#import "Device.h"
#import "DataModel.h"

#define remoteFetchAllSongsByArtistCall       @"remoteFetchAllSongsByArtistMethod:"
#define actionkey                          @"action"   
#define mediakey                       @"media key"
#define sendSingleSongRequestCall       @"sendSingleSongMethod:"
#define messagekey                          @"message"   
#define sendMessageCall       @"sendMessageMethod:"
#define addMediaFromListCall       @"addMediaFromListMethod:"

@implementation RJMusicSessionManager
static RJMusicSessionManager *_sessionManager = nil;

+(RJMusicSessionManager *)sharedInstance {
    if (_sessionManager == nil) {
        _sessionManager = [[super allocWithZone:NULL] init];
    }
    return _sessionManager;
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    NSDictionary *dict = [PayloadTranslator extractDictionaryFromPayload:data];
    
    //NSLog(@"we got some data %@", dict);
    NSArray *packagedWithPeer = [NSArray arrayWithObjects:peer, dict, nil];
    NSString *executeAction = [dict objectForKey:actionkey];
    if (executeAction) {
        [self performSelector:NSSelectorFromString(executeAction) withObject:packagedWithPeer];
    }
}

- (void)sendMessageMethod:(NSArray *)payload {
    NSString *message = [[payload objectAtIndex:1] objectForKey:messagekey];
    NSLog(@"a message was sent: %@", message);
    NSString *deviceDisplayName = [[RJMusicSessionManager sharedInstance].session displayNameForPeer:[payload objectAtIndex:0]];
    
    Device *device = [[DataModel sharedInstance] fetchOrInsertDeviceWithPeerId:[payload objectAtIndex:0]
                                                                    deviceName:deviceDisplayName];
    
    [[DataModel sharedInstance] insertNewMessage:message fromDevice:device];
}

- (void)sendSingleSongMethod:(NSArray *)payload {
    NSDictionary *data = [payload objectAtIndex:1];
    NSString *peerId = [payload objectAtIndex:0];
    MediaItem *mediaItem = [data objectForKey:mediakey];
    Playlist *playlist = [[DataModel sharedInstance] currentPlaylist];
    
    NSString *deviceName = [[RJMusicSessionManager sharedInstance] displayNameForPeer:peerId];
    Device *device = [[DataModel sharedInstance] deviceWithName:deviceName];
    [[DataModel sharedInstance] insertNewPlaylistItem:mediaItem 
                                           fromDevice:device 
                                           toPlaylist:playlist];
}

- (void)sendMessageToAll:(NSString *)message {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setObject:message 
             forKey:messagekey];
    [dict setObject:sendMessageCall 
             forKey:actionkey];
    
    NSString *peerId = [RJMusicSessionManager sharedInstance].session.peerID;
    Device *me = [[DataModel sharedInstance] fetchOrInsertDeviceWithPeerId:peerId deviceName:@"Me"];
    
    [[DataModel sharedInstance] insertNewMessage:message fromDevice:me];
    NSData *data = [PayloadTranslator buildPayLoadWithDictionary:dict];
    
    NSArray *devices = [[DataModel sharedInstance] fetchPeersWithState:GKPeerStateConnected];
    for (Device *device in devices) {
        [[RJMusicSessionManager sharedInstance] sendPayload:data toDevice:device];
    }
    
}

- (void)remoteFetchAllSongsByArtistMethod:(NSArray *)packagedWithPeer {
    
    NSString *peerId = [packagedWithPeer objectAtIndex:0];
    
    NSString *deviceName = [[RJMusicSessionManager sharedInstance].session displayNameForPeer:peerId];
    Device *device = [[DataModel sharedInstance] fetchOrInsertDeviceWithPeerId:peerId 
                                                                    deviceName:deviceName];
    NSArray *media = [[DataModel sharedInstance] fetchAllLocalMedia];
    
    NSUInteger pageSize = 10;
    
    NSMutableArray *currentPackage = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < [media count]; i++) {
        [currentPackage addObject:[media objectAtIndex:i]];
        
        if ([currentPackage count] == pageSize) {
            NSMutableDictionary *payloadData = [NSMutableDictionary dictionary];
            [payloadData setObject:currentPackage 
                            forKey:mediakey];
            [payloadData setObject:addMediaFromListCall
                            forKey:actionkey];
            
            NSData *data = [PayloadTranslator buildPayLoadWithDictionary:payloadData];
            [[RJMusicSessionManager sharedInstance] sendPayload:data toDevice:device];
            currentPackage = nil;
            currentPackage = [NSMutableArray arrayWithCapacity:10];
        }
    }
}

- (void)addMediaFromListMethod:(NSArray *)packagedWithPeer {
    NSString *peerId = [packagedWithPeer objectAtIndex:0];
    NSString *deviceName = [[RJMusicSessionManager sharedInstance].session displayNameForPeer:peerId];
    Device *owner = [[DataModel sharedInstance] fetchOrInsertDeviceWithPeerId:peerId
                                                                   deviceName:deviceName];
    
    NSDictionary *data = [packagedWithPeer objectAtIndex:1];
    //NSLog(@"items are from %@\n %@", peerId, data);
    
    NSArray *mediaItems = [data objectForKey:mediakey];
    for (MediaItem *m in mediaItems) {
        [[DataModel sharedInstance] insertNewMediaItem:m toDevice:owner];
    }
    // TODO should I save here. It will take a long time, but is it better here than somewhere else? For now it's out
    //[self save];
}

- (void)requestSongsFromServer {
    NSLog(@"request tracks from server");
    Device *server =  [[RJMusicSessionManager sharedInstance] currentServer];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:remoteFetchAllSongsByArtistCall 
             forKey:actionkey];
    
    
    NSData *data = [PayloadTranslator buildPayLoadWithDictionary:dict];
    
    [[RJMusicSessionManager sharedInstance] sendPayload:data toDevice:server];
}

- (void)sendSingleSongRequest:(MediaItem *)media {
    RJMusicSessionManager *sessionManager = [RJMusicSessionManager sharedInstance];
    Device *server = sessionManager.currentServer;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setObject:media 
             forKey:mediakey];
    [dict setObject:sendSingleSongRequestCall 
             forKey:actionkey];
    
    NSData *data = [PayloadTranslator buildPayLoadWithDictionary:dict];
    
    [sessionManager sendPayload:data 
                       toDevice:server];
}
@end
