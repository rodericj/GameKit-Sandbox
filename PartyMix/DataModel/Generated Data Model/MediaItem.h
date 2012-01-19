//
//  MediaItem.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MediaItem : NSManagedObject

@property (nonatomic, retain) NSData * mediaItem;
@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleFirstLetter;
@property (nonatomic, retain) NSSet *deviceHome;
@end

@interface MediaItem (CoreDataGeneratedAccessors)

- (void)addDeviceHomeObject:(NSManagedObject *)value;
- (void)removeDeviceHomeObject:(NSManagedObject *)value;
- (void)addDeviceHome:(NSSet *)values;
- (void)removeDeviceHome:(NSSet *)values;

@end
