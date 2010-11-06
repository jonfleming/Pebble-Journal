//
//  TableViewController.m
//  Pebble
//
//  Created by techion on 6/24/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "TableViewController.h"
#import "RootViewController.h"
#import "ListViewController.h"
#import "ChecklistViewController.h"
#import "NotelistViewController.h"
#import "DetailViewController.h"
#import "ListItemViewController.h"
#import "Item.h"
#import "listItem.h"
#import "TextFieldCell.h"
#import "Utility.h"
#import "constants.h"
@implementation TableViewController

@synthesize listItem, fetchedResultsController, listViewController, selectedCell, listItemView, moving, changingFocus;
@synthesize lastSection, inserting, dirty, dragImage, lastLocation;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/

- (void)report {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	if (listViewController.detailViewController.item == nil) {
		DebugLog(D_TRACE, @"=== item is nil");
		return;
	}
	DebugLog(D_TRACE, @"--- itemType: %@", listViewController.detailViewController.item.itemType);
	DebugLog(D_TRACE, @"--- Item: %@",listViewController.detailViewController.item.itemTitle);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	DebugLog(D_VERBOSE, @"--- TableView numberOfSectionsInTableView: %d", [[fetchedResultsController sections] count]);
    return [[fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	DebugLog(D_VERBOSE, @"--- TableView numberOfRowsInSection: %d", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_VERBOSE, @"%s %@", __FUNCTION__, indexPath);
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell%@",listViewController.titleLabel.text];
    
    TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
				
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.contentMode = UIViewContentModeLeft;
		cell.shouldIndentWhileEditing = FALSE;

		// textField setup
		cell.textField = [[UITextField alloc] initWithFrame:CGRectZero];
		cell.textField.clearsOnBeginEditing = NO;
		cell.textField.returnKeyType = UIReturnKeyDefault;
		cell.textField.userInteractionEnabled = NO; // handled by didSelectRowAtIndexPath
		cell.textField.delegate = self;
		cell.textField.hidden = YES;
		[cell.contentView addSubview:cell.textField];
		
		//checkbox setup
		cell.checkboxButton = [[UIButton alloc] init];
		cell.checkboxButton.backgroundColor = [UIColor clearColor];
		[cell.checkboxButton addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
		[cell.contentView addSubview:cell.checkboxButton];
		
		// for background color
		cell.textField.opaque = FALSE;
		cell.textLabel.opaque = FALSE;
		cell.detailTextLabel.opaque = FALSE;
		cell.accessoryView.opaque = FALSE;
	}
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
	[self addGestureRecognizer:cell];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configureCell:(TextFieldCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_VERBOSE, @"--- %s %@", __FUNCTION__, indexPath);	
    ListItem *object = [fetchedResultsController objectAtIndexPath:indexPath];
    [self refreshCell:cell fromObject:object];
}

- (void)addGestureRecognizer:(UIView *)view {
	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
	recognizer.delegate = self;
	[view addGestureRecognizer:recognizer];
	[recognizer release];	
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	BOOL OK = YES;
	// moving only works in landscape when rootView is in edit mode.
	if (!UIDeviceOrientationIsLandscape(listViewController.detailViewController.orientation)) {
		OK = NO;
	}
	
	if (!listViewController.detailViewController.rootViewController.editing) {
		OK = NO;
	}
	
	if (self.tableView.editing) {
		OK = NO;
	}
	
	DebugLog(D_TRACE, @"%s %@", __FUNCTION__, YESNO(OK));
	return OK;
}

- (void)panHandler:(UIPanGestureRecognizer *)recognizer {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);

	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
			DebugLog(D_VERBOSE, @"--- begin");			
			if (dragImage != nil) {
				[dragImage release];
			}
			
			[self createDragImage:recognizer];
			break;

		case UIGestureRecognizerStateChanged:
			dragImage.center = [recognizer locationInView:[[UIApplication sharedApplication] keyWindow]];
			lastLocation = [recognizer locationInView:listViewController.detailViewController.rootViewController.tableView];
			DebugLog(D_VERBOSE, @"--- change location: %f, %f", dragImage.center.x, dragImage.center.y);
			break;

		case UIGestureRecognizerStateEnded:
			DebugLog(D_VERBOSE, @"--- end");
			[dragImage removeFromSuperview];
			dragImage = nil;
			
			//UITableViewCell *cell = (UITableViewCell *)recognizer.view;
			[self dropListItem:(UITableViewCell *)recognizer.view at:lastLocation];
			break;

		default:
			break;
	}
}

- (void)dropListItem:(UITableViewCell *)cell at:(CGPoint) location {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	DebugLog(D_VERBOSE, @"--- location: %f, %f", location.x, location.y);
	NSIndexPath *sourceIndexPath = [self.tableView indexPathForCell:cell];
	ListItem *movingListItem = [fetchedResultsController objectAtIndexPath:sourceIndexPath];
	DebugLog(D_VERBOSE, @"--- listItem: %@", movingListItem.title);
	NSIndexPath *targetIndexPath = [listViewController.detailViewController.rootViewController.tableView indexPathForRowAtPoint:location];
	if (targetIndexPath) {
		Item *item = [listViewController.detailViewController.rootViewController.fetchedResultsController objectAtIndexPath:targetIndexPath];
		DebugLog(D_VERBOSE, @"--- dropped on: %@", item.itemTitle);
		
		// update item and listItem
		Item *oldItem = movingListItem.item;
		movingListItem.item = item;
		[oldItem removeListItemsObject:movingListItem];
		[item addListItemsObject:movingListItem];
		
		[self saveObjectContext];

		// update badgeNumber
		[listViewController.detailViewController.rootViewController updateCurrentBadgeCount];				
		[listViewController.detailViewController.rootViewController updateBadgeCount:targetIndexPath];
	}
}

- (void)createDragImage:(UIPanGestureRecognizer *)recognizer {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	UIGraphicsBeginImageContext(recognizer.view.frame.size);
	[recognizer.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	[self drawBorder:UIGraphicsGetCurrentContext() size:recognizer.view.frame.size];
	UIImage* cellImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	dragImage = [[UIImageView alloc] initWithImage:cellImage];
	dragImage.alpha = 0.5;
	
	[self rotateDragImage];
	dragImage.center = [recognizer locationInView:[[UIApplication sharedApplication] keyWindow]];
	[[[UIApplication sharedApplication] keyWindow] addSubview:dragImage];
	
	[cellImage release];
}

- (void)drawBorder:(CGContextRef)context size:(CGSize)size {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, size.width, 0);
	CGContextAddLineToPoint(context, size.width, size.height);
	CGContextAddLineToPoint(context, 0, size.height);
	CGContextAddLineToPoint(context, 0, 0);
	
	CGContextDrawPath(context, kCGPathStroke);
	//CGContextStrokePath(context);
	
}

- (void)rotateDragImage {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	CGFloat angle;
	
	switch (listViewController.detailViewController.orientation) {
		case UIInterfaceOrientationPortraitUpsideDown:
			angle = 180;
			break;

		case UIInterfaceOrientationLandscapeLeft:
			angle = 270;
			break;

		case UIInterfaceOrientationLandscapeRight:
			angle = 90;
			break;

		default:
			angle = 0;
			break;
	}
	dragImage.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
}

#pragma mark -
#pragma mark Add a new object

- (NSNumber *)maxDisplayOrder {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	NSNumber *displayOrder = [NSNumber numberWithInt:99999];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ListItem" inManagedObjectContext:[self managedObjectContext]];
	[fetchRequest setEntity:entity];
	[fetchRequest setResultType:NSDictionaryResultType];
	
	NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"displayOrder"];
	NSExpression *maxDisplayOrderExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];	
	
	NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
	[expressionDescription setName:@"maxDisplayOrder"];
	[expressionDescription setExpression:maxDisplayOrderExpression];
	[expressionDescription setExpressionResultType:NSInteger32AttributeType];
	
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
	 
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(item == %@)", listViewController.detailViewController.item];
	[fetchRequest setPredicate:predicate];
	
	 // Execute the fetch.
	 NSError *error;
	 NSArray *objects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	 if (objects == nil) {
		 DebugLog(D_TRACE, @"!!! Error: fetching maxDisplayOrder");
		 // Handle the error.
	 }
	 else {
		 if ([objects count] > 0) {
			 int max = (int)[[[objects objectAtIndex:0] valueForKey:@"maxDisplayOrder"] intValue] + 1;
			 displayOrder = [NSNumber numberWithInt:max];
		 }
	 }
	 
	 [expressionDescription release];
	 [fetchRequest release];
	 
	 return displayOrder;
}

- (void)insertNewObject:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
	[listViewController.detailViewController reportFrames];
	
	if (dirty) {
		[self updateObject];
	}
	
    // Create a new instance of the entity managed by the fetched results controller.
    NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
    ListItem *newListItem = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:[self managedObjectContext]];
    
    // If appropriate, configure the new managed object.
    newListItem.title = @"";
	DebugLog(D_VERBOSE, @"--- lastSection: %@", self.lastSection);
    newListItem.topic = (self.lastSection != nil ? self.lastSection : @"");
	newListItem.dueDate = [NSDate date];
	newListItem.item = listViewController.detailViewController.item;
	newListItem.displayOrder = [self maxDisplayOrder];
	
	[listViewController.detailViewController.item addListItemsObject:newListItem];
	
	DebugLog(D_VERBOSE, @"--- adding listItem to %@  displayOrder: %d", listViewController.detailViewController.item.itemTitle, [newListItem.displayOrder intValue]);
    DebugLog(D_VERBOSE, @"--- editing: %@  focus: %@  inserting: %@  dirty: %@", YESNO(listViewController.editing), YESNO(changingFocus), YESNO(inserting), YESNO(dirty));
	
	if (inserting) {
		changingFocus = TRUE; // prevents keyboard scrolling while saving context
	}
	
    // Save the context.
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        DebugLog(D_ERROR, @"=== Unresolved error %@, %@", error, [error userInfo]);
        DebugBreak();
    }
    
	[self.tableView reloadData];

    NSIndexPath *indexPath = [fetchedResultsController indexPathForObject:newListItem];
	if (indexPath == nil) {
		DebugLog(D_ERROR, @"=== indexPath is nil");
		indexPath = [[NSIndexPath indexPathWithIndex:0] indexPathByAddingIndex:0];
	}
	
	//refresh RootViewController badge
	[listViewController.detailViewController.rootViewController updateCurrentBadgeCount];

	// Enter edit mode
	inserting = TRUE;
	DebugLog(D_TRACE, @"--- insertionPath: %@", indexPath);
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES]; 
	[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

	DebugLog(D_VERBOSE, @"--- after insertNewObject");		
	[listViewController.detailViewController reportFrames];
	
	[self editSelectedText:indexPath];
}

#pragma mark -
#pragma mark Fetched results controller delegate
- (void)showPersistentStore {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
	NSPersistentStoreCoordinator *storeCoordinator = [[self managedObjectContext] persistentStoreCoordinator];
	NSArray *stores = [storeCoordinator persistentStores];
	
	for (int i=0; i < [stores count]; i++) {
		DebugLog(D_TRACE, @"Store: %@", [[stores objectAtIndex:i] URL]);
		NSDictionary *dictionary = [[stores objectAtIndex:i] metadata];

		for (id key in dictionary) {
			DebugLog(D_TRACE, @"Key: %@, Value: %@", key, [dictionary objectForKey:key]);
		}
	}
}

- (NSManagedObjectContext *)managedObjectContext {
	return listViewController.detailViewController.rootViewController.managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
	
	return [self fetchedResultsControllerInit];
}

- (NSFetchedResultsController *)fetchedResultsControllerInit {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);    
	[listViewController updateTitle];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setFetchBatchSize:20];

	[self setEntity:fetchRequest];
	[self setPredicate:fetchRequest];
	[self setSortDescriptors:fetchRequest];
    NSFetchedResultsController *aFetchedResultsController = [self createFetchedResultsController:fetchRequest]; 
	
    aFetchedResultsController.delegate = self;
	if (fetchedResultsController != nil) {
		[fetchedResultsController release];
	}
    fetchedResultsController = [aFetchedResultsController retain];
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [self performFetch];
    
	DebugLog(D_VERBOSE, @"--- Count: %d", [fetchedResultsController.fetchedObjects count]);
	
	return fetchedResultsController;
}

- (void)setEntity:(NSFetchRequest *)fetchRequest {
    // Edit the entity name as appropriate.
	listItem = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ListItem" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];    
}

- (void)setPredicate:(NSFetchRequest *)fetchRequest {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
	// Set predicate -- all listItems with listItem.item==item	
	// Hide completed tasks -- @"(item == %@) AND (complete == NO)"
	DetailViewController *detailViewController = listViewController.detailViewController; 
	UISearchBar *theSearchBar = detailViewController.rootViewController.theSearchBar;
	NSPredicate *predicate;
	
	if (detailViewController.item != nil) {
		predicate = [NSPredicate predicateWithFormat: @"(item == %@)", detailViewController.item];

		if ([theSearchBar.text length] > 0 && theSearchBar.selectedScopeButtonIndex == 2) {
			NSPredicate *searchMatch = [NSPredicate predicateWithFormat:@"(title CONTAINS[c] %@)", theSearchBar.text];
			predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, searchMatch, nil]];
		}
		
		if (detailViewController.item.showCompleted != nil) {
			if (![detailViewController.item.showCompleted boolValue]) {
				NSPredicate *hideCompleted = [NSPredicate predicateWithFormat:@"(complete == NO)"];
				predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, hideCompleted, nil]];
			}
		}
	}
	else {
		predicate = [NSPredicate predicateWithFormat: @"FALSEPREDICATE"];
	}
	
	[fetchRequest setPredicate:predicate];
}

- (void)setSortDescriptors:(NSFetchRequest *)fetchRequest {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);    
	
	DetailViewController *detailViewController = listViewController.detailViewController;
	Item *item = detailViewController.item;
	NSString *sortField;
	BOOL ascending = TRUE;

	if (item.sortField == nil || ([listViewController.sortFields indexOfObject:item.sortField] == NSNotFound)) {
		sortField = [listViewController.sortFields objectAtIndex:0];
	}
	else {
		sortField = item.sortField;
		ascending = [item.sortAscending boolValue];
	}
		
	NSSortDescriptor *sectionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"topic"
																	  ascending:TRUE];
    NSSortDescriptor *OrderDescriptor = [[NSSortDescriptor alloc] initWithKey:sortField ascending:ascending];
	
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sectionDescriptor, OrderDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	[OrderDescriptor release];
	[sectionDescriptor release];
	[sortDescriptors release];
	DebugLog(D_VERBOSE, @"--- predicate: item=%@  showCompleted:%@", item.itemTitle, 
			 YESNO([item.showCompleted boolValue]));
}

- (NSFetchedResultsController *)createFetchedResultsController:(NSFetchRequest *)fetchRequest {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);    
	
	// cacheName nil to prevent caching
	return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
											   managedObjectContext:[self managedObjectContext] 
												 sectionNameKeyPath:@"topic" cacheName:nil];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	if (!self.moving) {
		[self.tableView beginUpdates];
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	DebugLog(D_VERBOSE, @"--- path:%@ - %@  type:%d", indexPath, newIndexPath, type);
    
	if (!self.moving) {
		UITableView *tableView = self.tableView;
		
		switch(type) {
				
			case NSFetchedResultsChangeInsert:
				[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeDelete:
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeMove:
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
				break;

			case NSFetchedResultsChangeUpdate:
				//[tableView cellForRowAtIndexPath:indexPath];
				break;
				
		}
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	if (!self.moving) {
		[self.tableView endUpdates];
	}
}

#pragma mark -
#pragma mark TableViewController delegate

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		ListItem *listItemToDelete = [fetchedResultsController objectAtIndexPath:indexPath];
		[[self managedObjectContext] deleteObject:listItemToDelete];
		selectedCell = nil;
		
		[self saveObjectContext];
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	self.moving = TRUE;

	ListItem *fromObject = [fetchedResultsController objectAtIndexPath:fromIndexPath];
	ListItem *toObject = [fetchedResultsController objectAtIndexPath:toIndexPath];
	
	// change fromObject section heading
	if (fromIndexPath.section != toIndexPath.section) {
		fromObject.topic = toObject.topic;
	}	

	NSMutableArray *array = [[self.fetchedResultsController fetchedObjects] mutableCopy];
	NSUInteger fromIndex = [array indexOfObject:fromObject];
	NSUInteger toIndex = [array indexOfObject:toObject];
	if (fromIndex < toIndex) {
		toIndex--;  //removing fromObject will change the index of toObject
	}
	[array removeObject:fromObject];
	[array insertObject:fromObject atIndex:toIndex];

	for (int i=0; i<[array count]; i++)
	{
		[(NSManagedObject *)[array objectAtIndex:i] setValue:[NSNumber numberWithInt:i] forKey:@"displayOrder"];
	}
	[array release];
	
	[self performFetch];
	[self saveObjectContext];
	
	self.moving = FALSE;	
}

- (void)showData {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	// Display Model Data
	NSMutableArray *array = [[self.fetchedResultsController fetchedObjects] mutableCopy];
	for (int i = 0; i < [array count]; i++) {
		ListItem *object = (ListItem *)[array objectAtIndex:i];
		DebugLog(D_TRACE, @" %d - %d : %@", i, [object.displayOrder intValue], object.title);
	}
	[array release];
	
	// Diplay Table View Data
	NSInteger sections = [self numberOfSectionsInTableView:self.tableView];
	for (NSInteger section = 0; section < sections; section++) {
		for (NSInteger row = 0; row < [self tableView:self.tableView numberOfRowsInSection:section]; row++) {
			TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
			DebugLog(D_TRACE, @"[%d, %d] : %@", section, row, cell.textLabel.text);
		}
	}		
}

- (void)performFetch {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        DebugLog(D_TRACE, @"Unresolved error %@, %@", error, [error userInfo]);
        DebugBreak();
    }
}

- (void)saveObjectContext {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
	NSError *error = nil;
	if (![[self managedObjectContext] save:&error]) {
		DebugLog(D_TRACE, @"Unresolved error %@, %@", error, [error userInfo]);
		DebugBreak();
	}
	
	//refresh RootViewController badge
	[[listViewController.detailViewController currentCell] setNeedsLayout];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	DetailViewController *detailViewController = listViewController.detailViewController;
	BOOL canMove = YES;
	Item *item = detailViewController.item;
	if (item.sortField != nil) {
		DebugLog(D_FINER, @"sortField: %@", item.sortField);
		canMove = [item.sortField isEqual:@"displayOrder"];
	}
    return canMove;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	if (listViewController.editing) {
		changingFocus = TRUE;  //prevent view from scrolling up and down due to changing first responder
	}
	inserting = FALSE;
	DebugLog(D_VERBOSE, @"--- didSelectRowAtIndexPath");		
	[listViewController.detailViewController reportFrames];

	[self editSelectedText:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	DebugLog(D_VERBOSE, @"%s section: %d", __FUNCTION__, section);
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	NSString *sectionTitle = [sectionInfo name];
	DebugLog(D_VERBOSE, @"  Section Title: %@", sectionTitle);
	
	return sectionTitle;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_VERBOSE, @"%s", __FUNCTION__);
	if (![listViewController isKindOfClass:[ChecklistViewController class]]) {
		return;
	}

	ListItem *theListItem = (ListItem *)[fetchedResultsController objectAtIndexPath:indexPath];
	[self updateColor:cell fromObject:theListItem];	
}

- (void)updateColor:(UITableViewCell *)cell fromObject:(ListItem *)object {
	UIColor *color;
	switch ([object.priority intValue]) {
		case 0:
			color = [UIColor whiteColor];
			break;
		case 1: // red
			color= [UIColor colorWithRed:1 green:.5 blue:.5 alpha:.5];
			break;
		case 2: // orange
			color = [UIColor colorWithRed:1 green:.75 blue:.5 alpha:.5];
			break;
		case 3:  // yellow
			color= [UIColor colorWithRed:1 green:1 blue:.5 alpha:.5];
			break;
		case 4: // blue
			color = [UIColor colorWithRed:.5 green:.5 blue:1 alpha:.5];
			break;
		default:
			color = [UIColor whiteColor];
			break;
	}
	TextFieldCell *textFieldCell = (TextFieldCell *)cell;
	
	DebugLog(D_VERBOSE, @"object: %@  priority: %d  color: %@", object.title, [object.priority intValue], color);
	
	textFieldCell.backgroundColor = color;
	textFieldCell.contentView.backgroundColor = color;
	textFieldCell.textField.backgroundColor = color;
	textFieldCell.textLabel.opaque = FALSE;
	textFieldCell.textLabel.backgroundColor	= [UIColor clearColor];
	textFieldCell.detailTextLabel.opaque = FALSE;
	textFieldCell.detailTextLabel.backgroundColor = [UIColor clearColor];
	textFieldCell.accessoryView.backgroundColor = color;
	textFieldCell.checkboxButton.opaque = FALSE;
	textFieldCell.checkboxButton.backgroundColor = [UIColor clearColor];
}

#pragma mark -
#pragma mark textField Handling
- (void)editSelectedText:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[self selectCell:indexPath];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	TextFieldCell *cell = (TextFieldCell*)selectedCell;
	cell.textField.text = cell.textLabel.text;
	cell.textField.font = cell.textLabel.font;
	cell.textField.textColor = [UIColor blackColor];
	cell.textField.hidden = FALSE;
	cell.textLabel.hidden = TRUE;
	cell.textField.backgroundColor = [UIColor whiteColor];
	
	if ([cell.textField.text length] == 0) {
		cell.textField.placeholder = @"Title";
	}
	
	cell.textField.userInteractionEnabled = YES;
	[cell.textField becomeFirstResponder];
	listViewController.editing = TRUE;
	dirty = TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
		
	if (inserting) {
		changingFocus = TRUE;
		DebugLog(D_VERBOSE, @"--- textFieldShouldReturn");		
		[listViewController.detailViewController reportFrames];
		
		[self updateObject];
		// add a new row when Return key is pressed
		if (inserting) {	// will be set to FALSE if blank row was deleted			
			[self insertNewObject:self]; 
		}
	}
	else {
		listViewController.editing = FALSE;
		changingFocus = FALSE;
		DebugLog(D_VERBOSE, @"--- textFieldShouldReturn");		
		[listViewController.detailViewController reportFrames];
		[textField resignFirstResponder];	// triggers updateObject
	}
	
	return NO;
}

// Updates listItem title and refreshes cell
- (void)updateObject {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[listViewController.detailViewController reportFrames];

	if (!dirty) {
		return;
	}
	
	dirty = FALSE;
	
	if (selectedCell == nil) {
		DebugLog(D_TRACE, @"!!! SelectedCell is nil");
		return;
	}

	TextFieldCell *cell = (TextFieldCell*)selectedCell;
	
	if (listItem != nil) {
		listItem.title = cell.textField.text;
		
		if ([listItem.title length] == 0) {
			inserting = FALSE;
			changingFocus = FALSE;
			listViewController.editing = FALSE;

			// Delete empty item
			[[self managedObjectContext] deleteObject:listItem];
			selectedCell = nil;

			DebugLog(D_VERBOSE, @"--- deleting object");
			[listViewController.detailViewController.rootViewController updateCurrentBadgeCount];
			cell.textLabel.hidden = FALSE;
			cell.textField.hidden = TRUE;
			[listViewController.detailViewController reportFrames];
		}
		else {
			cell.textLabel.text = cell.textField.text;
			cell.textLabel.hidden = FALSE;
			cell.textField.hidden = TRUE;

			[self saveSelectedListItem];
		}
	}
	else {
		DebugLog(D_ERROR, @"==== listItem is nil");
	}
}

#pragma mark -
#pragma mark Checkbox Support
- (void) checkboxClick:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	dirty = TRUE;
	
	TextFieldCell *cell = (TextFieldCell*)[[sender superview] superview];
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	
	changingFocus = TRUE;
    DebugLog(D_VERBOSE, @"--- editing: %@  focus: %@  inserting: %@  dirty: %@", YESNO(listViewController.editing), YESNO(changingFocus), YESNO(inserting), YESNO(dirty));
	[self selectCell:indexPath];
	listItem.complete = [NSNumber numberWithBool:![listItem.complete boolValue]];
	
	if ([listItem.complete boolValue]) {
		[cell.checkboxButton setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
		[cell.checkboxButton setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateHighlighted];
	}
	else {
		[cell.checkboxButton setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
		[cell.checkboxButton setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateHighlighted];
	}
	[self saveSelectedListItem];
}

#pragma mark -
#pragma mark ListItemView Support
- (void)selectCell:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	if (listViewController.keyboardUp) {
		changingFocus = TRUE;
	}
	[listViewController.detailViewController reportFrames];
	
	if (dirty) {
		[self updateObject];
	}
    // Set listItem to current cell.
	selectedCell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    self.listItem = (ListItem *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	self.lastSection = listItem.topic;
	DebugLog(D_FINER, @"--- lastSection: %@  title: %@", lastSection, listItem.title);
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[self selectCell:indexPath];
	[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
	DebugLog(D_TRACE, @"--- scrollPosition");

	// Disable toolbar
	[listViewController.detailViewController toolbarEnabled:NO];
	
	self.listItemView = [[ListItemViewController alloc] initWithNibName:@"ListItemView" bundle:nil];
	listItemView.tableViewController = self;
	listItemView.view.backgroundColor = [UIColor clearColor];
	listItemView.view.opaque = FALSE;
	
	UIView *topView = [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0];	
	[topView addSubview:listItemView.view];
	
	[UIView beginAnimations:nil context:nil];   
	[UIView setAnimationDuration:0.7]; // animation duration in seconds   
	listItemView.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
	[UIView commitAnimations];	
}

- (void) saveSelectedListItem {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	DebugLog(D_VERBOSE, @"--- %@", listItem);
	
	if (listItem != nil) {
		[self saveObjectContext];
	}
	else {
		DebugLog(D_ERROR, @"*** listItem is nil");
		DebugBreak();
	}
	
	// refresh cell
	TextFieldCell *cell = (TextFieldCell*)selectedCell;
	[self refreshCell:cell fromObject:listItem];
	[self updateColor:cell fromObject:listItem];	
	[selectedCell setNeedsLayout];
}

- (void)deselectCell {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    NSIndexPath *currentSelection = [self.tableView indexPathForSelectedRow];
    if (currentSelection != nil) {		
        [self.tableView deselectRowAtIndexPath:currentSelection animated:NO];
    }	
}

- (void)refreshCell:(TextFieldCell *)cell fromObject:(ListItem *)object {
	DebugLog(D_VERBOSE, @"%s", __FUNCTION__);
    DebugLog(D_VERBOSE, @"--- SelectedRow: %d", [self.tableView indexPathForSelectedRow].row);
    DebugLog(D_VERBOSE, @"--- SelectedCell Row: %d", [self.tableView indexPathForCell:cell].row);
	DebugLog(D_VERBOSE, @"--- cell.textLabel: %@  date: %@", cell.textLabel.text, cell.detailTextLabel.text);	
	DebugLog(D_VERBOSE, @"--- object.title: %@  date: %@", object.title, object.dueDate);
	DebugLog(D_VERBOSE, @"--- %@", object);
	
    cell.textLabel.text = object.title;
	cell.detailTextLabel.text = [Utility formatDate:object.dueDate];	
	cell.detailTextLabel.textColor = [Utility colorForDueDate:object.dueDate];
	cell.textField.text = object.title;
	
	if ([object.complete boolValue]) {
		[cell.checkboxButton setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
		[cell.checkboxButton setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateHighlighted];
	}
	else {
		[cell.checkboxButton setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
		[cell.checkboxButton setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateHighlighted];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    [super dealloc];
	
	[listItem release];
	[fetchedResultsController release];
	[listViewController release];
	[selectedCell release];
	[listItemView release];
	[lastSection release];
	[dragImage release];
}
@end

