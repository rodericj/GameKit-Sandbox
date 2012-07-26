//
//  RJPhotoFeedViewController.m
//  PartyMix
//
//  Created by Roderic Campbell on 7/24/12.
//  Copyright (c) 2012 Aliph. All rights reserved.
//

#import "RJPhotoFeedViewController.h"
#import "common.h"
#import "RJPhotoManager.h"
@interface RJPhotoFeedViewController ()

@end

@implementation RJPhotoFeedViewController

-(NSPredicate *)predicate {
    return nil;
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title = %@) OR (title = %@)", @"The Letter", @"clasic"];
//    return predicate;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.entityName = kEntityNamePhoto;
    self.sortBy     = @"dateTaken";
    [RJPhotoManager findLocalPhotos];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
