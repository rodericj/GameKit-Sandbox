//
//  RJPlaylistViewController.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "FetchedResultsBackedTableViewController.h"
#import "RJMusicPlayerInterface.h"

@interface RJPlaylistViewController : FetchedResultsBackedTableViewController {
    Playlist *_playlist;
    RJMusicPlayerInterface *_musicInterface;
}

+ (RJPlaylistViewController *)RJPlaylistViewControllerWithPlaylist:(Playlist *)playlist;
@end
