//
//  MediaItem.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device, PlaylistItem;

@interface MediaItem : NSManagedObject

@property (nonatomic, retain) NSData * mediaItem;
@property (nonatomic) int64_t persistentID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleFirstLetter;
@property (nonatomic, retain) Device *deviceHome;
@property (nonatomic, retain) NSSet *playlistItem;
@end

@interface MediaItem (CoreDataGeneratedAccessors)

- (void)addPlaylistItemObject:(PlaylistItem *)value;
- (void)removePlaylistItemObject:(PlaylistItem *)value;
- (void)addPlaylistItem:(NSSet *)values;
- (void)removePlaylistItem:(NSSet *)values;

@end
