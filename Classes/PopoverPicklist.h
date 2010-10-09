//
//  PopoverPicklist.h
//  Pebble
//
//  Created by techion on 8/9/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PopoverPicklist : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate> {

	NSMutableArray *choices;
	UIPopoverController *popoverController;
	UITextField *target;
}

@property (nonatomic, retain) NSMutableArray *choices;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UITextField *target;

- (void)presentPopover:(id)sender;
- (void)dismissPopover;

@end
