//
//  RJPhotoDisplayCell.m
//  PartyMix
//
//  Created by Roderic Campbell on 7/28/12.
//  Copyright (c) 2012 Aliph. All rights reserved.
//

#import "RJPhotoDisplayCell.h"
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MapKit/Mapkit.h>
#import "PhotoItem+Additions.h"

@interface RJPhotoDisplayCell ()

@property (retain, nonatomic) IBOutlet UIImageView *photoImageView;
@property (retain, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation RJPhotoDisplayCell
@synthesize photoImageView = _photoImageView;
@synthesize mapView = _mapView;
@synthesize photoItem = _photoItem;

+ (NSString *)photoDisplayCellReuseIdentifier {
    return @"RJPhotoDisplayCell";
}

-(void)findLargeImageForAssetURL:(NSURL *)url
{
    //
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            UIImage *largeimage = [UIImage imageWithCGImage:iref];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.photoImageView.image = largeimage;
            });
        }
    };
    
    //
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
    };
    
    NSString *mediaurl = url.absoluteString;
    NSLog(@"mediaurl is %@", mediaurl);
    if(mediaurl && [mediaurl length] && ![[mediaurl pathExtension] isEqualToString:@"AUDIO_EXTENSION"])
    {
        //[largeimage release];
        NSURL *asseturl = [NSURL URLWithString:mediaurl];
        ALAssetsLibrary* assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
        [assetslibrary assetForURL:asseturl 
                       resultBlock:resultblock
                      failureBlock:failureblock];
    }
    
}

- (void)setPhotoItem:(PhotoItem *)photoItem {
    if (_photoItem) {
        [_photoItem release];
    }
    _photoItem = [photoItem retain];
    
    self.photoImageView.image = [UIImage imageNamed:@"second"];
    
    if (photoItem.location) {
        CLLocation *location = photoItem.location;
        self.mapView.centerCoordinate = location.coordinate;
        NSLog(@"horizontal acc: %f, vertical acc: %f", location.horizontalAccuracy, location.verticalAccuracy);
        self.mapView.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.001, .001));
        [self.mapView addAnnotation:photoItem];
    }
    NSLog(@"photoItem is %@", photoItem);
    [self findLargeImageForAssetURL:photoItem.url];
    NSLog(@"exit findLarge");
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    return [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
}

- (void)dealloc {
    self.photoItem = nil;
    [_photoImageView release];
    [_mapView release];
    [super dealloc];
}

@end
