//
//  Device.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MediaItem;

@interface Device : NSManagedObject

@property (nonatomic, retain) NSString * deviceId;
@property (nonatomic, retain) NSSet *mediaItem;
@end

@interface Device (CoreDataGeneratedAccessors)

- (void)addMediaItemObject:(MediaItem *)value;
- (void)removeMediaItemObject:(MediaItem *)value;
- (void)addMediaItem:(NSSet *)values;
- (void)removeMediaItem:(NSSet *)values;

@end
