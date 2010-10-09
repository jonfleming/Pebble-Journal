//
//  CheckListViewController.m
//  Pebble
//
//  Created by techion on 6/24/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "ListViewController.h"
#import "constants.h"
#import "DetailViewController.h"
#import "ChecklistViewController.h"
#import "TableViewController.h"
#import "NoteTableViewController.h"
#import "RootViewController.h"
#import "Options.h"
#import "SortOptions.h"
#import "Utility.h"
#import "ProtectViewController.h"

@implementation ListViewController

@synthesize tableViewController, listView, editButton, sortFields;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

- (NSIndexPath *)indexPathForSelectedCell {
	UITableViewCell *cell = tableViewController.selectedCell;
	NSIndexPath *indexPath = nil;
	
	if (cell) {
		indexPath = [tableViewController.tableView indexPathForCell:cell];
	}
	
	return indexPath;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
	if ([self isKindOfClass:[ChecklistViewController class]]) {
		tableViewController = [[TableViewController alloc] initWithNibName:@"TableView" bundle:nil];
	}
	else {
		tableViewController = [[NoteTableViewController alloc] initWithNibName:@"TableView" bundle:nil];
	}
	
	tableViewController.listViewController = self;
	keyboardView = tableViewController.tableView;
	
	//tableViewController.tableView.frame = CGRectMake(-30.0, 0.0, 768.0 + 60.0, 1024.0);
	[self.listView addSubview:tableViewController.tableView];
	
	editButton.style = UIBarButtonItemStyleBordered;
	editButton.title = @"Edit";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
}

- (void)viewWillDisappear:(BOOL)animated {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Toolbar button handlers
- (IBAction)showProtect:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	if ([self functionDisabled]) {
		return;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL protect = [defaults boolForKey:@"passwordProtect"];

	Options *options = [[Options alloc] initWithNibName:@"OptionsView" bundle:nil];
	[options initForProtectView];
	options.detailViewController = detailViewController;
	
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:options];
	popover.delegate = self;
	popover.popoverContentSize = CGSizeMake(337, 172); //CGSizeMake(283, 149);
	options.popoverController = popover;
	options.protectViewController.protect.on = protect;
	
	UIBarButtonItem *button = (UIBarButtonItem *)sender;	
	[popover presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)showOptions:(id)sender {
	DebugLog(D_INFO, @"%s", __FUNCTION__);
	if ([self functionDisabled]) {
		return;
	}
	
	int index = [Utility viewIndex:detailViewController.tabBarController.selectedIndex];
	NSArray *buttonTitles = [detailViewController.rootViewController.resourceArray objectAtIndex:index + 2];

	Options *options = [[Options alloc] initWithNibName:@"OptionsView" bundle:nil];
	[options initForSortView:buttonTitles];

	options.detailViewController = detailViewController;
	
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:options];
	popover.delegate = self;
	options.popoverController = popover;
	
	switch (detailViewController.tabBarController.selectedIndex) {
		case NOTELIST:
			popover.popoverContentSize = CGSizeMake(290, 215);
			options.sortOptions.showCompleted.hidden = TRUE;
			break;
		case CHECKLIST:
			popover.popoverContentSize = CGSizeMake(290, 300);
			[options.sortOptions.showCompleted setOn:[detailViewController.item.showCompleted boolValue]];
			break;
		default:
			break;
	}
	
	[self initOptions:options];
	UIBarButtonItem *button = (UIBarButtonItem *)sender;	
	[popover presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)initOptions:(Options *)options {
	DebugLog(D_INFO, @"%s sortField: %@", __FUNCTION__,detailViewController.item.sortField);
	
	BOOL ascending = FALSE;
	int sort = 0;
	if (detailViewController.item.sortField != nil) {
		DebugLog(D_INFO, @"sortField: %@", detailViewController.item.sortField);
		sort = [sortFields indexOfObject:detailViewController.item.sortField];
		if (sort == NSNotFound) {
			sort = 0;
		}
	}
	if (detailViewController.item.sortAscending != nil) {
		ascending = [detailViewController.item.sortAscending boolValue];
	}
	[options.sortOptions initwithSort:sort ascending:ascending];
	
	NSString *field = [sortFields objectAtIndex:options.sortOptions.sort];
	DebugLog(D_INFO,@"=== options.sort: %d  ascending: %@  field: %@", options.sortOptions.sort, YESNO(options.sortOptions.ascending), field);
}

- (void)popoverControllerDidDismissPopover: (UIPopoverController *)popoverController {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	Options *options = (Options *)popoverController.contentViewController;
	if (options.sortOptions != nil) {
		
		detailViewController.item.sortField = [sortFields objectAtIndex: options.sortOptions.sort];
		detailViewController.item.sortAscending = [NSNumber numberWithBool:options.sortOptions.ascending];
		detailViewController.item.showCompleted = [NSNumber numberWithBool:options.sortOptions.showCompleted.on];

		DebugLog(D_INFO, @"--- sortField: %@  ascending:%@", detailViewController.item.sortField, YESNO(options.sortOptions.ascending));
		
		[self.tableViewController fetchedResultsControllerInit];
		[self.tableViewController.tableView reloadData];		
	}
	else {
		DebugLog(D_INFO, @"--- protect:%@", YESNO(options.protectViewController.protect.on));

		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSNumber *protect = [NSNumber numberWithBool:options.protectViewController.protect.on];
		[defaults setValue:protect forKey:@"passwordProtect"];
		
		// Set password if not set
		if (options.protectViewController.protect.on) {
			NSString *password = [defaults stringForKey:@"password"];
			
			if ([password length] == 0) {
				[detailViewController.rootViewController promptForPassword:PasswordSet];
			}
		}
	}
}

- (BOOL)functionDisabled {
	if (detailViewController == nil) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Function Disabled" message:@"Password Protected" 
														   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alertView show];
		return TRUE;
	}
	return FALSE;
}

- (IBAction)insertNewObject:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);	
	if ([self functionDisabled]) {
		return;
	}
	[tableViewController insertNewObject:sender];
}

- (IBAction)editTableView:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	if (self.tableViewController.editing) {
		[tableViewController setEditing:FALSE animated:TRUE];
		editButton.style = UIBarButtonItemStyleBordered;
		editButton.title = @"Edit";
		
		//[tableViewController showData];
	}
	else {
		[tableViewController setEditing:TRUE animated:TRUE];
		editButton.style = UIBarButtonItemStyleDone;
		editButton.title = @"Done";
	}
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc {
    [super dealloc];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
	[tableViewController release];
	[listView release];	
	[editButton release];
	[sortFields release];
}


@end
