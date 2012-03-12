//
//  Device.h
//  PartyMix
//
//  Created by Roderic Campbell on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatMessage, MediaItem, PlaylistItem;

@interface Device : NSManagedObject

@property (nonatomic, retain) NSString * cachedName;
@property (nonatomic, retain) NSString * deviceName;
@property (nonatomic, retain) NSNumber * isLocalHost;
@property (nonatomic, retain) NSNumber * isServer;
@property (nonatomic, retain) NSString * peerId;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * titleFirstLetter;
@property (nonatomic, retain) NSSet *mediaItems;
@property (nonatomic, retain) NSSet *playListItems;
@property (nonatomic, retain) NSOrderedSet *messages;
@end

@interface Device (CoreDataGeneratedAccessors)

- (void)addMediaItemsObject:(MediaItem *)value;
- (void)removeMediaItemsObject:(MediaItem *)value;
- (void)addMediaItems:(NSSet *)values;
- (void)removeMediaItems:(NSSet *)values;

- (void)addPlayListItemsObject:(PlaylistItem *)value;
- (void)removePlayListItemsObject:(PlaylistItem *)value;
- (void)addPlayListItems:(NSSet *)values;
- (void)removePlayListItems:(NSSet *)values;

- (void)insertObject:(ChatMessage *)value inMessagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMessagesAtIndex:(NSUInteger)idx;
- (void)insertMessages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMessagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMessagesAtIndex:(NSUInteger)idx withObject:(ChatMessage *)value;
- (void)replaceMessagesAtIndexes:(NSIndexSet *)indexes withMessages:(NSArray *)values;
- (void)addMessagesObject:(ChatMessage *)value;
- (void)removeMessagesObject:(ChatMessage *)value;
- (void)addMessages:(NSOrderedSet *)values;
- (void)removeMessages:(NSOrderedSet *)values;
@end
