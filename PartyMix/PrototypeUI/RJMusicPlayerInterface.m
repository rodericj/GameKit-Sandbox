//
//  RJMusicPlayerInterface.m
//  PartyMix
//
//  Created by Roderic Campbell on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RJMusicPlayerInterface.h"
#import "MediaPlayer/MPMusicPlayerController.h"
#import "MediaItem.h"
#import "PlaylistItem.h"
@interface RJMusicPlayerInterface ()

//TODO how to we release these
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet MPVolumeView *volumeView;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@end

@implementation RJMusicPlayerInterface

@synthesize playButton = _playButton;
@synthesize nextButton = _nextButton;
@synthesize volumeView = _volumeView;
@synthesize backButton = _backButton;
@synthesize progressView = _progressView;
@synthesize playlist = _playlist;

- (void)putCurrentTrackIntoMusicPlayer {
    //TODO add this to a category on the playlist called currentPlaylistItem
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
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

- (IBAction)playButtonPressed:(id)sender {
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
	}}


- (IBAction)nextButtonPressed:(id)sender {
    NSLog(@"Next button pressed");
    self.playlist.currentTrack++;
    [self putCurrentTrackIntoMusicPlayer];
    [self playButtonPressed:nil];

}
- (IBAction)backButtonPressed:(id)sender {
    NSLog(@"Back button pressed");
    self.playlist.currentTrack--;
    [self putCurrentTrackIntoMusicPlayer];
    [self playButtonPressed:nil];
}


@end
