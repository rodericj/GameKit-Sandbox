//
//  PayloadTranslator.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayloadTranslator : NSObject

+ (NSData *)buildPayLoadWithDictionary:(NSDictionary *)dict;
+ (NSDictionary *)extractDictionaryFromPayload:(NSData *)data;

@end
