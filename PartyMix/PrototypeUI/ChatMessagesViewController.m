//
//  ChatMessagesViewController.m
//  PartyMix
//
//  Created by Roderic Campbell on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChatMessagesViewController.h"
#import "common.h"
#import "ChatMessage.h"
#import "Device.h"

@interface ChatMessagesViewController ()

@end

@implementation ChatMessagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = self.entityName;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
    }
    
    ChatMessage *message = (ChatMessage *)[self.fetchController objectAtIndexPath:indexPath];
    cell.textLabel.text = message.messageContent;
    
    cell.detailTextLabel.text = message.device.deviceName;
    
    // Configure the cell with data from the managed object.
    return cell;
}

- (BOOL)ascendingOrder {
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.entityName = kEntityNameMessage;
    self.sortBy     = @"time";
    self.fetchController.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
