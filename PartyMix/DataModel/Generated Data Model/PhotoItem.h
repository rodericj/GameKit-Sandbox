//
//  PhotoItem.h
//  PartyMix
//
//  Created by Roderic Campbell on 7/24/12.
//  Copyright (c) 2012 Aliph. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PhotoItem : NSManagedObject

@property (nonatomic, retain) NSString * assetType;
@property (nonatomic, retain) NSDate * dateTaken;
@property (nonatomic, retain) id location;
@property (nonatomic, retain) NSNumber * orientation;
@property (nonatomic, retain) NSString * representation;
@property (nonatomic, retain) NSString * url;

@end
