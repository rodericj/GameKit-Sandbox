//
//  FetchedResultsBackedTableViewController.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface FetchedResultsBackedTableViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchController;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchController;

@end
