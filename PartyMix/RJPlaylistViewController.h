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

@interface RJPlaylistViewController : FetchedResultsBackedTableViewController {
    Playlist *_playlist;
}

+ (RJPlaylistViewController *)RJPlaylistViewControllerWithPlaylist:(Playlist *)playlist;
@end
