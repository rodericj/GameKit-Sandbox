//
//  SessionManagerDataModelDelegate.h
//  PartyMix
//
//  Created by roderic campbell on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SessionManagerDataModelDelegate <NSObject>
- (void)setDeviceConnectionState:(NSUInteger)state;
@end
