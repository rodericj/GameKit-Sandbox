//
//  UIFactory.m
//  PartyMix
//
//  Created by Roderic Campbell on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIFactory.h"

@interface UIFactory ()

@property (nonatomic, assign) IBOutlet RJMusicPlayerInterface *musicPlayerInterface;

@end

@implementation UIFactory

@synthesize musicPlayerInterface = _musicPlayerInterface;

static UIFactory *_uiFactory = nil;

- (RJMusicPlayerInterface *)generateMusicPlayerInterface {
    [[NSBundle mainBundle] loadNibNamed:@"RJMusicPlayerInterface" owner:self options:nil];
    RJMusicPlayerInterface *interface = _musicPlayerInterface;
    return interface;
}

+ (UIFactory*)sharedUIFactory {
    @synchronized(self) {
        if (_uiFactory == nil) {
            _uiFactory = [[self alloc] init];
        }
    }
    return _uiFactory;
}

@end
