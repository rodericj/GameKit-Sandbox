//
//  RJMusicManager.h
//  PartyMix
//
//  Created by Roderic Campbell on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"

@interface RJMusicManager : NSObject

@property (nonatomic, retain) Playlist *playlist;
- (void)playNextTrack;
- (void)playPreviousTrack;
- (void)playCurrentTrack;

+ (RJMusicManager *)sharedInstance;

@end
