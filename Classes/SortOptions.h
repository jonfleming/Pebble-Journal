//
//  Options.h
//  Pebble
//
//  Created by techion on 9/17/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@class Options;

@interface SortOptions : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UITableViewCell *switchCell;
	IBOutlet UISwitch *showCompleted;

	NSArray *columns;
	int sort;
	BOOL ascending;
	Options *options;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *switchCell;
@property (nonatomic, retain) IBOutlet UISwitch *showCompleted;
@property (nonatomic, retain) NSArray *columns;
@property (nonatomic) int sort;
@property (nonatomic) BOOL ascending;
@property (nonatomic, retain) Options *options;

- (void)initwithSort:(int)index ascending:(BOOL)value;
@end
