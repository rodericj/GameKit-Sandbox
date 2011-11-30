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
UIAlertViewDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {

    NSMutableDictionary     *_Sessions;
    
    UILabel                 *_StatusLabel;
    
    //Server
    NSString                *_PendingPeerId;
    UILabel                 *_ServerLabel;
    
    BOOL                    _isServer;
    NSString                *_serverPeerId;
    
    UITableView             *_tableView;
    
    NSMutableArray          *_peersConnected;
}

@end
