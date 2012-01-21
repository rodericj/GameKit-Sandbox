//
//  RJThirdViewController.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FetchedResultsBackedTableViewController.h"
#import "DataModel.h"

@interface RJThirdViewController : FetchedResultsBackedTableViewController <GKSessionDelegate>

-(IBAction)getRemoteMedia:(id)sender;

@end