//
//  RJFourthViewController.h
//  PartyMix
//
//  Created by Roderic Campbell on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FetchedResultsBackedTableViewController.h"
#import "RJMusicPlayerInterface.h"

@interface RJFourthViewController : FetchedResultsBackedTableViewController <UIAlertViewDelegate> {
    RJMusicPlayerInterface *_musicInterface;
}

@end
