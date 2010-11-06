//
//  Options.m
//  Pebble
//
//  Created by techion on 9/17/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "SortOptions.h"
#import "RootViewController.h"
#import "DetailViewController.h"
#import "Utility.h"

@implementation SortOptions

@synthesize switchCell, showCompleted, sort, ascending, options, columns;

- (void)viewDidLoad {
    [super viewDidLoad];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);

	sort = -1;
}

- (void)initwithSort:(int)index ascending:(BOOL)value {
	sort = index;
	ascending = value;
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    // Return the number of rows in the section.
	if (section == 0) {
		return 3;
	}
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	DebugLog(D_VERBOSE, @"%s section: %d", __FUNCTION__, section);
	if (section == 0) {
		return @"Sort Order";
	}
	else {
		return @"Checlist";
	}

}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s row: %d  sort: %d", __FUNCTION__, indexPath.row, sort);
	
	if (indexPath.section == 0) {
		static NSString *CellIdentifier = @"Cell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		if (indexPath.row == sort) {
			[cell.imageView setImage:[UIImage imageNamed:(ascending ? @"arrowup.png" : @"arrowdown.png")]];
		}
		else {
			[cell.imageView setImage:[UIImage imageNamed:@"blank.png"]];
		}

		cell.textLabel.text = [columns objectAtIndex:indexPath.row];
		return cell;
	}
	else {
		return switchCell;
	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);

	if (indexPath.row == sort) {
		ascending = !ascending;
	}

	sort = indexPath.row;
	[self.tableView reloadData];
/*
	[[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:temp inSection:0]] setNeedsLayout];

	else {
		[[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sort inSection:0]] setNeedsLayout];
	}
*/
}


#pragma mark -
#pragma mark button handlers
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
	[switchCell release];
	[showCompleted release];
	[options release];
	[columns release];
}


@end
