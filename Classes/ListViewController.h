//
//  CheckListViewController.h
//  Pebble
//
//  Created by techion on 6/24/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "TabViewBaseController.h"

@class DetailViewController;
@class TableViewController;
@class SortOptions;
@class Options;

@interface ListViewController : TabViewBaseController <UIPopoverControllerDelegate> {
	TableViewController *tableViewController;
	IBOutlet UIView *listView;
	IBOutlet UIBarButtonItem *editButton;
	NSArray *sortFields;
}

@property (nonatomic, retain) IBOutlet TableViewController *tableViewController;
@property (nonatomic, retain) IBOutlet UIView *listView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, retain) NSArray *sortFields;

- (IBAction)insertNewObject:(id)sender;
- (IBAction)editTableView:(id)sender;
- (NSIndexPath *)indexPathForSelectedCell;
- (IBAction)showProtect:(id)sender;
- (IBAction)showOptions:(id)sender;
- (void)initOptions:(Options *)options;
- (BOOL)functionDisabled;
@end
