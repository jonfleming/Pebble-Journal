    //
//  PriorityPicker.m
//  Pebble
//
//  Created by techion on 7/5/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "PriorityPicker.h"
#import "DebugLog.h"


@implementation PriorityPicker

- (void) cancel:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[self.view removeFromSuperview];

}

- (void) done:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[self.view removeFromSuperview];
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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


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
}


@end
