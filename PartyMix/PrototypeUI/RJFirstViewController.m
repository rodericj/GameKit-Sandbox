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
#import "RJMusicSessionManager.h"

#define kSessionRequestAlert            100
#define kSessionSendText                101

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
    
    [[RJMusicSessionManager sharedInstance] toggleServerAvailabilty];
    NSString *listeningState = [[RJMusicSessionManager sharedInstance] isListening] ? listening : not_listening;
    self.serverLabel.text = listeningState;
    
}

-(IBAction)findServerButtonPushed:(id)sender {
    
    [[RJMusicSessionManager sharedInstance] findServer];

}

-(IBAction)sendDataButtonPushed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:send_a_message
                                                    message:nil 
                                                   delegate:self 
                                          cancelButtonTitle:kOk
                                          otherButtonTitles:nil, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = kSessionSendText;
    [alert show];
    [alert release];
}

-(IBAction)disconnectButtonPushed:(id)sender {
    [[RJMusicSessionManager sharedInstance] disconnect];
}


#pragma mark - The Alert View
#pragma mark SERVER/CLIENT
-(void)handleSendTextThroughAlert:(UIAlertView *)alert {
    NSString *messageString = [alert textFieldAtIndex:0].text;
    
    [[RJMusicSessionManager sharedInstance] sendMessageToAll:messageString];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case kSessionRequestAlert:
            if (buttonIndex) {
                NSError *error = [[RJMusicSessionManager sharedInstance] handleSessionRequestFrom:self.deviceToConnectTo];
                if (error) {
                    NSLog(@"error handling session request %@", error);
                }
            }
            else {
                [[RJMusicSessionManager sharedInstance] denySessionRequestFrom:self.deviceToConnectTo];
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

#pragma mark - action sheet

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {        
        [[RJMusicSessionManager sharedInstance] connectToPeer:self.deviceToConnectTo];
    }
}
#pragma mark - MessageRecipient
-(void)newMessage:(NSDictionary *)data {
    NSLog(@"we got a new message %@", data);
}
#pragma mark - Session change event handling
    
-(void)handleConnecting:(Device *) device {
    NSLog(@"peer is connecting %@", device);
    NSString *displayName = [[RJMusicSessionManager sharedInstance] displayNameForPeer:device.peerId];
    
    self.deviceToConnectTo = device;
    NSString *title = [NSString stringWithFormat:allow_connections_from, displayName];
    UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle:title 
                                                              message:nil 
                                                             delegate:self 
                                                    cancelButtonTitle:kCancel 
                                                    otherButtonTitles:kOk, nil];
    connectionAlert.tag = kSessionRequestAlert;
    [connectionAlert show];
    [connectionAlert release];


}

#pragma mark - UITableView method
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Device *tappedDevice = [self.fetchController objectAtIndexPath:indexPath];
    switch ([tappedDevice.state intValue]) {
        case GKPeerStateConnected: {
            NSLog(@"Logic to push a view controller or send data");
            if ([tappedDevice.isServer boolValue]) {
                [self.tabBarController setSelectedIndex:2];
            }
        }
            break;
            
        case GKPeerStateAvailable: {
            self.deviceToConnectTo = tappedDevice;
            NSLog(@"device %@, peerId %@, device.deviceName %@", self.deviceToConnectTo, self.deviceToConnectTo.peerId, self.deviceToConnectTo.deviceName);
            NSString *displayName = [[RJMusicSessionManager sharedInstance] displayNameForPeer:self.deviceToConnectTo.peerId];
        
            if (!displayName) {
                NSString *name = [[RJMusicSessionManager sharedInstance] displayNameForPeer:self.deviceToConnectTo.peerId];
                NSLog(@"name = %@", name);
                NSAssert(displayName, @"Display name must not be nil for available state");
            }
            
            NSString *title = [NSString stringWithFormat:would_you_like_to_connect_to, displayName];
            
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title
                                                               delegate:self
                                                      cancelButtonTitle:kCancel 
                                                 destructiveButtonTitle:nil     
                                                      otherButtonTitles:kOk, nil];
            [sheet showInView:self.tabBarController.view];
            [sheet release];
        }
            
        default:
            break;
    }
    

}
- (NSString *)sessionTitleForState:(NSNumber *)state {
    switch ([state intValue]) {
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
    }
    
    Device *device = (Device *)[self.fetchController objectAtIndexPath:indexPath];
    NSString *deviceName = [[RJMusicSessionManager sharedInstance] displayNameForPeer:device.peerId];
    if(!deviceName) {
        NSLog(@"should perhaps have a cache name");
        //deviceName = device.cachedName;
    }
    int substringIndex = MIN(deviceName.length, 20);
    cell.textLabel.text = [deviceName substringToIndex:substringIndex];
    
    cell.detailTextLabel.text = [self sessionTitleForState:device.state];

    if ([device.isServer boolValue]) {
        cell.imageView.image = [UIImage imageNamed:@"server.png"];
    } else {
        cell.imageView.image = nil;
    }
    
    if ([device.state intValue] == GKPeerStateConnecting) {
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
    self.entityName = kEntityNameDevice;
    self.sortBy     = @"peerId";
    self.fetchController.delegate = self;
    
    for (Device *d in self.fetchController.fetchedObjects) {
        d.state = [NSNumber numberWithInt:GKPeerStateUnavailable];
    }
    [[DataModel sharedInstance] save];
    [[RJMusicSessionManager sharedInstance] findServer];
    
}

- (void)updateServerListeningString {
    self.serverLabel.text = [RJMusicSessionManager sharedInstance].isListening ? listening : not_listening;
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
    [self updateServerListeningString];
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
