//
//  MediaItem.h
//  PartyMix
//
//  Created by Roderic Campbell on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device, PlaylistItem;

@interface MediaItem : NSManagedObject

@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleFirstLetter;
@property (nonatomic, retain) Device *deviceHome;
@property (nonatomic, retain) NSSet *playlistItems;
@end

@interface MediaItem (CoreDataGeneratedAccessors)

- (void)addPlaylistItemsObject:(PlaylistItem *)value;
- (void)removePlaylistItemsObject:(PlaylistItem *)value;
- (void)addPlaylistItems:(NSSet *)values;
- (void)removePlaylistItems:(NSSet *)values;

@end
