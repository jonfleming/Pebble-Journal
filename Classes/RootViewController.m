//
//  RootViewController.m
//  Pebble
//
//  Created by techion on 6/23/10.
//  Copyright Jon Fleming 2010. All rights reserved.
//

#import "RootViewController.h"
#import "PebbleAppDelegate.h"
#import "DetailViewController.h"
#import "ItemViewController.h"
#import "NotepadViewController.h"
#import "CheckListViewController.h"
#import "TableViewController.h"
#import "Utility.h"
#import "constants.h"
#import "AlertPrompt.h"

#import "TDBadgedCell.h"
/*
 This template does not ensure user interface consistency during editing operations in the table view. 
 You must implement appropriate methods to provide the user experience you require.
 */

@implementation RootViewController

@synthesize detailViewController, fetchedResultsController, managedObjectContext, lastItemPath, lastTag, itemViewController, theSearchBar;
@synthesize postPasswordAction, resourceArray, protect;

+ (NSArray *)imageList {
	static NSArray *images = nil;
	if (!images) {
		images = [[NSArray arrayWithObjects:@"icon_notepad2.png", @"icon_notepad2.png",@"icon_checklist2.png", nil] retain];
	}
	return images;
}

+ (NSArray *)passwordPrompts {
	static NSArray *prompts = nil;
	if (!prompts) {
		prompts = [[NSArray arrayWithObjects:@"Pebble Journal Password", @"New Password", @"Set Password", @"Current Password", @"Incorrect Password", nil] retain];
	}
	return prompts;
}

#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
	// Subject table view
	self.tableView.rowHeight = 30.0;
	
	// Navigation Bar - Add and Edit buttons
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
											 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)]; 

	// Search Bar
	self.tableView.tableHeaderView = theSearchBar;
	NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        DebugLog(D_ERROR, @"=== Unresolved error %@, %@", error, [error userInfo]);
        DebugBreak();
    }

	// get saved indexPath
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	int section = [defaults integerForKey:@"section"];
	int row = [defaults integerForKey:@"row"];
	self.lastItemPath = [NSIndexPath indexPathForRow:row inSection:section];		
}

- (void)viewWillAppear:(BOOL)animated {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    [super viewDidAppear:animated];
	if (detailViewController.item != nil) {
		NSIndexPath *indexPath = [fetchedResultsController indexPathForObject:detailViewController.item];
		[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
	}
}

- (void)selectItem:(Item *)item {
	DebugLog(D_VERBOSE, @"%s %@", __FUNCTION__, item.itemTitle);

	NSInteger index = [item.itemType intValue];

	[self setCellImage:[detailViewController currentCell] index:index];
	NSIndexPath *indexPath = [self.tableView indexPathForCell:[detailViewController currentCell]];
	[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
	
	// refresh detail viewcol
	if ([[detailViewController.viewStatusArray objectAtIndex:index] boolValue]) {
		[detailViewController reloadData:index];
		if (index == CHECKLIST) {
			[self updateCurrentBadgeCount];
		}
	}
	
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
 */
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.    
    return YES;
}		


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	DebugLog(D_TRACE, @"%s %d", __FUNCTION__, interfaceOrientation);
	detailViewController.orientation = interfaceOrientation;
}

- (void)setCellImage:(TDBadgedCell *)cell index:(NSUInteger)index  {
	DebugLog(D_VERBOSE, @"%s %d", __FUNCTION__, index);
	NSString *file = [[RootViewController imageList] objectAtIndex:index];
	cell.imageView.image = [UIImage imageNamed:file];
	cell.imageView.backgroundColor = [UIColor clearColor];
	cell.imageView.opaque = FALSE;
}

- (void)updateBadgeCount:(NSIndexPath *)indexPath {
	DebugLog(D_INFO, @"%s", __FUNCTION__);
	// cellForRowAtIndexPath calls configureCell which calls setBadge
	TDBadgedCell *cell = (TDBadgedCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
	[cell setNeedsLayout];
}

- (void)updateCurrentBadgeCount {
	DebugLog(D_INFO, @"%s", __FUNCTION__);
	TDBadgedCell *cell = (TDBadgedCell *)[detailViewController currentCell];
	[self setBadge:cell item:detailViewController.item];
	[cell setNeedsLayout];
}

- (void)setBadge:(TDBadgedCell *)cell item:(Item *)managedObject {
	DebugLog(D_VERBOSE, @"%s", __FUNCTION__);

	NSString *entityName;
	if ([managedObject.itemType intValue] == 2) {
		entityName = @"ListItem";
	}
	else {
		entityName = @"NoteItem";
	}

	NSInteger count = [detailViewController entityCount:entityName item:managedObject];
	cell.badgeNumber = count;
	DebugLog(D_VERBOSE, @"--- badge count:%d", count);
}

- (void)configureCell:(TDBadgedCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_VERBOSE, @"%s path:%@", __FUNCTION__, indexPath);
    
    Item *theItem = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = theItem.itemTitle;
	cell.detailTextLabel.text = [Utility formatDate:theItem.modifiedDate];
	//cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
	cell.imageView.backgroundColor = [UIColor lightGrayColor];

	[self setCellImage:cell index:[theItem.itemType intValue]];

	[self setBadge:cell item:theItem];

	// skip configureView if processing search
	if ([theSearchBar.text length] > 0) {
		return;
	}
	
	if (indexPath.row == lastItemPath.row && indexPath.section == lastItemPath.section)
	{
		DebugLog(D_INFO, @"--- lastItemPath: %@", lastItemPath);
		DebugLog(D_INFO, @"--- Item: %@  row: %d", theItem.itemTitle, [theItem.lastNoteItemRow intValue]);

		// triggers ConfigureView
		if (detailViewController.item != theItem) {
			if ([theItem.passwordProtected boolValue]) {
				[self performSelector:@selector(promptForPasswordWithIndex:) withObject:indexPath afterDelay:0.2];
			}
			else {
				detailViewController.item = theItem;
			}			
		}		
	}
}

#pragma mark -
#pragma mark Add a new object

- (void)insertNewObject:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	if (protect) {
		[self functionDisabled];
		return;
	}
	
	[detailViewController saveNote];
    
    NSIndexPath *oldSelection = [self.tableView indexPathForSelectedRow];
    if (oldSelection != nil) {
        [self.tableView deselectRowAtIndexPath:oldSelection animated:YES];
    }	

    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
    Item *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
	newManagedObject.creationDate = [NSDate date];
	newManagedObject.modifiedDate = [NSDate date];
	newManagedObject.itemTitle = @"";
	newManagedObject.tags = lastTag != nil ? lastTag : @"";
    
	[self saveObjectContext:context];
    
    NSIndexPath *insertionPath = [fetchedResultsController indexPathForObject:newManagedObject];
	if (lastItemPath != nil) {
		[lastItemPath release];
	}
	lastItemPath = insertionPath;
	
	[self.tableView reloadData];
    //[self.tableView selectRowAtIndexPath:insertionPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    detailViewController.item = newManagedObject;
	
	[self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:insertionPath];
}


#pragma mark -
#pragma mark Table view data source
- (void)saveObjectContext:(NSManagedObjectContext *)context {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
	NSError *error = nil;
	if (![context save:&error]) {
		DebugLog(D_TRACE, @"Unresolved error %@, %@", error, [error userInfo]);
		DebugBreak();
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_VERBOSE, @"%s %@", __FUNCTION__, indexPath);    
    static NSString *CellIdentifier = @"Cell";
    
    TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		DebugLog(D_VERBOSE, @"--- Deleting item: %@", detailViewController.item.itemTitle);
        
        // Delete the managed object.
        Item *objectToDelete = (Item *)[fetchedResultsController objectAtIndexPath:indexPath];		
		
        if (detailViewController.item == objectToDelete) {
            detailViewController.item = nil;
        }
        
        NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
        [context deleteObject:objectToDelete];
		[self saveObjectContext:context];
    }   
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	Item *objectToEdit = (Item *)[fetchedResultsController objectAtIndexPath:indexPath];
	return ![objectToEdit.passwordProtected boolValue];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return YES;
}

#pragma mark - Password Prompt
- (BOOL)itemIsProtected:(Item *)theItem {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *password = [defaults stringForKey:@"password"];
	
	return ([password length] != 0 && [theItem.passwordProtected boolValue]);
}

- (void)promptForPassword:(NSUInteger)prompt {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[self promptForPasswordWithTitle:[[RootViewController passwordPrompts] objectAtIndex:prompt]];
}

- (void)promptForPasswordWithIndex:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	detailViewController.item = nil;
	self.lastItemPath = indexPath;	
	[detailViewController configureView:0];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *password = [defaults stringForKey:@"password"];
	
	if ([password length] != 0) {
		[self promptForPassword:PasswordPebble];
	}
	else {
		// ignore passwordProtected setting if password is not set
		detailViewController.item = [[self fetchedResultsController] objectAtIndexPath:self.lastItemPath];
	}
}

- (void)promptForPasswordWithTitle:(NSString *)title {	
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	AlertPrompt *prompt = [AlertPrompt alloc];
	prompt = [prompt initWithTitle:title message:@"Password" delegate:self cancelButtonTitle:@"Cancel" okButtonTitle:@"OK"];
	[prompt show];
	[prompt release];
	[prompt performSelector:@selector(setFocus) withObject:nil afterDelay:0.8];
}

- (void)changePassword {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *password = [defaults stringForKey:@"password"];

	if ([password length] == 0) {
		[self promptForPassword:PasswordSet];
	}
	else {
		[self promptForPassword:PasswordCurrent];
	}
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	DebugLog(D_INFO, @"%s %@", __FUNCTION__, alertView.title);
	int prompt = [[RootViewController passwordPrompts] indexOfObject:alertView.title];
				   
	switch (prompt) {
		case PasswordIncorrect:
			if (buttonIndex != [alertView cancelButtonIndex]) {
				// retry
				[self tableView:self.tableView didSelectRowAtIndexPath:self.lastItemPath];
			}
			else {
				[self.tableView deselectRowAtIndexPath:self.lastItemPath animated:YES];
				detailViewController.item = nil;
			}			
			break;
		case PasswordPebble:
			//[[(AlertPrompt *)alertView textField] resignFirstResponder]; 
			if (buttonIndex != [alertView cancelButtonIndex])
			{
				NSString *enteredText = [(AlertPrompt *)alertView enteredText];
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				NSString *password = [defaults stringForKey:@"password"];
				
				if ([enteredText isEqualToString:password]) {
					if (!protect && detailViewController != nil) {
						detailViewController.item = [[self fetchedResultsController] objectAtIndexPath:self.lastItemPath];
					}
					else {
						protect = FALSE;
						fetchedResultsController = nil;						
					}
					
					if (postPasswordAction != nil) {
						[self performSelector:self.postPasswordAction];
						self.postPasswordAction = nil;
					}
				}
				else {
					protect = TRUE;
					UIAlertView	*alertView = [[UIAlertView alloc] initWithTitle:@"Incorrect Password" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
					[alertView show];
					[alertView release];
				}
			}
			else {
				protect = TRUE;
				[self.tableView deselectRowAtIndexPath:self.lastItemPath animated:YES];
				detailViewController.item = nil;
			}				
			break;

		case PasswordSet:
		case PasswordNew:
			if (buttonIndex != [alertView cancelButtonIndex])
			{
				NSString *password = [(AlertPrompt *)alertView enteredText];
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				[defaults setValue:password forKey:@"password"];
				[defaults synchronize];
				
				if ([password length] == 0) {
					//detailViewController.item.passwordProtected = [NSNumber numberWithBool:FALSE];
				}
				[self updateRootView];
			}
			else {
				//detailViewController.item.passwordProtected = [NSNumber numberWithBool:FALSE];
			}			
			break;

		case PasswordCurrent:
			if (buttonIndex != [alertView cancelButtonIndex])
			{
				NSString *enteredText = [(AlertPrompt *)alertView enteredText];
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				NSString *password = [defaults stringForKey:@"password"];
				
				if ([enteredText isEqualToString:password]) {
					[self promptForPassword:PasswordNew];
				}
				else {
					UIAlertView	*alertView = [[UIAlertView alloc] initWithTitle:@"Incorrect Password" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
					[alertView show];
					[alertView release];
				}
			}
			break;
			
		default:
			break;
	}
}

- (BOOL)functionDisabled {
	if (protect) {
		postPasswordAction = @selector(performSearch);
		[self promptForPassword:PasswordPebble];
	}
	return protect;
}
	
- (void)updateRootView {
	// Update view title
	[detailViewController refreshAfterItemEdit];
	
	// Enable toolbar
	[detailViewController toolbarEnabled:YES];	
}

#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	// Save pending changes
   	[detailViewController saveNote];
	[detailViewController.checklistViewController.tableViewController updateObject];

	self.lastItemPath = nil;
	
    // Set the item in the detail view controller.
	Item *theItem = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	
	if ([self itemIsProtected:theItem]) {
		[self promptForPasswordWithIndex:indexPath];
	}
	else {
		detailViewController.item = theItem;
		
		// Save indexPath
		DebugLog(D_VERBOSE, @"--- Saving indexPath:%@ -- %@", detailViewController.item.tags, indexPath);
		self.lastItemPath = indexPath;	
		self.lastTag = detailViewController.item.tags;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	DebugLog(D_VERBOSE, @"%s section: %d", __FUNCTION__, section);
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	NSString *sectionTitle = [sectionInfo name];
	DebugLog(D_VERBOSE, @"--- Section Title: %@", sectionTitle);
	if ([sectionTitle length] == 0) {
		sectionTitle = @"";
	}
	
	return sectionTitle;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
	// Save pending changes
   	//[detailViewController saveNote];
	//[detailViewController.checklistViewController.tableViewController updateObject];
	
    // Set the item in the detail view controller.
	Item *theItem = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	
	if ([self itemIsProtected:theItem]) {
		self.postPasswordAction = @selector(postShowItemView);
		[self tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
	else 
	{
		[self tableView:tableView didSelectRowAtIndexPath:indexPath];
		[self showItemView];
	}
	
	if (detailViewController.popoverController != nil) {
        [detailViewController.popoverController dismissPopoverAnimated:YES];
    }		
}

- (void)postShowItemView {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[self performSelector:@selector(showItemView) withObject:nil afterDelay:0.5];
}

- (void)showItemView {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	itemViewController = [[ItemViewController alloc] initWithNibName:@"ItemView" bundle:nil];
	itemViewController.detailViewController = detailViewController;
	itemViewController.view.backgroundColor = [UIColor clearColor];
	
	UIView *topView = [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0];
	[topView addSubview:itemViewController.view];

	[UIView beginAnimations:nil context:nil];   
	[UIView setAnimationDuration:0.7]; // animation duration in seconds   
	itemViewController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
	[UIView commitAnimations];	
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    [super setEditing:editing animated:animate];

    if(!editing)
    {
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark Fetched results controller, Search bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
	[self performSearch];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
	[self performSearch];
}

- (void)performSearch {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	if (fetchedResultsController != nil) {
		[fetchedResultsController release];
		fetchedResultsController = nil;
		[self fetchedResultsController];
	}
	
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        DebugLog(D_TRACE, @"Unresolved error %@, %@", error, [error userInfo]);
        DebugBreak();
	}
	[self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

	// Set predicate -- filter based on search text
	NSPredicate *predicate;
	if (protect) {
		DebugLog(D_INFO, @"--- Setting predicate to return 0 results");
		predicate = [NSPredicate predicateWithFormat: @"FALSEPREDICATE"];
	}
	else {
		if ([theSearchBar.text length] > 0) {
			DebugLog(D_INFO, @"---Setting predicate to: %@  scope %d", theSearchBar.text, theSearchBar.selectedScopeButtonIndex);
			switch (theSearchBar.selectedScopeButtonIndex) {
				case 0: // Tags
					predicate = [NSPredicate predicateWithFormat: @"tags CONTAINS[c] %@", theSearchBar.text];
					break;
				case 1: // Title
					predicate = [NSPredicate predicateWithFormat: @"itemTitle CONTAINS[c] %@", theSearchBar.text];
					break;
				case 2: // Page
					predicate = [NSPredicate predicateWithFormat: @"(noteItems.title CONTAINS[c] %@) OR (listItems.title CONTAINS[c] %@)", 
								 theSearchBar.text, theSearchBar.text];
					break;
				default:
					predicate = [NSPredicate predicateWithFormat: @"tags CONTAINS[c] %@", theSearchBar.text];
			}		
		}
		else {
			predicate = [NSPredicate predicateWithFormat: @"TRUEPREDICATE"];
			DebugLog(D_INFO, @"---Setting predicate to: %@", theSearchBar.text);
		}
	}
	[fetchRequest setPredicate:predicate];
	
    // Edit the sort key as appropriate.
	NSSortDescriptor *sectionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tags" ascending:YES];
    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemTitle" ascending:YES];
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifiedDate" ascending:NO];
	
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sectionDescriptor, titleDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								managedObjectContext:managedObjectContext 
																								  sectionNameKeyPath:@"tags" cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
	[sectionDescriptor release];
    [titleDescriptor release];
    [dateDescriptor release];
    [sortDescriptors release];
    
    return fetchedResultsController;
}    

#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
			DebugLog(D_VERBOSE, @"--- Deleting section: %d", sectionIndex);
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
			DebugLog(D_VERBOSE, @"--- Inserting item at: %@", newIndexPath);
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
			DebugLog(D_VERBOSE, @"--- Deleting item at: %@", indexPath);
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
			DebugLog(D_VERBOSE, @"--- Updating item at: %@", indexPath);
            //[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
			DebugLog(D_VERBOSE, @"--- Moving item at: %@", indexPath);
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    [self.tableView endUpdates];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    
    [detailViewController release];
	[itemViewController release];
    [fetchedResultsController release];
    [managedObjectContext release];
	[theSearchBar release];
	[lastItemPath release];
	[lastTag release];
	[resourceArray release];
    
    [super dealloc];
}

@end
