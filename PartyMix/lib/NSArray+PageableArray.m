//
//  NSArray+PageableArray.m
//  PartyMix
//
//  Created by Roderic Campbell on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray+PageableArray.h"

@implementation NSArray (PageableArray)

-(NSArray *)getPage:(NSUInteger)page withPageSize:(NSUInteger)size {
    NSUInteger start = size * page;    
    id *objects;
    
    NSRange range = NSMakeRange(start, size);
    objects = malloc(sizeof(id) * range.length);
    
    [self getObjects:objects range:range];    
    NSArray *ret = [NSArray arrayWithArray:(NSArray *)objects];

    free(objects);
    return ret;
}


@end
