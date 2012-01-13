//
//  MediaItem.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MediaItem : NSManagedObject

@property (nonatomic, retain) NSData * mediaItem;
@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleFirstLetter;

@end
