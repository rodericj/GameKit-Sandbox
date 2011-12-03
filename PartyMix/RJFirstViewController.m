//
//  RJFirstViewController.m
//  PartyMix
//
//  Created by Roderic Campbell on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RJFirstViewController.h"

#define kSessionRequestAlert            100
#define kSessionSendText                101
#define kSessionName                    @"com.rodericj.partymix.session"

@interface RJFirstViewController()

@property (nonatomic, retain) IBOutlet  UILabel                   *statusLabel;

//Server
@property (nonatomic, retain)           GKSession                   *session;
@property (nonatomic, retain)           NSString                  *pendingPeerId;
@property (nonatomic, retain) IBOutlet  UILabel                  *serverLabel;
@property (nonatomic, assign)           BOOL                      isServer;
@property (nonatomic, retain)           NSString                   *serverPeerId;
@property (nonatomic, retain) IBOutlet  UITableView                 *tableView;
@property (nonatomic, retain)           NSMutableArray              *peersConnected;
@end


@implementation RJFirstViewController

@synthesize statusLabel = mStatusLabel;

//Server
@synthesize pendingPeerId   = _PendingPeerId;
@synthesize session         = _Session;
@synthesize serverLabel     = _ServerLabel;
@synthesize isServer        = _isServer;
@synthesize serverPeerId    = _serverPeerId;
@synthesize tableView       = _tableView;
@synthesize peersConnected  = _peersConnected;

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
    NSDictionary *myDictionary = [unarchiver decodeObjectForKey:@"data"];
    [unarchiver finishDecoding];
    [unarchiver release];
    return myDictionary;
}
#pragma mark - Buttons

-(IBAction)toggleServerAvailabilty:(id)sender {
    //start server
    
    if (!self.session) {
        self.session = [[[GKSession alloc] initWithSessionID:kSessionName displayName:nil sessionMode:GKSessionModeServer] autorelease];
        self.session.delegate = self;
        [self.session setDataReceiveHandler:self withContext:nil];
        self.isServer = YES;
    }
    
    self.session.available = !self.session.available;
    self.serverLabel.text = self.session.available ? @"listening" : @"not listening";
    
}

-(IBAction)findServer:(id)sender {
    self.session = [[[GKSession alloc] initWithSessionID:kSessionName 
                                            displayName:nil 
                                            sessionMode:GKSessionModeClient] autorelease];
    self.session.delegate = self;
    self.session.available = YES;
    self.isServer = NO;
    [self.session setDataReceiveHandler:self withContext:nil];
}

-(IBAction)sendDataPushed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"send a message" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = kSessionSendText;
    [alert show];
    [alert release];
}

-(IBAction)disconnectButtonPushed:(id)sender {
    self.isServer = NO;
    [self.session disconnectFromAllPeers];
    self.session = nil;
}


#pragma mark - The Alert View

#pragma mark SERVER
-(void)handleSessionRequestWithButton:(NSInteger)buttonIndex {
    NSError *error = nil;
    [self.session acceptConnectionFromPeer:self.pendingPeerId error:&error];
    self.pendingPeerId = nil;
    
    if (error) {
        NSLog(@"error handling session request %@", error);
    }
    
}
#pragma mark SERVER/CLIENT
-(void)handleSendTextThroughAlert:(UIAlertView *)alert {
    NSString *messageString = [alert textFieldAtIndex:0].text;
    
    NSLog(@"send the string to all sessions %@", messageString);
    NSLog(@"session %@ %@", self.session.peerID,  self.session.isAvailable ? @"is available" : @"is not available");

    NSData *data = [self buildPayLoadWithMessage:messageString];
    NSError *error = nil;
    
    if (self.isServer) {    
        [self.session sendDataToAllPeers:data 
                            withDataMode:GKSendDataReliable 
                                   error:&error];
    }
    else {
        NSArray *peer = [NSArray arrayWithObject:self.serverPeerId];
        [self.session sendData:data toPeers:peer withDataMode:GKSendDataReliable error:&error];
    }
    if (error) {
        NSLog(@"error sending data %@", error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error sending data"
                                                        message:[NSString stringWithFormat:@"%@", error] 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case kSessionRequestAlert:
            if (buttonIndex) {
                [self handleSessionRequestWithButton:buttonIndex];
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

#pragma mark Session Data
- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    //NSString *messageString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [self extractDictionaryFromPayload:data];
    NSString *messageString = [dict objectForKey:@"message"];
    NSLog(@"we got some data %@", messageString);
    self.statusLabel.text = messageString;
    
    if ([messageString isEqualToString:@"next"]) {
        [self.tabBarController setSelectedIndex:1];
    }
}

#pragma mark - action sheet
-(void)showActionSheetForServer {
    NSString *displayName = [self.session displayNameForPeer:self.pendingPeerId];
    
    //Handle an odd situation where the session returns nil for the peer
    if (!displayName) {
        self.pendingPeerId = nil;
        return;
    }
    
    NSString *title = [NSString stringWithFormat:@"Would you like to connect to %@", displayName];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel" 
                                         destructiveButtonTitle:nil     
                                              otherButtonTitles:@"Ok", nil];
    [sheet showInView:self.tabBarController.view];
    [sheet release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self.session connectToPeer:self.pendingPeerId withTimeout:10];
    }
}

#pragma mark - Session change event handling
-(void)handleDisconnect:(NSString *)peerID {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"disconnected"
                                                    message:[self.session displayNameForPeer:peerID]
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    
    NSString *toRemove = nil;
    //Remove peer from list
    for (NSString *existingPeer in self.peersConnected) {
        if ([peerID isEqualToString:existingPeer]) {
            toRemove = existingPeer;
            break;
        }
    }
    [self.peersConnected removeObject:toRemove];
    
    //reload table
    [self.tableView reloadData];
    
    if (![self.peersConnected count]) {
        self.session = nil;
    }
}

-(void)handleConnecting:(NSString *) peerID {
    NSLog(@"peer is connecting");


}
                         
-(void)handleUnavailable:(NSString *) peerID {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unavailable"
                                                    message:[self.session displayNameForPeer:peerID]
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

-(void)handleConnected:(NSString *) peerID {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Now Connected"
//                                                    message:[self.session displayNameForPeer:peerID]
//                                                   delegate:nil 
//                                          cancelButtonTitle:@"OK" 
//                                          otherButtonTitles:nil, nil];
//    [alert show];
//    [alert release];
    if (!self.isServer && !self.serverPeerId) {
        //TODO I can't set the serverPeerId here. I get 2 connections here.
        self.serverPeerId = self.pendingPeerId;
        self.session.available = NO;
    }
    
    //Add peer to the list
    [self.peersConnected addObject:peerID];
    
    //reload table
    [self.tableView reloadData];
    
    self.pendingPeerId = nil;
}
#pragma mark - GKSessionDelegate
/* Indicates a state change for the given peer.
 */
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    NSLog(@"The session state changed %@ %d", peerID, state);
    switch (state) {
        case GKPeerStateAvailable:
            self.pendingPeerId = peerID;
            [self showActionSheetForServer];
            break;
            
        case GKPeerStateConnected:
            [self handleConnected:peerID];
            NSLog(@"the session is now connected to: %@, %@ Do what you need to do.", session.displayName, peerID);
            break;
            
        case GKPeerStateDisconnected:
            [self handleDisconnect:peerID];
            break;
            
        case GKPeerStateConnecting:
            [self handleConnecting:peerID];
            break;
            
        case GKPeerStateUnavailable:
            [self handleUnavailable:peerID];
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
    NSString *displayName = [self.session displayNameForPeer:peerID];
    NSAssert(displayName, @"Display name must not be nill");
    NSString *title = [NSString stringWithFormat:@"Allow connection from %@", displayName];
    UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle:title 
                                                              message:nil 
                                                             delegate:self 
                                                    cancelButtonTitle:@"Cancel" 
                                                    otherButtonTitles:@"Ok", nil];
    connectionAlert.tag = kSessionRequestAlert;
    self.pendingPeerId = peerID;
    [connectionAlert show];
    [connectionAlert release];

}

/* Indicates a connection error occurred with a peer, which includes connection request failures, or disconnects due to timeouts.
 */
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    NSLog(@"connectionWithPeerFailed %@, %@ %@", session.displayName, peerID, error);
}

/* Indicates an error occurred with the session such as failing to make available.
 */
- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"GKSession didFailWithError %@", error);
}
#pragma mark - UITableView method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.peersConnected count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"client identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier] autorelease];
    }
    NSString *peerId = [self.peersConnected objectAtIndex:indexPath.row];
    NSString *displayName = [self.session displayNameForPeer:peerId];
    cell.textLabel.text = displayName;
    cell.detailTextLabel.text = peerId;
    return cell;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.peersConnected = [[[NSMutableArray alloc] initWithCapacity:8] autorelease];
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
    self.serverLabel    = nil;
    self.pendingPeerId  = nil;
    self.serverPeerId   = nil;
    self.tableView      = nil;
    self.peersConnected = nil;
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
