//
//  MediaItem+Additions.m
//  PartyMix
//
//  Created by Roderic Campbell on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MediaItem+Additions.h"
#import "DataModel.h"

#define kAttributeNameTitle @"kAttributeNameTitle"
#define kAttributeNamePersistentID @"kAttributeNamePersistentID"
#define kAttributeNameMediaItem @"kAttributeNameMediaItem"

@implementation MediaItem (Additions)
- (NSString *) titleFirstLetter {
    [self willAccessValueForKey:@"titleFirstLetter"];
    NSString * initial = [[self title] substringToIndex:1];
    [self didAccessValueForKey:@"titleFirstLetter"];
    return initial;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:[self title] forKey:kAttributeNameTitle];
    //[coder encodeObject:[self mediaItem] forKey:kAttributeNameMediaItem];

    [coder encodeObject:[self persistentID] forKey:kAttributeNamePersistentID];
}

- (id) initWithCoder: (NSCoder *)coder
{
    self = [[DataModel sharedInstance] insertNewMediaItemWithTitle:[coder decodeObjectForKey:kAttributeNameTitle] persistentID:[coder decodeObjectForKey:kAttributeNamePersistentID] fromDevice:nil];
    //self = [[DataModel sharedInstance]  insertNewMPMediaItem:[coder decodeObjectForKey:kAttributeNameMediaItem] device:nil];
//    if (self)
//    {
//        NSString *title = [coder decodeObjectForKey:kAttributeNameTitle];
//        [self setTitle:title];
//        
//        NSNumber *persistentID = [coder decodeObjectForKey:kAttributeNamePersistentID];
//        [self setPersistentID:persistentID];
//    }
    return self;
}
@end
