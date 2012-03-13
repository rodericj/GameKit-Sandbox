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
#import "DataModel.h"
#import "Device.h"
#import "RJSessionManager.h"

@interface ChatMessagesViewController ()
@property (nonatomic, retain) UITextField *textField;
@end

@implementation ChatMessagesViewController
@synthesize textField = _textField;

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
    if ([message.unread boolValue]) {
        message.unread = [NSNumber numberWithBool:NO];
    }
    // Configure the cell with data from the managed object.
    return cell;
}

- (BOOL)ascendingOrder {
    return NO;
}

- (void)sendChat {
    [[RJSessionManager sharedInstance] sendMessageToAll:self.textField.text];
    self.textField.text = @"";
    [self.textField resignFirstResponder];
}

- (void)setUpTableHeader {
    UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)] autorelease];
    header.backgroundColor = [UIColor grayColor];
    
    self.textField = [[[UITextField alloc] initWithFrame:CGRectMake(5, 5, 310, 30)] autorelease];
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.placeholder = @"send a chat";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(200, 40, 90, 30);
    [button setTitle:@"Submit" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sendChat) forControlEvents:UIControlEventTouchUpInside];
    
    [header addSubview:self.textField];
    [header addSubview:button];
    
    self.tableView.tableHeaderView = header;
}

- (void)updateBadge {
    NSUInteger numUnread = [[DataModel sharedInstance] numberOfUnreadMessage];
    if (numUnread) {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", numUnread];
    }
    else {
        self.tabBarItem.badgeValue = nil;
    }
    [self performSelector:@selector(updateBadge) withObject:nil afterDelay:4];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.entityName = kEntityNameMessage;
    self.sortBy     = @"time";
    self.fetchController.delegate = self;

    [self setUpTableHeader];
    // TODO when I know how to efficiently update this, update the badge
    // [self updateBadge];
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
