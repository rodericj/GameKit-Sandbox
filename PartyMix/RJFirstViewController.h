//
//  RJFirstViewController.h
//  PartyMix
//
//  Created by Roderic Campbell on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FetchedResultsBackedTableViewController.h"
#import <GameKit/GameKit.h>
#import "DataModel.h"

@interface RJFirstViewController : FetchedResultsBackedTableViewController <UIAlertViewDelegate, UIActionSheetDelegate, GKSessionDelegate, MessageRecipient> {

    UILabel                 *_ServerLabel;
    UILabel                 *_StatusLabel;
    UITableView             *_tableView;
    Device                  *_deviceToConnectTo;

}

@end
