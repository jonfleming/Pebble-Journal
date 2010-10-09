    //
//  TabViewBaseController.m
//  Pebble
//
//  Created by techion on 8/2/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "TabViewBaseController.h"
#import "DetailViewController.h"

@implementation TabViewBaseController

@synthesize detailViewController, titleLabel, toolbar, keyboardView, keyboardUp;

- (void)updateTitle {
	DebugLog(D_TRACE, @"%s %@", __FUNCTION__, detailViewController.item.itemTitle);
	self.titleLabel.text = detailViewController.item.itemTitle;
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
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
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

	[detailViewController release];
	[titleLabel release];
	[toolbar release];
	[keyboardView release];
}


@end
