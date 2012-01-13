//
//  RJSecondViewController.h
//  PartyMix
//
//  Created by Roderic Campbell on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FetchedResultsBackedTableViewController.h"

@interface RJSecondViewController : FetchedResultsBackedTableViewController <UITableViewDelegate, UITableViewDataSource> {
}

-(IBAction)getMPMediaItems:(id)sender;

@end
