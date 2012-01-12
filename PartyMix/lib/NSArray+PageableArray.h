//
//  NSArray+PageableArray.h
//  PartyMix
//
//  Created by Roderic Campbell on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (PageableArray)

-(NSArray *)getPage:(NSUInteger)page withPageSize:(NSUInteger)size;
@end
