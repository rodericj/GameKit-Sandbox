//
//  UIFactory.h
//  PartyMix
//
//  Created by Roderic Campbell on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJMusicPlayerInterface.h"
#import "RJPhotoDisplayCell.h"

@interface UIFactory : NSObject {
    RJMusicPlayerInterface				*_musicPlayerInterface;
}

+ (UIFactory*)sharedUIFactory;
- (RJMusicPlayerInterface *)generateMusicPlayerInterface;
- (RJPhotoDisplayCell *)generatePhotoDisplayCell;

@end
