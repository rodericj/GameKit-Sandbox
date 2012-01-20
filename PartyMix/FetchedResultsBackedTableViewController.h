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
    NSString                    *_entityName;
    NSString                    *_sortBy;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchController;
@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) NSString *sortBy;

@end
