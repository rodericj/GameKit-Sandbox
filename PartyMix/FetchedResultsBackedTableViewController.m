//
//  FetchedResultsBackedTableViewController.m
//  PartyMix
//
//  Created by Roderic Campbell on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FetchedResultsBackedTableViewController.h"
#import "DataModel.h"
#import "MediaItem.h"

@implementation FetchedResultsBackedTableViewController : UITableViewController

@synthesize fetchController = _fetchController;
@synthesize entityName      = _entityName;
@synthesize sortBy          = _sortBy;

#pragma mark -
-(NSPredicate *)predicate {
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"configure Cell %@", indexPath);
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                          withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark - Fetched Results Controller
-(NSFetchedResultsController *)fetchController {
    
    if (_fetchController) {
        return _fetchController;
    }
    
    NSManagedObjectContext *context = [[DataModel sharedInstance] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.entityName];
    // Configure the request's entity, and optionally its predicate.
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortBy ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    fetchRequest.predicate = [self predicate];
    
    [sortDescriptors release];
    [sortDescriptor release];
    _fetchController = [[NSFetchedResultsController alloc]
                        initWithFetchRequest:fetchRequest
                        managedObjectContext:context
                        sectionNameKeyPath:nil//@"titleFirstLetter"
                        cacheName:self.entityName];
    [fetchRequest release];
    
    NSError *error;
    BOOL success = [_fetchController performFetch:&error];
    NSLog(@"success %d", success);
    return _fetchController;
}

#pragma mark - Responding to changes - NSFetchedResultsControllerDelegate
/*
 Assume self has a property 'tableView' -- as is the case for an instance of a UITableViewController
 subclass -- and a method configureCell:atIndexPath: which updates the contents of a given cell
 with information from a managed object at the given index path in the fetched results controller.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - Table View Datasource and Delegate Functions



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger ret = [[self.fetchController sections] count];
    return ret;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchController sectionForSectionIndexTitle:title atIndex:index];
}

- (void)dealloc {
    
    self.entityName         = nil;
    self.sortBy             = nil;
    self.fetchController    = nil;
    
    [super dealloc];
}
@end
