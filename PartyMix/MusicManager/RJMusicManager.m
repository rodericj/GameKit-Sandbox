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

+ (RJMusicManager *)sharedInstance {
    if (_musicManager == nil) {
        _musicManager = [[super allocWithZone:NULL] init];
        MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        [musicPlayer setShuffleMode:MPMusicShuffleModeOff];
        [musicPlayer setRepeatMode:MPMusicRepeatModeAll];
        [musicPlayer beginGeneratingPlaybackNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:_musicManager 
                                                 selector:@selector(musicChanged:) 
                                                     name:MPMusicPlayerControllerPlaybackStateDidChangeNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:_musicManager 
                                                 selector:@selector(handleNowPlayingChanged:) 
                                                     name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification 
                                                   object:nil];
        
        
        
        //Need to observe the current playlist
        if ([[DataModel sharedInstance] currentPlaylist]) {
            _musicManager.playlist = [[DataModel sharedInstance] currentPlaylist];
        }
    }
    return _musicManager;
}
- (void)handleNowPlayingChanged:(NSNotification *)notification {
    //NSLog(@"now playing has changed");
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    NSLog(@"after a change the now playing is %d", musicPlayer.indexOfNowPlayingItem);
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

- (void)playNextTrack {
    // TODO obviously this needs to be revisited
    //self.playlist.currentTrack = (self.playlist.currentTrack+1) % [self.playlist.playlistItem count];
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    [musicPlayer skipToNextItem];
    //[self playCurrentTrack];
}

- (void)playPreviousTrack {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    [musicPlayer skipToPreviousItem];
    self.playlist.currentTrack = [NSNumber numberWithInt:[self.playlist.currentTrack intValue] - 1];
    if (self.playlist.currentTrack < 0) {
        self.playlist.currentTrack = 0;
    }
    [self playCurrentTrack];
}

- (void)playCurrentTrack {
    
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    NSLog(@"play pressed %@", musicPlayer);
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    
    
    if([self.playlist.currentTrack intValue] == -1){
        NSLog(@"nothing is playing");
        self.playlist.currentTrack = 0;
        [musicPlayer skipToBeginning];        
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
