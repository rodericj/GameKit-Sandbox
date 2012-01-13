//
//  MediaItem+Additions.m
//  PartyMix
//
//  Created by Roderic Campbell on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MediaItem+Additions.h"

@implementation MediaItem (Additions)
- (NSString *) titleFirstLetter {
    [self willAccessValueForKey:@"titleFirstLetter"];
    NSString * initial = [[self title] substringToIndex:1];
    [self didAccessValueForKey:@"titleFirstLetter"];
    return initial;
}
@end
