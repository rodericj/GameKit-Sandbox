//
//  DataModel.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject {
	NSPersistentStoreCoordinator        *_persistentStoreCoordinator;
	NSManagedObjectModel                *_managedObjectModel;
	NSManagedObjectContext              *_managedObjectContext;	
}

+(DataModel*)sharedInstance;
-(NSArray *)insertArrayOfMPMediaItems:(NSArray *)mediaItems;

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

#if TARGET_IPHONE_SIMULATOR
-(NSArray *)insertDummyMediaItems;
#endif
@end
