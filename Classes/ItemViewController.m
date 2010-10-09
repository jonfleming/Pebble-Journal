//
//  EditView.m
//  Notebook
//
//  Created by techion on 5/22/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "ItemViewController.h"
#import "RootViewController.h"
#import "DetailViewController.h"
#import "NotepadViewController.h"
#import "PopoverPicklist.h"
#import "constants.h"
#import "AlertPrompt.h"
#import "Utility.h"

@implementation ItemViewController

@synthesize detailViewController, itemTitle, tags, itemType, tagPickList, tagList, barItem, passwordProtect;

- (IBAction) save:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	if (itemTitle.text != nil) {
		detailViewController.item.itemTitle =  self.itemTitle.text;
	}else {
		detailViewController.item.itemTitle = @"";

	}
	
	if (tags.text != nil) {
			detailViewController.item.tags =  self.tags.text;
	}
	else {
		detailViewController.item.tags = @"";
	}
	
	detailViewController.item.passwordProtected = [NSNumber numberWithBool:self.passwordProtect.on];
	detailViewController.item.itemType = [NSString stringWithFormat:@"%d", self.itemType.selectedSegmentIndex * 2];
	DebugLog(D_VERBOSE, @"--- itemType: %d %@  showComplete: %@  protected: %@", self.itemType.selectedSegmentIndex, 
			 detailViewController.item.itemType, YESNO([detailViewController.item.showCompleted boolValue]), 
			 YESNO([detailViewController.item.passwordProtected boolValue])); 
	
	[self.view removeFromSuperview];
	
	// Set password if not set
	if (self.passwordProtect.on) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *password = [defaults stringForKey:@"password"];

		if ([password length] == 0) {
			[detailViewController.rootViewController promptForPassword:PasswordSet];
		}
	}
	else {
		[self updateRootView];
	}
}

- (void)updateRootView {
	// Update view title
	[detailViewController refreshAfterItemEdit];
	
	// Enable toolbar
	[detailViewController toolbarEnabled:YES];	
}

- (IBAction)cancel:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	// Enable toolbar
	[detailViewController toolbarEnabled:YES];

	[self.view removeFromSuperview];
}

#pragma mark - Password Prompt
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [alertView cancelButtonIndex])
	{
		NSString *password = [(AlertPrompt *)alertView enteredText];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:password forKey:@"password"];
		[defaults synchronize];
		
		[self updateRootView];
	}
	else {
		detailViewController.item.passwordProtected = [NSNumber numberWithBool:FALSE];
	}
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

	self.tags.delegate = self;
	
	NSString *titleText = detailViewController.item.itemTitle;
	if ([titleText length] > 0) {
		self.itemTitle.text = titleText;
		self.barItem.title = @"Edit Subject";
	}
	else {
		self.barItem.title = @"New Subject";
	}
	
	NSString *tagsText = detailViewController.item.tags;
	if (tagsText == nil) {
		tagsText = detailViewController.rootViewController.lastTag;
	}
	self.tags.text = tagsText;
	
	NSString *type = detailViewController.item.itemType;
	if (type != nil) {
		self.itemType.selectedSegmentIndex = [Utility viewIndex:[type intValue]];
	}
	
	[self.passwordProtect setOn:[detailViewController.item.passwordProtected boolValue] animated:TRUE];	
	[self.itemTitle becomeFirstResponder];
	
	// initialize tags picklist
	[self getList];
	tagPickList = [PopoverPicklist alloc];
	tagPickList.target = self.tags;
	[tagPickList loadView];
}

- (void)viewWillDisappear:(BOOL)animated {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[self save:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark -
#pragma mark Data Source
- (void)getList{
	DebugLog(D_TRACE, @"%s", __FUNCTION__);

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:detailViewController.rootViewController.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setReturnsDistinctResults:YES];
	[fetchRequest setResultType:NSDictionaryResultType];
	
	NSDictionary *entityProperties = [entity propertiesByName];	
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"tags"]]];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"tags" ascending:YES] autorelease]]];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tags != nil"];
	[fetchRequest setPredicate:predicate];
	
	
	// Execute the fetch.
	NSError *error;
	NSArray *objects = [detailViewController.rootViewController.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (objects == nil) {
		DebugLog(D_SEVERE, @"!!! Error: fetching tagList");
		// Handle the error.
	}

	self.tagList = [objects valueForKey:@"tags"];
	
	DebugLog(D_VERBOSE, @"tagList count:%d", [tagList count]);
	[fetchRequest release];
}

- (void)updateChoices:(NSString *)substring {
	// Put anything that starts with this substring into the choices array
	// The items in this array will show up in the table view
	[tagPickList.choices removeAllObjects];
	DebugLog(D_VERBOSE, @"updateChoices substring:%@", substring);
	for (NSString *tag in tagList) {
		DebugLog(D_VERBOSE, @"  comparing tag:%@", tag);

		NSRange substringRange = [tag rangeOfString:substring];
		if (substringRange.location == 0) {
			DebugLog(D_VERBOSE, @"  adding tag:%@", tag);
			
			[tagPickList.choices addObject:tag];  
			DebugLog(D_VERBOSE, @"  choices count:%d", [tagPickList.choices count]);
		}
	}

	DebugLog(D_VERBOSE, @"choices count:%d", [tagPickList.choices count]);

	[tagPickList.tableView reloadData];
	
	if ([tagPickList.choices count] == 0) {
		[tagPickList dismissPopover];
	}
}

#pragma mark -
#pragma mark Text Field Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);

	if (textField.tag == 1) {
		NSString *substring = [NSString stringWithString:textField.text];
		substring = [substring stringByReplacingCharactersInRange:range withString:string];
		
		
		// create new array
		[self updateChoices:substring];
		
		// if Popover is not visible, show it
		[tagPickList presentPopover:textField];
	}
	return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[tagPickList dismissPopover];

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

- (void)dealloc {
    [super dealloc];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);

	[detailViewController release];
	[itemTitle release];
	[tags release];
	[itemType release];
	[tagPickList release];
	[tagList release];
	[barItem release];
	[passwordProtect release];
}


@end
