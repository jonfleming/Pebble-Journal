    //
//  DatePicker.m
//  Pebble
//
//  Created by techion on 7/5/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "DatePicker.h"
#import "DebugLog.h"

@implementation DatePicker

@synthesize selectedDate, datePicker, popoverController, observer;

- (void) cancel:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[popoverController dismissPopoverAnimated:YES];
}

- (void) done:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	self.selectedDate = datePicker.date;
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    [super viewDidLoad];
    [self addObserver:observer forKeyPath:@"selectedDate" options:0 context:nil];
	datePicker.date = selectedDate;
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
	[self removeObserver:observer forKeyPath:@"selectedDate"];
}


- (void)dealloc {
    [super dealloc];
	[selectedDate release];
	[datePicker release];
	[popoverController release];
	[observer release];
}


@end
