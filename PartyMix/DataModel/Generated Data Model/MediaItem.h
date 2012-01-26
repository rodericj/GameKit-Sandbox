//
//  MediaItem.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device;

@interface MediaItem : NSManagedObject

@property (nonatomic, retain) NSData * mediaItem;
@property (nonatomic) int64_t persistentID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleFirstLetter;
@property (nonatomic, retain) Device *deviceHome;

@end
