//
//  ChatMessage.h
//  PartyMix
//
//  Created by Roderic Campbell on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device;

@interface ChatMessage : NSManagedObject

@property (nonatomic, retain) NSString * messageContent;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) Device *device;

@end
