//
//  DetailViewController.m
//  Pebble
//
//  Created by techion on 6/23/10.
//  Copyright Jon Fleming 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "NotepadViewController.h"
#import "LinesView.h"
#import "ListViewController.h"
#import "ChecklistViewController.h"
#import "NotelistViewController.h"
#import "TableViewController.h"
#import "NoteTableViewController.h"
#import "constants.h"
#import "Utility.h"
#import "NoteItem.h"

@implementation DetailViewController

@synthesize window, rootViewController, popoverController, tabBarController;
@synthesize notepadViewController, checklistViewController, notelistViewController, item, buttonShowing, changingViews, popoverButton;
@synthesize orientation, viewStatusArray; 

#pragma mark -
#pragma mark Object insertion

- (IBAction)insertNewItem:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[rootViewController insertNewObject:sender];	
}


#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setItem:(Item *)managedObject {
	DebugLog(D_INFO, @"%s", __FUNCTION__);
	if (managedObject == nil) {
		[item release];
		item = nil;
		
		rootViewController.lastItemPath = nil;
		[self reloadData:tabBarController.selectedIndex];

		// Item was deleted.  Change DetailView to show message indicating nothing is selected.
		NSString *text = rootViewController.protect ? @"Password Protected" : @"Select a Subject";
		switch (tabBarController.selectedIndex) {
			case NOTELIST:
				notelistViewController.titleLabel.text = text;
				break;
			case NOTEPAD:
				notepadViewController.titleLabel.text = text;
				notepadViewController.dateLabel.text = @"";
				notepadViewController.notepadView.text = @"";
				[notepadViewController.notepadView resignFirstResponder];				
				break;
			case CHECKLIST:
				checklistViewController.titleLabel.text = text;
				break;
			default:
				break;
		}
		[self toolbarEnabled:FALSE];
		return;
	}

    changingViews = TRUE;
	
	if (item != managedObject) {
		[item release];
		item = [managedObject retain];
				
		for (int index=0; index<3; index++) {
			[viewStatusArray replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:NO]];
		}
		[rootViewController selectItem:item];

		NSUInteger index = [item.itemType intValue];
		UISearchBar *theSearchBar = rootViewController.theSearchBar;
		if ([theSearchBar.text length] > 0 && theSearchBar.selectedScopeButtonIndex == 2 && index == NOTEPAD) {
			// if active search go to notelist instead of notepad
			index = NOTELIST;
		}
        [self configureView:index];
	}
    
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
		[self toolbarEnabled:YES];
    }
	changingViews = FALSE;
}


/* 
 showView changes visible view based on segmentedControl/tabBarController index
 */
- (void)showView:(NSUInteger)index {
	DebugLog(D_TRACE, @"%s %d", __FUNCTION__, index);

	if (item == nil) {
		return;
	}
	
	if (![item.itemType isEqualToString:[NSString stringWithFormat:@"%d", index]]) {
		item.itemType = [NSString stringWithFormat:@"%d", index];
	}
	
	[self toolbarEnabled:TRUE];
	
	switch (index) {
		case NOTELIST:
			[notepadViewController.notepadView resignFirstResponder];
			[tabBarController setSelectedViewController:notelistViewController];
			[self tabBarController:tabBarController didSelectViewController:notelistViewController];
			[notelistViewController updateTitle];
			break;
			
		case NOTEPAD:			
			[tabBarController setSelectedViewController:notepadViewController];
			[self tabBarController:tabBarController didSelectViewController:notepadViewController];
			[self updateNotepadView];
			[notepadViewController.notepadView becomeFirstResponder];
			[notepadViewController updateTitle];
			break;
			
		case CHECKLIST:
			[tabBarController setSelectedViewController:checklistViewController];
			[self tabBarController:tabBarController didSelectViewController:checklistViewController];
			[checklistViewController updateTitle]; 
			break;
			
		default:
			break;
	}
}

- (void)updateNotepadView {
	NoteTableViewController *noteTableViewController = (NoteTableViewController *)notelistViewController.tableViewController;
	[noteTableViewController updateNotepadView];
}

/*
 configureView initializes the appropriate fetchedResultsController to show the content for the selected Item
 */
- (void)configureView:(NSUInteger)index {
    // Update the user interface for the detail item.
	DebugLog(D_INFO, @"%s view:%d", __FUNCTION__, index);

	if (item == nil) {
		return;
	}
	
	//initializeView and reloadData are called by showView -- tabBarController:didSelectViewController
	[self showView:index];
	
	NoteTableViewController *noteTableViewController = (NoteTableViewController *)notelistViewController.tableViewController;
	TableViewController *tableViewController = (TableViewController *)checklistViewController.tableViewController;
	UITableView *tableView = noteTableViewController.tableView;
	NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
	NSUInteger rows;
	NSUInteger row;
	BOOL filtered = FALSE;
	
	UISearchBar *theSearchBar = rootViewController.theSearchBar;
	 if ([theSearchBar.text length] > 0 && theSearchBar.selectedScopeButtonIndex == 2) {
		 filtered = TRUE;
	 }
	 
	DebugLog(D_INFO, @"--- selected: %d  saved: %d", indexPath.row, [item.lastNoteItemRow intValue]);
	
	switch (index) {
		case NOTELIST:
			if (filtered) {
				DebugLog(D_VERBOSE, @"--- filtered on: %@", theSearchBar.text);
			}
			break;
			
		case NOTEPAD:
			/* if lastNoteItemRow exists
					and row < rows: use it
					else: use last row or create new
			   lastNoteItemRow doesn't exist
					use last row or create new
			 */
			
			rows = [noteTableViewController tableView:tableView numberOfRowsInSection:0];			
			if (item.lastNoteItemRow != nil) {
				row = [item.lastNoteItemRow intValue];
				DebugLog(D_INFO, @"--- Rows: %d  Row: %d", rows, row);

				if (row < rows) {
					if (indexPath == nil || indexPath.row != row) {
						[noteTableViewController selectCell:[NSIndexPath indexPathForRow:row inSection:0]];
					}
					return;
				}
			}
			
			// unable to select lastNoteItemRow
			if (rows > 0) {
				[noteTableViewController selectCell:[NSIndexPath indexPathForRow:(rows - 1) inSection:0]];
			}
			else {
				[noteTableViewController insertNewObject:self];
			}

			break;
		
		case CHECKLIST:
			tableViewController.moving = FALSE;
			tableViewController.changingFocus = FALSE;
			tableViewController.lastSection = nil;		
			DebugLog(D_VERBOSE, @"--- CHECKLIST:");
			break;
			
		default:
			break;
	}
}

- (void) refreshAfterItemEdit {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);

	[rootViewController selectItem:item];
	UITableViewCell *cell = [self currentCell];
	cell.textLabel.text = item.itemTitle;

	[self.notepadViewController updateTitle];
	[self.checklistViewController updateTitle];
	
	[cell setNeedsLayout];
	
	switch ([item.itemType intValue]) {
		case NOTELIST:
		case NOTEPAD:
			if ([self entityCount:@"NoteItem" item:item] == 0) {
				// insert new noteItem
				[self.notelistViewController.tableViewController insertNewObject:self];
			}
			break;
			
		case CHECKLIST:
			if ([self entityCount:@"ListItem" item:item] == 0) {
				// configureView
				[self configureView:CHECKLIST];
				
				// insert new listItem
				[self.checklistViewController.tableViewController performSelector:@selector(insertNewObject:) withObject:self afterDelay:0.5];
			}
		default:
			break;
	}
}

- (NSInteger) entityCount:(NSString *)entityName item:(Item *)theItem {
	DebugLog(D_VERBOSE, @"%s", __FUNCTION__);

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:rootViewController.managedObjectContext];
    [fetchRequest setEntity:entity];
    
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(item == %@)", theItem];

	DebugLog(D_VERBOSE, @"--- predicate: item=%@  showCompleted:%@", theItem.itemTitle, YESNO([theItem.showCompleted boolValue]));

	if ([entityName isEqualToString:@"ListItem"] && theItem.showCompleted != nil) {
		if (![theItem.showCompleted boolValue]) {
			NSPredicate *hideCompleted = [NSPredicate predicateWithFormat:@"(complete == NO)"];
			predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, hideCompleted, nil]];
		}		
	}

	if ([rootViewController.theSearchBar.text length] > 0 && rootViewController.theSearchBar.selectedScopeButtonIndex == 2) {
		NSPredicate *searchMatch;
		
		if ([entityName isEqualToString:@"ListItem"]) {
			searchMatch = [NSPredicate predicateWithFormat:@"(title CONTAINS[c] %@)", rootViewController.theSearchBar.text];
		}
		else {
			searchMatch = [NSPredicate predicateWithFormat:@"(note CONTAINS[c] %@)", rootViewController.theSearchBar.text];
		}

		predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, searchMatch, nil]];
	}
	
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSUInteger count = [rootViewController.managedObjectContext countForFetchRequest:fetchRequest error:&error];
	if (error != nil)
	{
		DebugLog(D_ERROR, @"=== Error getting count");
	}
	
	[fetchRequest release];
	
	return count;
}

#pragma mark -
#pragma mark Save Details 
- (UITableViewCell *)currentCell {
	DebugLog(D_INFO, @"%s", __FUNCTION__);
	NSIndexPath	*indexPath = [[rootViewController fetchedResultsController] indexPathForObject:item];
	return [rootViewController.tableView cellForRowAtIndexPath:indexPath];
}

- (void)saveItem {
	DebugLog(D_INFO, @"%s", __FUNCTION__);
	DebugLog(D_INFO, @"--- Item: %@", item.itemTitle);
	if (item != nil) {
		NSManagedObjectContext *context = rootViewController.managedObjectContext;
		[rootViewController saveObjectContext:context];
	}
}

- (void)saveNote {
	DebugLog(D_INFO, @"%s", __FUNCTION__);
	DebugLog(D_INFO, @"--- Item: %@  NoteItem: %@  Dirty: %@", item.itemTitle, notepadViewController.notepadView.text, YESNO(notepadViewController.dirty));
	if (item == nil) {
		DebugLog(D_ERROR, @"=== item is nil");
		return;
	}

	if (notelistViewController.tableViewController != nil) {
		[notelistViewController.tableViewController updateObject];
	}

	if (notepadViewController.dirty) {
		if ([(NoteTableViewController *) notelistViewController.tableViewController noteItem].title == nil) {
			DebugLog(D_ERROR,@"=== title is nil");
		}
		if ([[(NoteTableViewController *) notelistViewController.tableViewController noteItem].note length] == 0) {
			DebugLog(D_ERROR,@"=== note is nil");
		}
		[self saveItem];
		notepadViewController.dirty = FALSE;
	}
}

- (void)savePosition {
	DebugLog(D_INFO, @"%s", __FUNCTION__);
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	int lastRow = [[rootViewController lastItemPath] row];
	int lastSection = [[rootViewController lastItemPath] section];
	DebugLog(D_INFO, @"--- lastRow: %d  lastSection: %d", lastRow, lastSection);
	
	NSNumber *rowObject = [NSNumber numberWithInt:lastRow];
	NSNumber *sectionObject = [NSNumber numberWithInt:lastSection];
	
	[defaults setValue:rowObject forKey:@"row"];
	[defaults setValue:sectionObject forKey:@"section"];
	[defaults synchronize];
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    barButtonItem.title = ITEMS_TITLE;
	self.popoverButton = barButtonItem;
	buttonShowing = TRUE;
	self.popoverController = pc;
	[self performSelector:@selector(updatePopoverButton) withObject:nil afterDelay:0.7];
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);	
	buttonShowing = FALSE;
	self.popoverController = nil;
	[self performSelector:@selector(updatePopoverButton) withObject:nil afterDelay:0.7];
//	[NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(updatePopoverButton) userInfo:nil repeats:NO];
}

#pragma mark -
#pragma mark Toolbar support

- (void)toolbarEnabled:(BOOL)enabled {
	DebugLog(D_TRACE, @"%s %@", __FUNCTION__, YESNO(enabled));	
	checklistViewController.toolbar.userInteractionEnabled = enabled;
	notelistViewController.toolbar.userInteractionEnabled = enabled;
}

- (void) updatePopoverButton {
	DebugLog(D_VERBOSE, @"%s %@", __FUNCTION__, YESNO(buttonShowing));
	NSUInteger index = tabBarController.selectedIndex;
	
	if (buttonShowing) {
		switch (index) {
			case NOTELIST:
				[self showPopoverButton:notelistViewController.toolbar];
				break;
			case NOTEPAD:
				[self showPopoverButton:notepadViewController.toolbar];
				break;
			case CHECKLIST:
				[self showPopoverButton:checklistViewController.toolbar];			
				break;
			default:
				break;
		}		
	}
	else {
		[self removePopoverButton:notelistViewController.toolbar];
		[self removePopoverButton:notepadViewController.toolbar];
		[self removePopoverButton:checklistViewController.toolbar];
	}
}

- (void)showPopoverButton:(UIToolbar *)toolbar {
	DebugLog(D_VERBOSE, @"%s", __FUNCTION__);
	[self removePopoverButton:toolbar];
	if (toolbar != nil) {
		NSMutableArray *items = [[toolbar items] mutableCopy];
		if (![[[items objectAtIndex:0] title] isEqualToString:[popoverButton title]]) {
			[items insertObject:popoverButton atIndex:0];
			[toolbar setItems:items animated:NO];
		}
		[items release];
	}
}

- (void)removePopoverButton:(UIToolbar *)toolbar {
	DebugLog(D_VERBOSE, @"%s", __FUNCTION__);
	if (toolbar != nil) {
		NSMutableArray *items = [[toolbar items] mutableCopy];
		if ([[[items objectAtIndex:0] title] isEqualToString: ITEMS_TITLE]) {
			[items removeObjectAtIndex:0];
			[toolbar setItems:items animated:NO];
		}

		[items release];
	}
}

#pragma mark -
#pragma mark Tab bar support
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
}
	
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    DebugLog(D_VERBOSE, @"--- didSelectViewController: %@ loaded: %@", viewController.nibName ,YESNO([viewController isViewLoaded]));
	
	NSUInteger index = [self.tabBarController.viewControllers indexOfObject:viewController];
	
	if (![[viewStatusArray objectAtIndex:index] boolValue]) {
		[self initializeView:index];
		[self reloadData:index];
	}
	[self performSelector:@selector(updatePopoverButton) withObject:nil afterDelay:0.2];
	//[NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(updatePopoverButton) userInfo:nil repeats:NO];	
}

- (void)initializeView:(NSUInteger)index {
	DebugLog(D_TRACE, @"%s view:%d", __FUNCTION__, index);

	if (item == nil) {
		return;
	}
	
	[viewStatusArray replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:YES]];
	
	switch (index) {
		case NOTELIST:
		case NOTEPAD:			
			//[checklistViewController.view removeFromSuperview];
			notelistViewController.detailViewController = self;
			notelistViewController.sortFields = [rootViewController.resourceArray objectAtIndex:0];
			break;
			
		case CHECKLIST:
			//[notepadViewController.view removeFromSuperview];
			//[notelistViewController.view removeFromSuperview];
			checklistViewController.detailViewController = self;
			checklistViewController.sortFields = [rootViewController.resourceArray objectAtIndex:1];
			break;
			
		default:
			break;
	}
}

- (void)reloadData:(NSUInteger)index {
	DebugLog(D_TRACE, @"%s view:%d", __FUNCTION__, index);
	
	switch (index) {
		case NOTELIST:
		case NOTEPAD:
			if (notelistViewController.detailViewController != nil) {
				[notelistViewController.tableViewController fetchedResultsControllerInit];
				[notelistViewController.tableViewController.tableView reloadData];				
			}
			break;
			
		case CHECKLIST:
			if (checklistViewController.detailViewController != nil) {
				[checklistViewController.tableViewController fetchedResultsControllerInit];
				[checklistViewController.tableViewController.tableView reloadData];
			}
			break;
			
		default:
			break;
	}
}

#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[self resizeSubviews];
}	

- (void)resizeSubviews {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	DebugLog(D_VERBOSE, @"notepadView.frame: %@", NSStringFromCGRect(notepadViewController.notepadView.frame));
	CGRect frame = self.view.frame;
	frame.origin.x = 0.0;
	frame.origin.y = 0.0;
	notepadViewController.view.frame = frame;
	
	CGRect noteFrame = notepadViewController.linesView.frame;
	noteFrame.size.width = frame.size.width - noteFrame.origin.x;
	noteFrame.size.height = frame.size.height - noteFrame.origin.y;

	notepadViewController.linesView.frame = noteFrame;
	
	[notepadViewController positionDateLabel];	
	[notepadViewController.linesView setNeedsDisplay];
	[notepadViewController.notepadView setNeedsDisplay];
	[notepadViewController.imageView setNeedsDisplay];
 
	[self reportFrames];
}

- (void)reportFrames {
	DebugLog(D_FINE, @"self.view.frame:   %@", NSStringFromCGRect(self.view.frame));
	DebugLog(D_FINE, @"view.frame:        %@", NSStringFromCGRect(notepadViewController.view.frame));
	DebugLog(D_FINE, @"linesView.frame:   %@", NSStringFromCGRect(notepadViewController.linesView.frame));
	DebugLog(D_FINE, @"notepadView.frame: %@", NSStringFromCGRect(notepadViewController.notepadView.frame));
	
	DebugLog(D_FINE, @"view.bounds:        %@", NSStringFromCGRect(notepadViewController.view.bounds));
	DebugLog(D_FINE, @"linesView.bounds:   %@", NSStringFromCGRect(notepadViewController.linesView.bounds));
	DebugLog(D_FINE, @"notepadView.bounds: %@", NSStringFromCGRect(notepadViewController.notepadView.bounds));
	
	DebugLog(D_FINE, @"contentVew.frame: %@", NSStringFromCGSize(notepadViewController.notepadView.contentSize));

	DebugLog(D_TRACE, @"notelist:%@  checklist:%@  editing:%@  inserting:%@  dirty:%@  changingFocus:%@  keyboardUp:%@", 
			 NSStringFromCGRect(notelistViewController.keyboardView.frame),
			 NSStringFromCGRect(checklistViewController.keyboardView.frame),
			 YESNO(checklistViewController.editing),
			 YESNO(checklistViewController.tableViewController.inserting),
			 YESNO(checklistViewController.tableViewController.dirty),
			 YESNO(checklistViewController.tableViewController.changingFocus),
			 YESNO(checklistViewController.keyboardUp));
}

#pragma mark -
#pragma mark View lifecycle

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);

	// Add the tab bar controller's current view as a subview of the window
	CGRect frame = self.view.frame;
	frame.size.height += TABBAR_HEIGHT;
	[self.view addSubview:tabBarController.view];

	// Push tabbar off screen
	frame = CGRectMake(0.0, SCREEN_FRAME.size.height, SCREEN_FRAME.size.width, TABBAR_HEIGHT);
	UITabBar *tabBar = tabBarController.tabBar;
	tabBar.frame = frame;  // resize tab bar
	
	notepadViewController.detailViewController = self;
	
	NSArray *temp = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], nil];
	self.viewStatusArray = [temp mutableCopy];
	[temp release];
	
	
}

- (void)viewWillAppear:(BOOL)animated {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    [super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftMainViewWhenKeybordAppears:) 
												 name:UIKeyboardWillShowNotification object:nil]; 
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnMainViewToInitialposition:) 
												 name:UIKeyboardWillHideNotification object:nil]; 
}

- (void) liftMainViewWhenKeybordAppears:(NSNotification*)aNotification{
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	if (tabBarController.selectedIndex == NOTELIST) {
		DebugLog(D_VERBOSE, @"--- skipping NOTELIST");
		return;
	}
	TabViewBaseController *viewController = (TabViewBaseController *)[tabBarController.viewControllers objectAtIndex:[item.itemType intValue]];
	[self scrollViewForKeyboard:viewController notification:aNotification up:YES]; 
} 

- (void) returnMainViewToInitialposition:(NSNotification*)aNotification{ 
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	if (tabBarController.selectedIndex == NOTELIST) {
		DebugLog(D_FINER, @"--- skipping NOTELIST");
		return;
	}
	TabViewBaseController *viewController = (TabViewBaseController *)[tabBarController.viewControllers objectAtIndex:[item.itemType intValue]];
	[self scrollViewForKeyboard:viewController notification:aNotification up:NO]; 	
}

- (void)moveUp:(id)sender {
	CGRect newFrame = [notepadViewController.linesView frame];
	newFrame.size.height -= 352.0;
	[notepadViewController.linesView setFrame:newFrame]; 
}

- (void)moveDown:(id)sender {
	CGRect newFrame = [notepadViewController.linesView frame];
	newFrame.size.height += 352.0;
	[notepadViewController.linesView setFrame:newFrame]; 
}

- (void)scrollViewForKeyboard:(TabViewBaseController *)viewController notification:(NSNotification*)aNotification up:(BOOL)up { 
	DebugLog(D_TRACE, @"%s%@  editing:%@  changingFocus:%@", __FUNCTION__, YESNO(up), YESNO(checklistViewController.editing), YESNO(checklistViewController.tableViewController.changingFocus));
	[self reportFrames];
	
	UIView *keyboardView = viewController.keyboardView;
	
	if (viewController == checklistViewController) {
		// Don't execute this routine if focus is shifting (becuase keyboard will come back up)
		if (checklistViewController.tableViewController.changingFocus) {
			if (up) {
				// keyboard is coming back up after changing focus
				checklistViewController.tableViewController.changingFocus = FALSE;
			}
			return;
		}
	}

	CGRect newFrame = keyboardView.frame;
	CGRect keyboardEndFrame; 

	DebugLog(D_FINER, @"--- scrolling: %@", up?@"UP":@"DOWN");
	[self reportFrames];
			 
	checklistViewController.editing = up;
	
	if (up && viewController.keyboardUp) {
		return;
	}
	
	if (!up && !viewController.keyboardUp) {
		return;
	}
	
	NSDictionary* userInfo = [aNotification userInfo]; 
	
	// Get animation info from userInfo 
	NSTimeInterval animationDuration; 
	UIViewAnimationCurve animationCurve;
		
	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve]; 
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration]; 
	[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame]; 
	CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil]; 
	CGFloat change = keyboardFrame.size.height * (up? -1 : 1);
	
	// Animate up or down 
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationDuration:animationDuration]; 
	[UIView setAnimationCurve:animationCurve]; 
	
	// special handling for bug
	// conditions: scrolling down and origin.y < 0
	if (newFrame.origin.y < 0) {
		newFrame.origin.y = 0;
		newFrame.size.height += change;		
	}
	
	newFrame.size.height += change;

	DebugLog(D_TRACE, @"--- Scroll view: %@ (%d) frame: %@  change: %f  new frame: %@",
		  (viewController == checklistViewController ? @"checklist" : @"notelist"), tabBarController.selectedIndex,
		  NSStringFromCGRect(keyboardView.frame), change, NSStringFromCGRect(newFrame));
	
	keyboardView.frame = newFrame; 
	
	[UIView commitAnimations];		

	viewController.keyboardUp = up;
	[self reportFrames];

	if (viewController == checklistViewController) {
		NSIndexPath *indexPath = [checklistViewController.tableViewController.tableView 
								  indexPathForCell:(UITableViewCell *) checklistViewController.tableViewController.selectedCell];
		[checklistViewController.tableViewController.tableView
		 scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES]; 
	
	
		// Keyboard is being dismissed without pressing Done
		if (!up && !checklistViewController.tableViewController.inserting) {
			[checklistViewController.tableViewController updateObject];
		}
	}
	
	DebugLog(D_VERBOSE, @"--- editing_k:%@", YESNO(checklistViewController.editing));
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
- (void)viewWillDisappear:(BOOL)animated {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[super viewWillDisappear:animated];

	[[NSNotificationCenter defaultCenter] removeObserver:self]; 	

	[self saveNote];
	[self savePosition];
}

- (void)viewDidDisappear:(BOOL)animated {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[super viewDidDisappear:animated];
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.popoverController = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	[self savePosition];
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[window release];
	[rootViewController release];
	[popoverController release];
	[tabBarController release];
	[notepadViewController release];
	[notelistViewController release];
	[checklistViewController release];
	[item release];
	[popoverButton release];
	[viewStatusArray release];
	
	[super dealloc];
}	


@end
