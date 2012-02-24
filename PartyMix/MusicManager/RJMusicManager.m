//
//  RJMusicManager.m
//  PartyMix
//
//  Created by Roderic Campbell on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RJMusicManager.h"
#import "MediaPlayer/MPMusicPlayerController.h"
#import "MPMediaItemCollection+Utils.h"
#import "MediaItem.h"
#import "PlaylistItem.h"
#import "DataModel.h"

@implementation RJMusicManager

static RJMusicManager *_musicManager = nil;

@synthesize playlist = _playlist;

- (void)setPlaylist:(Playlist *)playlist {
    if (playlist == _playlist) {
        return;
    }
    if (self.playlist) {
        [self.playlist removeObserver:self forKeyPath:@"isCurrent"];
    }
    [playlist addObserver:self 
               forKeyPath:@"isCurrent"
                  options:NSKeyValueObservingOptionNew 
                  context:nil];
    _playlist = playlist;
}

+ (RJMusicManager *)sharedInstance {
    if (_musicManager == nil) {
        _musicManager = [[super allocWithZone:NULL] init];
        MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        [musicPlayer beginGeneratingPlaybackNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:_musicManager 
                                                 selector:@selector(musicChanged:) 
                                                     name:MPMusicPlayerControllerPlaybackStateDidChangeNotification 
                                                   object:nil];
        
        //Need to observe the current playlist
        if ([[DataModel sharedInstance] currentPlaylist]) {
            _musicManager.playlist = [[DataModel sharedInstance] currentPlaylist];
        }
    }
    return _musicManager;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqual:@"isCurrent"]) {
        self.playlist = [DataModel sharedInstance].currentPlaylist;
    }
}

- (void)musicChanged:(NSNotification *)notification {
    NSLog(@"the music changed %@", notification);
 
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    switch(musicPlayer.playbackState) {
        case MPMusicPlaybackStatePaused:
            NSLog(@"paused");
            break;
        case MPMusicPlaybackStateInterrupted:
            NSLog(@"interrupted");
            break;
        case MPMusicPlaybackStatePlaying:
            NSLog(@"playing");
            break;
        case MPMusicPlaybackStateSeekingBackward:
            NSLog(@"seek backward");
            break;
        case MPMusicPlaybackStateSeekingForward:
            NSLog(@"seek forward");
            break;
        default:
            break;
    }

}

- (void)putCurrentTrackIntoMusicPlayer {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    //TODO add this to a category on the playlist called currentPlaylistItem
    PlaylistItem *item = [[self.playlist.playlistItem allObjects] objectAtIndex:self.playlist.currentTrack];
    
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    NSLog(@"mediaItem %@", item.mediaItem.persistentID);
    NSNumber *persistentID = item.mediaItem.persistentID;
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:persistentID 
                                                                           forProperty:MPMediaItemPropertyPersistentID];
    
    [query addFilterPredicate:predicate];
    
    NSArray *queriedItems = [query items];
    NSLog(@"queried items %@", queriedItems);
    MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:queriedItems];
    [musicPlayer setQueueWithItemCollection:collection];
    [collection release];
}

- (void)playNextTrack {
    // TODO obviously this needs to be revisited
    self.playlist.currentTrack = (self.playlist.currentTrack+1) % [self.playlist.playlistItem count];
    [self putCurrentTrackIntoMusicPlayer];
    [self playCurrentTrack];
}

- (void)playPreviousTrack {
    self.playlist.currentTrack--;
    if (self.playlist.currentTrack < 0) {
        self.playlist.currentTrack = 0;
    }
    [self putCurrentTrackIntoMusicPlayer];
    [self playCurrentTrack];
}

- (void)playCurrentTrack {
    
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    NSLog(@"play pressed %@", musicPlayer);
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    
    
    if(self.playlist.currentTrack == -1){
        NSLog(@"nothing is playing");
        self.playlist.currentTrack = 0;
        [self putCurrentTrackIntoMusicPlayer];
    }
    
	if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
		[musicPlayer play];
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
		[musicPlayer pause];
	}     
}

- (void)songFinished:(NSNotification *)notification {
    NSLog(@"A song has finished, we should play the next song");
    [self playNextTrack];
}

- (void)dealloc {    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.playlist = nil;
    [super dealloc];
}

@end
