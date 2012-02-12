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

- (IBAction)playButtonPressed:(id)sender {
    NSLog(@"play pressed");
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
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
