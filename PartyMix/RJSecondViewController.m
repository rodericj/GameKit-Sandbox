//
//  RJSecondViewController.m
//  PartyMix
//
//  Created by Roderic Campbell on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "common.h"
#import "DataModel.h"
#import "MediaItem.h"
#import "RJSecondViewController.h"

@implementation RJSecondViewController

#pragma mark - Get Media

-(IBAction)getMPMediaItems:(id)sender {
#if TARGET_IPHONE_SIMULATOR
    [[DataModel sharedInstance] insertDummyMediaItems];
    return;
#endif
    
    //From the Apple documentation
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    
    NSLog(@"Logging items from a generic query...");
    NSArray *itemsFromGenericQuery = [everything items];
    [[DataModel sharedInstance] insertArrayOfMPMediaItems:itemsFromGenericQuery device:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Cell for the row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = self.entityName;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseId];
    }
    
    MediaItem *mediaItem = (MediaItem *)[self.fetchController objectAtIndexPath:indexPath];
    cell.textLabel.text = mediaItem.title;

    // Configure the cell with data from the managed object.
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaItem *mediaItem = (MediaItem *)[self.fetchController objectAtIndexPath:indexPath];
    Device *currentDevice = [[DataModel sharedInstance] localDevice];
    Playlist *currentPlaylist = [[DataModel sharedInstance] currentPlaylist];
    [[DataModel sharedInstance] insertNewPlaylistItem:mediaItem 
                                           fromDevice:currentDevice
                                           toPlaylist:currentPlaylist];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.entityName = kEntityNameMediaItem;
    self.sortBy     = @"title";
    self.fetchController.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
