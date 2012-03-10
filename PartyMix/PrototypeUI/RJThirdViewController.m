//
//  RJThirdViewController.m
//  PartyMix
//
//  Created by Roderic Campbell on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "common.h"
#import "MediaItem+Additions.h"
#import "RJThirdViewController.h"
#import "DataModel.h"
#import "RJSessionManager.h"
#define kAddToRemotePlaylist    @"Would you like to add this song to the remote playlist"

@interface RJThirdViewController () 

@property (nonatomic, retain) MediaItem *mediaToSend;

@end
@implementation RJThirdViewController

@synthesize mediaToSend = _mediaToSend;

-(IBAction)getRemoteMedia:(id)sender {
    if([[DataModel sharedInstance] currentServerWithState:GKPeerStateConnected]) {
        NSLog(@"fetch remote");
        [[RJSessionManager sharedInstance] requestSongsFromServer];
    }
    else {
        NSString *alertTitle = @"Requesting remote tracks";
        NSString *notConnectedMessage = @"It looks like you are not connected to a server. Go back to the first view and establish a connection, or start your own party by becoming a server";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:notConnectedMessage 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

-(NSPredicate *)predicate {
    return [NSPredicate predicateWithFormat:@"deviceHome == %@", [[DataModel sharedInstance] currentServerWithState:GKPeerStateConnected]];
}

#pragma mark - UITableViewDelegate Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = self.entityName;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    MediaItem *mediaItem = (MediaItem *)[self.fetchController objectAtIndexPath:indexPath];
    cell.textLabel.text = mediaItem.title;

    // Configure the cell with data from the managed object.
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.mediaToSend = [self.fetchController objectAtIndexPath:indexPath];
    //Show an alert vew asking if we want to add this song
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:kAddToRemotePlaylist
                                                       delegate:self
                                              cancelButtonTitle:kCancel 
                                         destructiveButtonTitle:nil     
                                              otherButtonTitles:kOk, nil];
    [sheet showInView:self.tabBarController.view];
    [sheet release];
}

#pragma mark - UIActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {        
        NSLog(@"send song %@", self.mediaToSend);
        [[RJSessionManager sharedInstance] sendSingleSongRequest:self.mediaToSend];
        self.mediaToSend = nil;
        //[DataModel sharedInstance] 
    }
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
