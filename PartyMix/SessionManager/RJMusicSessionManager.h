//
//  RJMusicSessionManager.h
//  PartyMix
//
//  Created by roderic campbell on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaItem.h"
#import "RJSessionManager.h"

@interface RJMusicSessionManager : RJSessionManager

+(RJMusicSessionManager *)sharedInstance;

- (void)requestSongsFromServer;

- (void)sendSingleSongRequest:(MediaItem *)media;



@end
