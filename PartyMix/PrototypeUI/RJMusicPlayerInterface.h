//
//  RJMusicPlayerInterface.h
//  PartyMix
//
//  Created by Roderic Campbell on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaPlayer/MPVolumeView.h"
#import "Playlist.h"

@interface RJMusicPlayerInterface : UIView {
    UIButton *_playButton;
    UIButton *_backButton;
    UIButton *_nextButton;
    MPVolumeView *_volumeView;
    UIProgressView *_progressView;
    Playlist *_playlist;
}

- (IBAction)playButtonPressed:(id)sender;
- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)backButtonPressed:(id)sender;

@property (nonatomic, retain) Playlist *playlist;

@end
