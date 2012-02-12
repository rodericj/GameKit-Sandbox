//
//  RJFourthViewController.m
//  PartyMix
//
//  Created by Roderic Campbell on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RJFourthViewController.h"
#import "common.h"
#import "DataModel.h"
#import "Playlist.h"
#import "RJPlaylistViewController.h"
#import "UIFactory.h"

@interface RJFourthViewController ()
@property (nonatomic, retain) RJMusicPlayerInterface *musicInterface;
@end

@implementation RJFourthViewController

@synthesize musicInterface = _musicInterface;

#pragma mark -
#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Playlist *playlist = [self.fetchController objectAtIndexPath:indexPath];
    
    //Set as current playlist
    [[DataModel sharedInstance] setCurrentPlaylist:playlist];
    
    //Push playlist view controller
    RJPlaylistViewController *view = [RJPlaylistViewController RJPlaylistViewControllerWithPlaylist:playlist];
    [self.navigationController pushViewController:view 
                                         animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = self.entityName;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Playlist *playlist = (Playlist *)[self.fetchController objectAtIndexPath:indexPath];
    cell.textLabel.text = playlist.title;
    
    return cell;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated {
    if ([[DataModel sharedInstance] localDevice].isServer) {
        self.tableView.tableHeaderView = self.musicInterface; 
    }
    else {
        self.tableView.tableHeaderView = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.entityName = kEntityNamePlaylist;
    self.sortBy     = @"title";
    self.fetchController.delegate = self;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                                 target:self 
                                                                                 action:@selector(addPlaylist:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:rightButton];
    [rightButton release];
    
    self.musicInterface = [UIFactory sharedUIFactory].generateMusicPlayerInterface;
    
}

- (IBAction)addPlaylist:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Playlist" 
                                                    message:nil 
                                                   delegate:self
                                          cancelButtonTitle:kCancel 
                                          otherButtonTitles:kOk, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    [alert release];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex != buttonIndex) {
        NSString *newPlaylistName = [alertView textFieldAtIndex:0].text;
        [[DataModel sharedInstance] insertNewPlaylistWithTitle:newPlaylistName];
    }
}

- (void)releaseWhenViewUnloads {
    self.musicInterface = nil;
}

- (void)viewDidUnload
{
    [self releaseWhenViewUnloads];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
