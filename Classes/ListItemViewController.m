//
//  ListItemViewController.m
//  Pebble
//
//  Created by techion on 7/4/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "ListItemViewController.h"
#import "TableViewController.h"
#import "ListViewController.h"
#import "DetailViewController.h"
#import "Utility.h"
#import "DatePicker.h"

@implementation ListItemViewController

@synthesize tableViewController, section, listItemTitle, priorityButton, dueDateButton, dueDate;

- (IBAction) cancel:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	// Enable toolbar
	[tableViewController.listViewController.detailViewController toolbarEnabled:YES];

	[self.view removeFromSuperview];
}

- (IBAction) save:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
	tableViewController.listItem.title = listItemTitle.text;
	tableViewController.listItem.topic = section.text;
	tableViewController.listItem.priority = [NSString stringWithFormat:@"%d", priorityButton.selectedSegmentIndex];
	tableViewController.listItem.dueDate = dueDate;

	[tableViewController saveSelectedListItem];

	// Enable toolbar
	[tableViewController.listViewController.detailViewController toolbarEnabled:YES];
	
	[self.view removeFromSuperview];
}

- (IBAction) selectPriority:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
}

- (IBAction) selectDueDate:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	datePicker = [[DatePicker alloc] initWithNibName:@"DatePicker" bundle:nil];
	datePicker.observer = self;
	datePicker.selectedDate = self.dueDate;
	[self.dueDateButton setTitle:[Utility formatDate:self.dueDate] forState:UIControlStateNormal];
	
	// Next line triggers viewDidLoad
	datePicker.popoverController = [[UIPopoverController alloc] initWithContentViewController:datePicker];
	datePicker.popoverController.delegate = datePicker;
	datePicker.popoverController.popoverContentSize = CGSizeMake(297.0, 189.0);
	
	CGRect rect = dueDateButton.frame;
	rect.origin.y = rect.origin.y + dueDateButton.superview.frame.origin.y;
	
	[datePicker.popoverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	DebugLog(D_VERBOSE, @"  Section: %@  Title: %@", tableViewController.listItem.topic, tableViewController.listItem.title);

	listItemTitle.text = tableViewController.listItem.title;
	section.text = tableViewController.listItem.topic;
	priorityButton.selectedSegmentIndex = [tableViewController.listItem.priority intValue];
	self.dueDate = tableViewController.listItem.dueDate;
	if (self.dueDate == nil) {
		self.dueDate = [[NSDate date] retain];
	}
	[self.dueDateButton setTitle:[Utility formatDate:self.dueDate] forState:UIControlStateNormal];
	
	[self.section becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    if ([keyPath isEqual:@"selectedDate"]) {
		self.dueDate = datePicker.selectedDate;  // causes EXC_BAD_ACESS
		[self.dueDateButton setTitle:[Utility formatDate:self.dueDate] forState:UIControlStateNormal];
		
		[datePicker.popoverController dismissPopoverAnimated:YES];
	}
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
	DebugLog(D_TRACE, @"%s", __FUNCTION__);

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	NSInteger nextTag = textField.tag + 1;
	// Try to find next responder
	UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
	if (nextResponder) {
		// Found next responder, so set it.
		[nextResponder becomeFirstResponder];
	} else {
		// Not found, so remove keyboard.
		[textField resignFirstResponder];
		[self save:self];
	}
	return NO; // We do not want UITextField to insert line-breaks.
}

- (void)dealloc {
    [super dealloc];
	[tableViewController release];
	[section release];
	[listItemTitle release];
	[priorityButton release];
	[dueDateButton release];
	[dueDate release];
}


@end
