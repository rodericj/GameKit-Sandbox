//
//  Playlist.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PlaylistItem;

@interface Playlist : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *playlistItem;
@end

@interface Playlist (CoreDataGeneratedAccessors)

- (void)addPlaylistItemObject:(PlaylistItem *)value;
- (void)removePlaylistItemObject:(PlaylistItem *)value;
- (void)addPlaylistItem:(NSSet *)values;
- (void)removePlaylistItem:(NSSet *)values;

@end
