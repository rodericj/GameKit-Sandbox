//
//  RJPhotoDisplayCell.h
//  PartyMix
//
//  Created by Roderic Campbell on 7/28/12.
//  Copyright (c) 2012 Aliph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItem.h"
#import <MapKit/MapKit.h>

@interface RJPhotoDisplayCell : UITableViewCell <MKMapViewDelegate>
+ (NSString *)photoDisplayCellReuseIdentifier;

@property (nonatomic, retain) PhotoItem *photoItem;

@end
