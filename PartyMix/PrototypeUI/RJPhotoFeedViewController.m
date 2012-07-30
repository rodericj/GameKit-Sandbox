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
#import "PhotoItem.h"
#import "RJPhotoDisplayCell.h"
#import "UIFactory.h"

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
    self.fetchController.delegate = self;

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UIFactory sharedUIFactory] generatePhotoDisplayCell];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RJPhotoDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier: [RJPhotoDisplayCell photoDisplayCellReuseIdentifier]];
    if (!cell) {    
        cell = [[UIFactory sharedUIFactory] generatePhotoDisplayCell];
    }
    cell.photoItem = [self.fetchController objectAtIndexPath:indexPath];

    // Configure the cell...
    if (indexPath.row % 2) {
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}


@end
