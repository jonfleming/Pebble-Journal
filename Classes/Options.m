//
//  Options.m
//  Pebble
//
//  Created by techion on 9/17/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "Options.h"
#import "ProtectViewController.h"
#import "SortOptions.h"
#import "RootViewController.h"
#import "DetailViewController.h"
#import "Utility.h"

@implementation Options

@synthesize protectViewController,detailViewController, popoverController, sortOptions, navigationItem;

- (void)initForProtectView {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
	protectViewController = [[ProtectViewController alloc] initWithNibName:@"ProtectView" bundle:nil];
	protectViewController.options = self;
	
	[self.view addSubview:protectViewController.tableView];
	protectViewController.tableView.frame = CGRectMake(0.0, 44.0, 335.0, 128.0);
}

- (void)initForSortView:(NSArray *)columns {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);

	//self.view.frame
	sortOptions = [[SortOptions alloc] initWithNibName:@"SortOptions" bundle:nil];
	sortOptions.options = self;
	sortOptions.columns = columns; //[NSArray arrayWithArray:columns];
	
	[self.view addSubview:sortOptions.tableView];
	self.navigationItem.title = @"Options";
	sortOptions.tableView.frame = CGRectMake(0.0, 44.0, 307.0, 254.0);
	DebugLog(D_INFO, @"--- Setting sortOptions frame: %@", NSStringFromCGRect(sortOptions.tableView.frame));
}

- (void)viewDidLoad {
    [super viewDidLoad];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
}

#pragma mark -
#pragma mark button handlers
- (void)changePassword:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[detailViewController.rootViewController changePassword];
	[popoverController dismissPopoverAnimated:TRUE];
}

- (void)done:(id)sender {
	[popoverController dismissPopoverAnimated:TRUE];
	[self.popoverController.delegate popoverControllerDidDismissPopover: self.popoverController];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [super dealloc];
	[protectViewController release];
	[detailViewController release];
	[popoverController release];
	[sortOptions release];
	[navigationItem release];
}


@end
