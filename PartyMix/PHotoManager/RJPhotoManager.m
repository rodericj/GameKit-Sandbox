//
//  RJPhotoManager.m
//  PartyMix
//
//  Created by Roderic Campbell on 7/24/12.
//  Copyright (c) 2012 Aliph. All rights reserved.
//

#import "RJPhotoManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <CoreLocation/CoreLocation.h>

@implementation RJPhotoManager

+ (void)findLocalPhotos {
    NSMutableArray *assets = [NSMutableArray array];
    
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop)
    {
        NSLog(@"enumerating %@", result);
        if(result != nil)
        {
//            NSString *const ALAssetPropertyType;
//            NSString *const ALAssetPropertyLocation;
//            NSString *const ALAssetPropertyDuration;
//            NSString *const ALAssetPropertyOrientation;
//            NSString *const ALAssetPropertyDate;
//            NSString *const ALAssetPropertyRepresentations;
//            NSString *const ALAssetPropertyURLs;
            
            NSLog(@"####################");
            NSLog(@"asset found");
            NSDictionary *propertyUrls = [result valueForProperty:ALAssetPropertyURLs];
            NSArray *propertyRepresentations = [result valueForProperty:ALAssetPropertyRepresentations];
            NSDate *photoDate = [result valueForProperty:ALAssetPropertyDate];
            NSNumber *photoOrientation = [result valueForProperty:ALAssetPropertyOrientation];
            NSNumber *duration = [result valueForProperty:ALAssetPropertyDuration];
            CLLocation *location = [result valueForProperty:ALAssetPropertyLocation];
            NSString *propertyType = [result valueForProperty:ALAssetPropertyType];
            
            NSLog(@"ALAssetPropertyType %@", propertyType);
            NSLog(@"ALAssetPropertyLocation %@", location);
            NSLog(@"ALAssetPropertyDuration %@", duration);
            NSLog(@"ALAssetPropertyOrientation %@", photoOrientation);
            NSLog(@"ALAssetPropertyDate %@", photoDate);
            NSLog(@"ALAssetPropertyRepresentations %@", propertyRepresentations);
            NSLog(@"ALAssetPropertyURLs %@", propertyUrls);
            [assets addObject:result];
            NSLog(@"####################");
        }
    };
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
    {
        NSLog(@"group enumerating: %@", group);
        if(group != nil)
        {
            [group enumerateAssetsUsingBlock:assetEnumerator];
        }
    };
    
    void (^assetFailureBlock)(NSError *) = ^(NSError *error)
    {
        NSLog(@"AssetFailure %@", error);
    };
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock:assetFailureBlock];
    
    [assetsLibrary release];
    
}
    
    
@end
