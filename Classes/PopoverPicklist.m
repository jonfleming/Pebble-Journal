    //
//  PopoverPicklist.m
//  Pebble
//
//  Created by techion on 8/9/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "PopoverPicklist.h"
#import "DetailViewController.h"

@implementation PopoverPicklist

@synthesize choices, popoverController, target;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 400, 400) style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.scrollEnabled = TRUE;
	self.tableView = tableView;
	
	popoverController = [[UIPopoverController alloc] initWithContentViewController:self];
	popoverController.delegate = self;
	popoverController.popoverContentSize = CGSizeMake(400, 400);
	
	choices = [[NSMutableArray alloc] initWithObjects:nil];
}

- (void)presentPopover:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	UIView *inView = (UIView *)sender;
	CGRect rect = CGRectMake(0, 0, 22, 22);
	
	DebugLog(D_VERBOSE, @"--- rect=%@", NSStringFromCGRect(rect));
	
	if ([choices count] > 0) {
		if (!popoverController.popoverVisible) {
			[popoverController presentPopoverFromRect:rect inView:inView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
		}
	}
	else {
		[self dismissPopover];
	}

}

- (void)dismissPopover {
	if (popoverController.popoverVisible) {
		[popoverController dismissPopoverAnimated:YES];
	}
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/
#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [choices count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
    cell.textLabel.text = [choices objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	target.text = [choices objectAtIndex:indexPath.row];
	[popoverController dismissPopoverAnimated:YES];
}	

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[choices release];
	[popoverController release];
	[target release];
}


@end
