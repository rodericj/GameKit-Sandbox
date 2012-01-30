//
//  PlaylistItem.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device, MediaItem, Playlist;

@interface PlaylistItem : NSManagedObject

@property (nonatomic, retain) NSDate * addedDate;
@property (nonatomic, retain) Device *device;
@property (nonatomic, retain) MediaItem *mediaItem;
@property (nonatomic, retain) Playlist *playlist;

@end
