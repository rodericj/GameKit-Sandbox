//
//  RJFirstViewController.m
//  PartyMix
//
//  Created by Roderic Campbell on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <malloc/malloc.h>
#import <MediaPlayer/MediaPlayer.h>

#import "common.h"
#import "DataModel.h"
#import "Device.h"
#import "NSArray+PageableArray.h"
#import "PayloadTranslator.h"
#import "RJFirstViewController.h"

#define send_a_message                  @"Send a message"
#define error_sending_data              @"Error sending data"

#define disconnected                    @"disconnected"
#define listening                       @"Listening"
#define not_listening                   @"Not Listening"
#define would_you_like_to_connect_to    @"Would you like to connect to %@"
#define allow_connections_from          @"Allow connection from %@"

#define cancel                          @"Cancel"
#define ok                              @"OK"

#define kSessionRequestAlert            100
#define kSessionSendText                101

#define fetch_all_songs_by_artist       @"fetchAllSongsByArtist"
#define media_key                       @"media key"

@interface RJFirstViewController()

@property (nonatomic, retain) IBOutlet  UILabel                  *serverLabel;
@property (nonatomic, retain) IBOutlet  UITableView                 *tableView;
@property (nonatomic, retain)           Device                     *deviceToConnectTo;

@end


@implementation RJFirstViewController

@synthesize serverLabel     = _ServerLabel;
@synthesize tableView       = _tableView;
@synthesize deviceToConnectTo   = _deviceToConnectTo;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Buttons

-(IBAction)toggleServerAvailabiltyButtonPushed:(id)sender {
    
    [[DataModel sharedInstance] toggleServerAvailabilty];
    NSString *listeningState = [[DataModel sharedInstance] isSessionAvailable] ? listening : not_listening;
    self.serverLabel.text = listeningState;
    
}

-(IBAction)findServerButtonPushed:(id)sender {
    
    [[DataModel sharedInstance] findServer];

}

-(IBAction)sendDataButtonPushed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:send_a_message message:nil delegate:self cancelButtonTitle:ok otherButtonTitles:nil, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = kSessionSendText;
    [alert show];
    [alert release];
}

-(IBAction)disconnectButtonPushed:(id)sender {
    [[DataModel sharedInstance] disconnect];
}


#pragma mark - The Alert View
#pragma mark SERVER/CLIENT
-(void)handleSendTextThroughAlert:(UIAlertView *)alert {
    NSString *messageString = [alert textFieldAtIndex:0].text;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:messageString forKey:@"message"];
    
    if ([messageString isEqualToString:@"getmusic"]) {
        [dict setObject:fetch_all_songs_by_artist forKey:@"action"];
    }

    NSData *data = [PayloadTranslator buildPayLoadWithDictionary:dict];
    NSError *error = nil;
    
    [[DataModel sharedInstance] sendPayload:data];
    
    if (error) {
        NSLog(@"error sending data %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error_sending_data
                                                        message:[NSString stringWithFormat:@"%@", error] 
                                                       delegate:nil 
                                              cancelButtonTitle:ok 
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case kSessionRequestAlert:
            if (buttonIndex) {
                NSError *error = [[DataModel sharedInstance] handleSessionRequestFrom:self.deviceToConnectTo];
                if (error) {
                    NSLog(@"error handling session request %@", error);
                }
            }
            break;
            
        case kSessionSendText: {
            [self handleSendTextThroughAlert:alertView];
            break;
        }
            
        default:
            break;
    }    
}

-(void)fetchAllSongsByArtist {

    NSArray *media = [MPMediaQuery songsQuery].items;

    NSUInteger pageSize = 10;
    for (int i = 0; i * pageSize < [media count]; i++ ) {
        NSArray *page = [media getPage:i withPageSize:pageSize];
        NSMutableDictionary *payloadData = [NSMutableDictionary dictionary];
        [payloadData setObject:page forKey:media_key];
        
        //NSData *data = [self buildPayLoadWithDictionary:payloadData];
        //[self sen
        NSLog(@"size of myObject: %zd", malloc_size(payloadData));
    }
}

#pragma mark - action sheet
-(void)showActionSheetForServer {
  }

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {        
        [[DataModel sharedInstance] connectToPeer:self.deviceToConnectTo];
    }
}
#pragma mark - MessageRecipient
-(void)newMessage:(NSDictionary *)data {
    NSLog(@"we got a new message %@", data);
}
#pragma mark - Session change event handling
    
-(void)handleConnecting:(Device *) device {
    NSLog(@"peer is connecting %@", device);
    NSString *displayName = [[DataModel sharedInstance] displayNameForPeer:device.peerId];
    
    self.deviceToConnectTo = device;
    NSString *title = [NSString stringWithFormat:allow_connections_from, displayName];
    UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle:title 
                                                              message:nil 
                                                             delegate:self 
                                                    cancelButtonTitle:cancel 
                                                    otherButtonTitles:ok, nil];
    connectionAlert.tag = kSessionRequestAlert;
    [connectionAlert show];
    [connectionAlert release];


}

#pragma mark - UITableView method
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Device *tappedDevice = [self.fetchController objectAtIndexPath:indexPath];
    switch (tappedDevice.state) {
        case GKPeerStateConnected:
            NSLog(@"Logic to push a view controller or send data");
            break;
            
        case GKPeerStateAvailable: {
            self.deviceToConnectTo = tappedDevice;
            NSString *displayName = [[DataModel sharedInstance] displayNameForPeer:self.deviceToConnectTo.peerId];
            
            NSString *title = [NSString stringWithFormat:would_you_like_to_connect_to, displayName];
            
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title
                                                               delegate:self
                                                      cancelButtonTitle:cancel 
                                                 destructiveButtonTitle:nil     
                                                      otherButtonTitles:ok, nil];
            [sheet showInView:self.tabBarController.view];
            [sheet release];
        }
            
        default:
            break;
    }
    

}
- (NSString *)sessionTitleForState:(NSInteger)state {
    switch (state) {
        case GKPeerStateAvailable:
            return @"Available";

        case GKPeerStateConnected:
            return @"Connected";
            
        case  GKPeerStateConnecting:
            return @"Connecting";
            
        case GKPeerStateDisconnected:
            return @"Disconnected";
            
        case GKPeerStateUnavailable:
            return @"Unavailable";
        default:
            break;
    }
    return @"unknown";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = self.entityName;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
    }
    
    Device *device = (Device *)[self.fetchController objectAtIndexPath:indexPath];
    NSString *deviceName = [[DataModel sharedInstance] displayNameForPeer:device.peerId];
    
    int substringIndex = MIN(deviceName.length, 20);
    cell.textLabel.text = [deviceName substringToIndex:substringIndex];
    
    cell.detailTextLabel.text = [self sessionTitleForState:device.state];

    if (device.state == GKPeerStateConnecting) {
        [self handleConnecting:device];
    }
    
    // Configure the cell with data from the managed object.
    return cell;
}

#pragma mark - View lifecycle

-(NSPredicate *)predicate {
    return [NSPredicate predicateWithFormat:@"state != %d && state != %d", GKPeerStateDisconnected, GKPeerStateUnavailable];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.entityName = kEntityPeer;
    self.sortBy     = @"peerId";
    self.fetchController.delegate = self;
    
    for (Device *d in self.fetchController.fetchedObjects) {
        d.state = GKPeerStateUnavailable;
    }
    [[DataModel sharedInstance] save];
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
    self.serverLabel.text = [DataModel sharedInstance].isSessionAvailable ? listening : not_listening;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

-(void) dealloc {
    self.serverLabel    = nil;
    self.tableView      = nil;
    self.deviceToConnectTo = nil;
    [super dealloc];
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
