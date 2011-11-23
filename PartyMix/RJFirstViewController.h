//
//  RJFirstViewController.h
//  PartyMix
//
//  Created by Roderic Campbell on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
@interface RJFirstViewController : UIViewController <GKPeerPickerControllerDelegate, GKSessionDelegate, UIAlertViewDelegate, GKMatchmakerViewControllerDelegate> {

    GKPeerPickerController  *mPicker;
    NSMutableDictionary     *mSessions;
    
    UILabel                 *mStatusLabel;
}

@property (nonatomic, retain)           GKPeerPickerController    *picker;
@property (nonatomic, retain)           NSMutableDictionary       *sessions;
@property (nonatomic, retain) IBOutlet  UILabel                   *statusLabel;

-(IBAction)sendDataPushed:(id)sender;

@end
