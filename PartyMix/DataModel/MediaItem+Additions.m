//
//  MediaItem+Additions.m
//  PartyMix
//
//  Created by Roderic Campbell on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MediaItem+Additions.h"
#import "DataModel.h"

@implementation MediaItem (Additions)
- (NSString *) titleFirstLetter {
    [self willAccessValueForKey:@"titleFirstLetter"];
    NSString * initial = [[self title] substringToIndex:1];
    [self didAccessValueForKey:@"titleFirstLetter"];
    return initial;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:[self title] forKey:@"title"];
    [coder encodeObject:[self mediaItem] forKey:@"mediaItem"];
}

- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [[DataModel sharedInstance]  insertNewMPMediaItem:[coder decodeObjectForKey:@"mediaItem"] device:nil])
    {
        NSString *title = [coder decodeObjectForKey:@"title"];
        [self setTitle:title];
        //[self setMediaItem:     [coder decodeObjectForKey:@"mediaItem"]];
    }
    return self;
}
@end
