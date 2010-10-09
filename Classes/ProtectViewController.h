//
//  ProtectViewController.h
//  Pebble
//
//  Created by techion on 10/3/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Options;

@interface ProtectViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UITableViewCell *cell1;
	IBOutlet UITableViewCell *cell2;
	IBOutlet UISwitch *protect;
	Options *options;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *cell1;
@property (nonatomic, retain) IBOutlet UITableViewCell *cell2;
@property (nonatomic, retain) IBOutlet UISwitch *protect;
@property (nonatomic, retain) Options *options;

@end
