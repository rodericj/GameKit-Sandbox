//
//  RJPlaylistViewController.m
//  PartyMix
//
//  Created by Roderic Campbell on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RJPlaylistViewController.h"
#import "common.h"
#import "DataModel.h"
#import "Device.h"
#import "MediaItem.h"
#import "PlaylistItem.h"
#import "UIFactory.h"

@interface RJPlaylistViewController ()

@property (nonatomic, retain) Playlist *playlist;
@property (nonatomic, retain) RJMusicPlayerInterface *musicInterface;

@end

@implementation RJPlaylistViewController

@synthesize playlist = _playlist;
@synthesize musicInterface = _musicInterface;

+ (RJPlaylistViewController *)RJPlaylistViewControllerWithPlaylist:(Playlist *)playlist {
    RJPlaylistViewController *playlistViewController = [[[RJPlaylistViewController alloc] initWithNibName:@"RJPlaylistViewController" 
                                                                                                  bundle:nil] autorelease];
    playlistViewController.playlist = playlist;
    return playlistViewController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.musicInterface = [UIFactory sharedUIFactory].generateMusicPlayerInterface;

    self.entityName = kEntityNamePlaylistItem;
    self.sortBy     = @"addedDate";
    self.fetchController.delegate = self;

}
- (void)releaseWhenViewUnloads {
    self.playlist = nil;
    self.musicInterface = nil;   
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[DataModel sharedInstance] localDevice].isServer) {
        if ([DataModel sharedInstance].currentPlaylist == self.playlist) {
            self.tableView.tableHeaderView = self.musicInterface; 
        } else {
            
            UIButton *makeCurrentPlaylistButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            makeCurrentPlaylistButton.backgroundColor = [UIColor whiteColor];
            [makeCurrentPlaylistButton setTitle:@"Make current Playlist" 
                                       forState:UIControlStateNormal];
            CGSize size = [makeCurrentPlaylistButton.titleLabel.text sizeWithFont:makeCurrentPlaylistButton.titleLabel.font];
            makeCurrentPlaylistButton.frame = CGRectMake(0, 0, size.width, size.height);
            makeCurrentPlaylistButton.titleLabel.textColor = [UIColor brownColor];
            [makeCurrentPlaylistButton addTarget:self 
                                          action:@selector(makeCurrentPlaylist:) 
                                forControlEvents:UIControlEventTouchUpInside];
            UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
            [header addSubview:makeCurrentPlaylistButton];
            self.tableView.tableHeaderView = header;
            [header release];

        }
    }
    
    [super viewWillAppear:animated];
}

- (void)makeCurrentPlaylist:(UIButton *)button {
    [[DataModel sharedInstance] setCurrentPlaylist:self.playlist];
    self.tableView.tableHeaderView = self.musicInterface; 
    
    //TODO Set the media player's playlist to this playlist
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = self.entityName;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    PlaylistItem *playlistItem = (PlaylistItem *)[self.fetchController objectAtIndexPath:indexPath];
    cell.textLabel.text = playlistItem.mediaItem.title;
    cell.detailTextLabel.text = playlistItem.device.peerId;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
