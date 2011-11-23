//
//  RJFirstViewController.m
//  PartyMix
//
//  Created by Roderic Campbell on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RJFirstViewController.h"
@implementation RJFirstViewController

@synthesize picker      = mPicker;
@synthesize sessions    = mSessions;
@synthesize statusLabel = mStatusLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Private method stuff
-(NSData *)buildPayLoadWithMessage:(NSString *)message {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:message forKey:@"message"];
    
    NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:dict forKey:@"data"];
	[archiver finishEncoding];
	[archiver release];
    
    return data;    
}

-(NSDictionary *)extractDictionaryFromPayload:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *myDictionary = [[unarchiver decodeObjectForKey:@"data"] retain];
    [unarchiver finishDecoding];
    [unarchiver release];
    return myDictionary;
}
#pragma mark - Buttons

-(IBAction)startMatch:(id)sender {
    
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (localPlayer.isAuthenticated)
        {
            GKMatchRequest *request = [[[GKMatchRequest alloc] init] autorelease];
            request.minPlayers = 2;
            request.maxPlayers = 2;
            
            GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease];
            mmvc.matchmakerDelegate = self;
            
            [self presentModalViewController:mmvc animated:YES];        }
    }];
    
   
}

-(IBAction)sendDataPushed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"send a message" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    [alert release];
}

#pragma mark - MatchmakerDelegate
// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    NSLog(@"matchmaker was cancelled");
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    NSLog(@"matchmaker failed %@", error);
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match {
    NSLog(@"matchmaker did find match %@", match);
}

// Players have been found for a server-hosted game, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindPlayers:(NSArray *)playerIDs {
    NSLog(@"matchmaker did find players %@", playerIDs);
}

// An invited player has accepted a hosted invite.  Apps should connect through the hosting server and then update the player's connected state (using setConnected:forHostedPlayer:)
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didReceiveAcceptFromHostedPlayer:(NSString *)playerID __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0) {
    NSLog(@"did get accept from hosted player %@", playerID);
}

#pragma mark - The Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *messageString = [alertView textFieldAtIndex:0].text;
    
    NSLog(@"send the string to all sessions %@", messageString);
    NSData *data = [self buildPayLoadWithMessage:messageString];
    //NSData *data = [messageString dataUsingEncoding:NSUTF8StringEncoding];
    for(GKSession *sess in [self.sessions allValues]) {
        NSLog(@"session %@ %@", sess.peerID,  sess.isAvailable ? @"is available" : @"is not available");
        //[sess connectToPeer:sess.peerID withTimeout:10];
        [sess sendDataToAllPeers:data withDataMode:GKSendDataUnreliable error:nil];
    }
}

#pragma mark Session Data
- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    //NSString *messageString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [self extractDictionaryFromPayload:data];
    NSString *messageString = [dict objectForKey:@"message"];
    [dict release];
    NSLog(@"we got some data %@", messageString);
    self.statusLabel.text = messageString;
    
    if ([messageString isEqualToString:@"next"]) {
        [self.tabBarController setSelectedIndex:1];
    }
}

#pragma mark  GKSessionDelegate
/* Indicates a state change for the given peer.
 */
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    NSLog(@"The session state changed %@ %d", peerID, state);
    switch (state) {
        case GKPeerStateAvailable:
            [self.picker show];
            break;
            
        case GKPeerStateConnected:
            NSLog(@"the session is now connected to: %@, %@ Do what you need to do.", session.displayName, peerID);
            break;
            
        case GKPeerStateDisconnected:
            NSLog(@"DISCONNECTED FROM: %@", peerID);

            break;
            
        default:
            break;
    }
    
}

/* Indicates a connection request was received from another peer. 
 
 Accept by calling -acceptConnectionFromPeer:
 Deny by calling -denyConnectionFromPeer:
 */
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    NSLog(@"The session didReceiveConnectionRequestFromPeer %@, %@", session.displayName, peerID);
    
    //For now let's always accept
    if (YES) {
        NSError *error;
        [session acceptConnectionFromPeer:peerID error:&error];
    }
}

/* Indicates a connection error occurred with a peer, which includes connection request failures, or disconnects due to timeouts.
 */
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    NSLog(@"connectionWithPeerFailed %@, %@ %@", session.displayName, peerID, error);

    //Remove from retained sessions
    [self.sessions removeObjectForKey:peerID];
}

/* Indicates an error occurred with the session such as failing to make available.
 */
- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"GKSession didFailWithError %@", error);
}


#pragma mark - GKPeerPickerDelegate
/* Notifies delegate that a connection type was chosen by the user.
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didSelectConnectionType:(GKPeerPickerConnectionType)type {
    NSLog(@"peer picker did select connection type");
}

/* Notifies delegate that the connection type is requesting a GKSession object.
 
 You should return a valid GKSession object for use by the picker. If this method is not implemented or returns 'nil', a default GKSession is created on the delegate's behalf.
 */
//- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
//    NSLog(@"sessionForConnectionType %d", type);
//    return nil;
//}

/* Notifies delegate that the peer was connected to a GKSession.
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
    NSLog(@"did Connect to session %@", session);    
    session.available   = YES;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    
    [self.sessions setObject:session forKey:peerID];

    [picker dismiss];
}

/* Notifies delegate that the user cancelled the picker.
 */
- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
    NSLog(@"the peer picker cancelled");
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sessions = [NSMutableDictionary dictionary];
    self.picker = [[GKPeerPickerController alloc] init];
    self.picker.delegate = self;
    self.picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby; 
    [self.picker show];
    
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

-(void) dealloc {
    self.picker         = nil;
    self.sessions       = nil;
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
