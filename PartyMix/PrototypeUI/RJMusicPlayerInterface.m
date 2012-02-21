//
//  RJMusicPlayerInterface.m
//  PartyMix
//
//  Created by Roderic Campbell on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RJMusicPlayerInterface.h"
#import "MediaPlayer/MPMusicPlayerController.h"

@interface RJMusicPlayerInterface ()

//TODO how to we release these
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet MPVolumeView *volumeView;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) Playlist *playlist;
@end

@implementation RJMusicPlayerInterface

@synthesize playButton = _playButton;
@synthesize nextButton = _nextButton;
@synthesize volumeView = _volumeView;
@synthesize backButton = _backButton;
@synthesize progressView = _progressView;
@synthesize playlist = _playlist;

- (IBAction)playButtonPressed:(id)sender {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    NSLog(@"play pressed %@", musicPlayer);
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    
	if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
		[musicPlayer play];
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
		[musicPlayer pause];
	}}


- (IBAction)nextButtonPressed:(id)sender {
    NSLog(@"Next button pressed");
}
- (IBAction)backButtonPressed:(id)sender {
    NSLog(@"Back button pressed");
}


@end
