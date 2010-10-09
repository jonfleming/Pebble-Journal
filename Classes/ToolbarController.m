    //
//  ToolbarController.m
//  Pebble
//
//  Created by techion on 6/25/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "ToolbarController.h"


@implementation ToolbarController

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
- (void) repositionToolbar:(UIInterfaceOrientation) interfaceOrientation {
	CGRect frame;
	
	// Resize toolbar and set auto-resizing mast for rotation
	if(interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		frame = CGRectMake(0.0, TOOLBAR_TOP, SCREEN_FRAME.size.width, TOOLBAR_HEIGHT);
	}
	else {
		frame = CGRectMake(0.0, 0.0, SCREEN_FRAME.size.width, TOOLBAR_HEIGHT);
	}
	
	toolbar.frame = frame;
	NSLog(@"Notepad repositionToolbar %f  %d", frame.origin.y, interfaceOrientation);	
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
}


@end
