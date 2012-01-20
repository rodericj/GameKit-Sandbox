//
//  PayloadTranslator.m
//  PartyMix
//
//  Created by Roderic Campbell on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PayloadTranslator.h"

@implementation PayloadTranslator
#pragma mark - Private method stuff
+ (NSData *)buildPayLoadWithDictionary:(NSDictionary *)dict {
    NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:dict forKey:@"data"];
	[archiver finishEncoding];
	[archiver release];
    
    return data;    
}

+ (NSDictionary *)extractDictionaryFromPayload:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *myDictionary = [unarchiver decodeObjectForKey:@"data"];
    [unarchiver finishDecoding];
    [unarchiver release];
    return myDictionary;
}
@end
