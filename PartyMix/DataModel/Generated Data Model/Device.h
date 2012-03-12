//
//  Device.h
//  PartyMix
//
//  Created by Roderic Campbell on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MediaItem, PlaylistItem;

@interface Device : NSManagedObject

@property (nonatomic, retain) NSString * cachedName;
@property (nonatomic, retain) NSNumber * isLocalHost;
@property (nonatomic, retain) NSNumber * isServer;
@property (nonatomic, retain) NSString * peerId;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * titleFirstLetter;
@property (nonatomic, retain) NSString * deviceName;
@property (nonatomic, retain) NSSet *mediaItem;
@property (nonatomic, retain) NSSet *playListItem;
@end

@interface Device (CoreDataGeneratedAccessors)

- (void)addMediaItemObject:(MediaItem *)value;
- (void)removeMediaItemObject:(MediaItem *)value;
- (void)addMediaItem:(NSSet *)values;
- (void)removeMediaItem:(NSSet *)values;

- (void)addPlayListItemObject:(PlaylistItem *)value;
- (void)removePlayListItemObject:(PlaylistItem *)value;
- (void)addPlayListItem:(NSSet *)values;
- (void)removePlayListItem:(NSSet *)values;

@end
