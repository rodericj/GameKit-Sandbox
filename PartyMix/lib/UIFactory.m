//
//  UIFactory.m
//  PartyMix
//
//  Created by Roderic Campbell on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIFactory.h"
#import "RJPhotoDisplayCell.h"

@interface UIFactory ()

@property (nonatomic, assign) IBOutlet RJMusicPlayerInterface *musicPlayerInterface;
@property (retain, nonatomic) IBOutlet RJPhotoDisplayCell *photoDisplayCell;

@end

@implementation UIFactory

@synthesize musicPlayerInterface = _musicPlayerInterface;
@synthesize photoDisplayCell = _photoDisplayCell;

static UIFactory *_uiFactory = nil;

- (RJMusicPlayerInterface *)generateMusicPlayerInterface {
    [[NSBundle mainBundle] loadNibNamed:@"RJMusicPlayerInterface" owner:self options:nil];
    RJMusicPlayerInterface *interface = _musicPlayerInterface;
    return interface;
}

- (RJPhotoDisplayCell *)generatePhotoDisplayCell {
    [[NSBundle mainBundle] loadNibNamed:@"RJPhotoDisplayCell" owner:self options:nil];
    RJPhotoDisplayCell *cell = _photoDisplayCell;
    return cell;
}

+ (UIFactory*)sharedUIFactory {
    @synchronized(self) {
        if (_uiFactory == nil) {
            _uiFactory = [[self alloc] init];
        }
    }
    return _uiFactory;
}

- (void)dealloc {
    [_photoDisplayCell release];
    [super dealloc];
}
@end
