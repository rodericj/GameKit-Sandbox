//
//  Playlist.h
//  PartyMix
//
//  Created by Roderic Campbell on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PlaylistItem;

@interface Playlist : NSManagedObject

@property (nonatomic, retain) NSNumber * currentTrack;
@property (nonatomic, retain) NSNumber * isCurrent;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *playlistItems;
@end

@interface Playlist (CoreDataGeneratedAccessors)

- (void)addPlaylistItemsObject:(PlaylistItem *)value;
- (void)removePlaylistItemsObject:(PlaylistItem *)value;
- (void)addPlaylistItems:(NSSet *)values;
- (void)removePlaylistItems:(NSSet *)values;

@end
