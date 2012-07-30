//
//  PhotoItem+Additions.m
//  PartyMix
//
//  Created by Roderic Campbell on 7/29/12.
//  Copyright (c) 2012 Aliph. All rights reserved.
//

#import "PhotoItem+Additions.h"

@implementation PhotoItem (Additions)
- (CLLocationCoordinate2D)coordinate {
    return ((CLLocation *)self.location).coordinate;
}

@end
