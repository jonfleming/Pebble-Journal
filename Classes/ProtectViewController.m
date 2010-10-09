//
//  ProtectViewController.m
//  Pebble
//
//  Created by techion on 10/3/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "ProtectViewController.h"
#import "constants.h"
#import "Utility.h"
#import "DebugLog.h"
#import "Options.h"

@implementation ProtectViewController

@synthesize cell1, cell2, protect, options;
#pragma mark -
#pragma mark Initialization


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    [super viewDidLoad];
	cell1.frame = CGRectMake(cell1.frame.origin.x, cell1.frame.origin.y, 
							 cell1.frame.size.width - 10, cell1.frame.size.height);
	cell2.frame = CGRectMake(cell2.frame.origin.x, cell2.frame.origin.y, 
							 cell2.frame.size.width - 10, cell2.frame.size.height);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    // Return the number of rows in the section.
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);

	if (indexPath.row == 0)
        return cell1;

	return cell2;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);	
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[options changePassword:self];
}	

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[cell1 release];
	[cell2 release];
	[protect release];
	[options release];
}


@end

