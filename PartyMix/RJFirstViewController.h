//
//  RJFirstViewController.h
//  PartyMix
//
//  Created by Roderic Campbell on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
@interface RJFirstViewController : UIViewController <GKSessionDelegate,
UIAlertViewDelegate, UIActionSheetDelegate> {

    NSMutableDictionary     *_Sessions;
    
    UILabel                 *_StatusLabel;
    
    //Server
    NSString                *_PendingPeerId;
    UILabel                 *_ServerLabel;
    
    BOOL                    _isServer;
    NSString                *_serverPeerId;
}

@property (nonatomic, retain) IBOutlet  UILabel                   *statusLabel;

//Server
@property (nonatomic, retain)           GKSession                   *session;
@property (nonatomic, retain)           NSString                  *pendingPeerId;
@property (nonatomic, retain) IBOutlet  UILabel                  *serverLabel;
@property (nonatomic, assign)           BOOL                      isServer;
@property (nonatomic, retain)           NSString                   *serverPeerId;
-(IBAction)sendDataPushed:(id)sender;

@end
