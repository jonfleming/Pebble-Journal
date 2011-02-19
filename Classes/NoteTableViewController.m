//
//  NoteTableViewController.m
//  Pebble
//
//  Created by techion on 7/28/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "NoteTableViewController.h"
#import "RootViewController.h"
#import "TableViewController.h"
#import "ListViewController.h"
#import "DetailViewController.h"
#import "NotepadViewController.h"
#import "NotelistViewController.h"
#import "Item.h"
#import "NoteItem.h"
#import "NotelistCell.h"
#import "Utility.h"
#import "constants.h"

@implementation NoteTableViewController

@synthesize noteItem, selectedRow;

#pragma mark -
#pragma mark Note Support
- (void)setSelectedCell:(NotelistCell *)cell {
	DebugLog(D_TRACE, @"%s %@", __FUNCTION__, cell);
	[selectedCell release];
	selectedCell = [cell retain];
}

- (void)selectCell:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s path: %@", __FUNCTION__, indexPath);
	selectedRow = indexPath.row;
	// Note: can't call setSelectedCell from here because cellForRowAtIndexPath calls configureCell and causes an endless loop
	
    // Set noteItem to current cell and intialize NotepadView	
	NSUInteger row = indexPath.row;
	NSInteger rows = [self tableView:self.tableView numberOfRowsInSection:0];
	if (rows == 0 || row +1 > rows) {
		DebugLog(D_TRACE, @"!!! Error: attempt to select non-existant row: %d", indexPath.row);
		return;
	}
	
	noteItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
	DebugLog(D_FINER, @"item: %@", listViewController.detailViewController.item.itemTitle);
	
	listViewController.detailViewController.item.lastNoteItemRow = [NSNumber numberWithInt:row];
	[self updateNotepadView];
	[listViewController.detailViewController.viewStatusArray replaceObjectAtIndex:NOTEPAD withObject:[NSNumber numberWithBool:YES]];
	[listViewController.detailViewController.tabBarController setSelectedViewController:listViewController.detailViewController.notepadViewController];
	//[self report];
}

- (void)updateNotepadView {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	// Initialize notepadView
	NotepadViewController *notepadViewController = listViewController.detailViewController.notepadViewController;
	if (![notepadViewController isViewLoaded]) {
		notepadViewController.view = notepadViewController.view; // forces loadView
	}
	
	notepadViewController.notepadView.text = noteItem.note;
	notepadViewController.notepadView.editable = TRUE;
	notepadViewController.dirty = FALSE;
	notepadViewController.dateLabel.text = [Utility 
											formatDate:([listViewController.detailViewController.item.sortField isEqualToString:@"modifiedDate"] ?
														 noteItem.modifiedDate : noteItem.creationDate)];
	if ([notepadViewController.notepadView.text length] == 0) {
		DebugLog(D_FINE, @"=== notepadView.txt is empty  %@    %@", noteItem.title, noteItem.summary);
	}
	else {
		DebugLog(D_FINE, @"--- %@    %@", noteItem.title, noteItem.summary);
	}	
}

#pragma mark -
#pragma mark Table view delegate
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s path: %@", __FUNCTION__, indexPath);

	listViewController.detailViewController.item.lastNoteItemRow = nil;
	[self editNote:indexPath];
}

- (void)editNote:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	// there are times when we want to select a cell without changing self.selectedCell
	[self setSelectedCell:(NotelistCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath]];
	[self selectCell:indexPath];
	
	// switch to NotepadView
	[listViewController.detailViewController showView:NOTEPAD];
}

- (NSIndexPath *)selectedPath {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	//return 	[self.tableView indexPathForSelectedRow];
	return [NSIndexPath indexPathForRow:selectedRow inSection:0];
}

- (void)report {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[super report];

	DebugLog(D_VERBOSE, @"   setting detailViewController");
	DetailViewController *detailViewController = listViewController.detailViewController;
	
	if (detailViewController.item == nil) {
		DebugLog(D_ERROR, @"   detailViewController is nil.  Exiting report.");
		return;
	}
		
	DebugLog(D_VERBOSE, @"setting notepadViewController");
	NotepadViewController *notepadViewController = detailViewController.notepadViewController;

	DebugLog(D_VERBOSE, @"checking notepadViewController");
	if (notepadViewController == nil) {
		DebugLog(D_ERROR, @"   notepadViewController is nil.  Exiting report.");
		return;
	}
	
	DebugLog(D_VERBOSE, @"checking notepadView.text");
	if (notepadViewController.notepadView.text == nil) {
		DebugLog(D_ERROR, @"   text is nil.  Exiting report.");
		return;
	}
	else {
		DebugLog(D_VERBOSE, @"   notepadView:%@", notepadViewController.notepadView.text);
	}
	
	DebugLog(D_VERBOSE, @"checking noteItem");
	if (noteItem == nil) {
		DebugLog(D_ERROR, @"   noteItem is nil.  Exiting report.");
		return;
	}
	
	if (detailViewController.item.lastNoteItemRow != nil) {
		DebugLog(D_VERBOSE, @"   lastNoteItemRow: %d", [detailViewController.item.lastNoteItemRow intValue]);
	}

	DebugLog(D_VERBOSE, @"checking noteItem.title");
	if (noteItem.title == nil) {
		DebugLog(D_ERROR, @"   title is nil.  Exiting report.");
		return;
	}
	else {
		DebugLog(D_VERBOSE, @"   title: %@", noteItem.title);
		DebugLog(D_VERBOSE, @"   summary: %@", noteItem.summary);
	}
	
	DebugLog(D_VERBOSE, @"   note:\n%@", noteItem.note);
	

	NotelistCell *cell = (NotelistCell *)selectedCell;
	if (cell == nil) {
		DebugLog(D_ERROR, @"   selectedCell is nil.  Exiting report.");
		return;
	}
	
}

- (void)updateObject {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[self report];
	
	NotelistCell *cell = (NotelistCell *)selectedCell;
	if (cell == nil) {
		DebugLog(D_VERBOSE, @"   selectedCell is nil. Exiting updateObject.");
		return;
	}

	DetailViewController *detailViewController = listViewController.detailViewController;
	if (detailViewController == nil) {
		DebugLog(D_VERBOSE, @"   detailViewController is nil. Exiting updateObject.");
		return;
	}
	
	NotepadViewController *notepadViewController = detailViewController.notepadViewController;
	if (notepadViewController == nil) {
		DebugLog(D_VERBOSE, @"   notepadViewController is nil. Exiting updateObject.");
		return;
	}
	
	if (notepadViewController.notepadView == nil) {
		DebugLog(D_VERBOSE, @"   notepadView is nil. Exiting updateObject.");
		return;
	}
	
	noteItem.modifiedDate =[NSDate date];
	noteItem.note = notepadViewController.notepadView.text;
	DebugLog(D_VERBOSE, @"noteItem: %@ \ncell: %@", noteItem, cell.title.text);
	NSArray *array = [[noteItem.note substringToIndex:MIN(200,[noteItem.note length])] componentsSeparatedByString:@"\n"];
	NSString *title = [array objectAtIndex:0];
	noteItem.title = title;
	cell.title.text = title;
	
	if ([array count] > 1) {
		NSRange range;
		range.location = 1;
		range.length = [array count] - 1;
		NSString *summary = [[array subarrayWithRange:range] componentsJoinedByString:@" "]; 
		noteItem.summary = summary;
		cell.summary.text = summary;
	}
	
	DebugLog(D_VERBOSE, @"=== %@    %@", noteItem.title, noteItem.summary);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_VERBOSE, @"%s %@", __FUNCTION__, indexPath);    
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell%@",listViewController.titleLabel.text];
    
    NotelistCell *cell = (NotelistCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[NotelistCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
	
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.contentMode = UIViewContentModeLeft;
		cell.shouldIndentWhileEditing = FALSE;
		
		cell.title = [[UILabel alloc] initWithFrame:CGRectZero];
		[cell.contentView addSubview:cell.title];
		
		cell.summary = [[UILabel alloc] initWithFrame:CGRectZero];
		[cell.contentView addSubview:cell.summary];
	}
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
	[self addGestureRecognizer:cell];

    return cell;
}

- (void)configureCell:(NotelistCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	DebugLog(D_VERBOSE, @"%s %@", __FUNCTION__, indexPath);
    
    NoteItem *row = [fetchedResultsController objectAtIndexPath:indexPath];
	if (row == nil) {
		DebugLog(D_ERROR, @"=== Error: row is nil");
		DebugBreak();
	}
	DebugLog(D_FINE, @"--- row: %d  title: %@", indexPath.row, row.title);

    cell.textLabel.text = [Utility formatDate:([listViewController.detailViewController.item.sortField isEqualToString:@"modifiedDate"] ?
		row.modifiedDate : row.creationDate)];
	cell.title.text = (row.title == nil || [row.title length] == 0) ? @"" : row.title;
	cell.summary.text = row.summary;
	
	// don't move to lastNoteItemRow while searching
	UISearchBar *theSearchBar = listViewController.detailViewController.rootViewController.theSearchBar;
	if ([theSearchBar.text length] > 0 && theSearchBar.selectedScopeButtonIndex == 2) {	
		return;
	}
		
	if ([listViewController.detailViewController.item.itemType intValue] == NOTEPAD) {
		if (listViewController.detailViewController.item.lastNoteItemRow != nil) {
			if (indexPath.row == [listViewController.detailViewController.item.lastNoteItemRow intValue]) {
				[self selectCell:indexPath];
				[self setSelectedCell:cell];
			}
		}
	}
}

- (void)addGestureRecognizer:(UIView *)view {
	DebugLog(D_INFO, @"%s", __FUNCTION__);
	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
	recognizer.delegate = self;
	[view addGestureRecognizer:recognizer];
	[recognizer release];	
}

- (void)panHandler:(UIPanGestureRecognizer *)recognizer {
	DebugLog(D_INFO, @"%s", __FUNCTION__);

	CGPoint point;
	CGPoint temp;

	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
			DebugLog(D_INFO, @"--- begin");			
			if (dragImage != nil) {
				[dragImage release];
			}
			
			[self createDragImage:recognizer];
			break;
			
		case UIGestureRecognizerStateChanged:
			point = [recognizer locationInView:nil]; //[recognizer locationInView:[[UIApplication sharedApplication] keyWindow]];
			temp = CGPointApplyAffineTransform(point, dragImage.transform);
			
			dragImage.center = point;
			lastLocation = [recognizer locationInView:listViewController.detailViewController.rootViewController.tableView];
			DebugLog(D_INFO, @"--- image: %f, %f  point: %f, %f  temp: %f, %f", dragImage.center.x, dragImage.center.y, point.x, point.y, temp.x, temp.y);
			break;
			
		case UIGestureRecognizerStateEnded:
			DebugLog(D_INFO, @"--- end");
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
	NoteItem *movingListItem = [fetchedResultsController objectAtIndexPath:sourceIndexPath];
	DebugLog(D_VERBOSE, @"--- listItem: %@", movingListItem.title);
	NSIndexPath *targetIndexPath = [listViewController.detailViewController.rootViewController.tableView indexPathForRowAtPoint:location];
	if (targetIndexPath) {
		Item *item = [listViewController.detailViewController.rootViewController.fetchedResultsController objectAtIndexPath:targetIndexPath];
		DebugLog(D_VERBOSE, @"--- dropped on: %@", item.itemTitle);
		
		// update item and listItem
		Item *oldItem = movingListItem.item;
		movingListItem.item = item;
		[oldItem removeNoteItemsObject:movingListItem];
		[item addNoteItemsObject:movingListItem];
		
		[self saveObjectContext];
		
		// update badgeNumber
		[listViewController.detailViewController.rootViewController updateCurrentBadgeCount];				
		[listViewController.detailViewController.rootViewController updateBadgeCount:targetIndexPath];		
	}
}

#pragma mark -
#pragma mark Add a new object
- (void)insertNewObject:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	
	[listViewController.detailViewController saveNote];

    NSIndexPath *currentSelection = [self.tableView indexPathForSelectedRow];
    if (currentSelection != nil) {
        [self.tableView deselectRowAtIndexPath:currentSelection animated:NO];
    }    
    
    // Create a new instance of the entity managed by the fetched results controller.
    NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
    NoteItem *newNoteItem = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:[self managedObjectContext]];
    
    // If appropriate, configure the new managed object.
    newNoteItem.summary = @"";
    newNoteItem.title = @"";
	newNoteItem.creationDate = [NSDate date];
	newNoteItem.modifiedDate = [NSDate date];
	newNoteItem.item = listViewController.detailViewController.item;
	
	[listViewController.detailViewController.item addNoteItemsObject:newNoteItem];
	
	//DebugLog(D_VERBOSE, @"--- add listItem to: item=%@", listViewController.detailViewController.item.itemTitle);
    
    // Save the context.
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        DebugLog(D_TRACE, @"Unresolved error %@, %@", error, [error userInfo]);
        DebugBreak();
    }
    
	//refresh RootViewController badge
	[listViewController.detailViewController.rootViewController updateCurrentBadgeCount];

    NSIndexPath *insertionPath = [fetchedResultsController indexPathForObject:newNoteItem];
	if (insertionPath == nil) {
		insertionPath = [[NSIndexPath indexPathWithIndex:0] indexPathByAddingIndex:0];
	}
    [self.tableView selectRowAtIndexPath:insertionPath animated:YES scrollPosition:UITableViewScrollPositionTop];
	[self.tableView reloadData];
	
	// Edit new note
	noteItem = newNoteItem;
	listViewController.detailViewController.item.lastNoteItemRow = [NSNumber numberWithInt:insertionPath.row];

	[self editNote:insertionPath];
}

#pragma mark -
#pragma mark Fetched results controller delegate
- (void)setEntity:(NSFetchRequest *)fetchRequest {
	noteItem = nil;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteItem" inManagedObjectContext:[self managedObjectContext]];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
}
- (void)setPredicate:(NSFetchRequest *)fetchRequest {
	// Set predicate -- all listItems with listItem.item==item	
	DetailViewController *detailViewController = listViewController.detailViewController; 
	UISearchBar *theSearchBar = detailViewController.rootViewController.theSearchBar;
	NSPredicate *predicate;

	if (detailViewController.item != nil) {
		predicate = [NSPredicate predicateWithFormat: @"(item == %@)", detailViewController.item];

		if ([theSearchBar.text length] > 0 && theSearchBar.selectedScopeButtonIndex == 2) {
			NSPredicate *searchMatch = [NSPredicate predicateWithFormat:@"(note CONTAINS[c] %@)", theSearchBar.text];
			predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, searchMatch, nil]];
			
			DebugLog(D_FINER, @"--- filtered on %@", theSearchBar.text);
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
	BOOL ascending = FALSE;
	
	if (item.sortField == nil || ([listViewController.sortFields indexOfObject:item.sortField] == NSNotFound)) {
		sortField = [listViewController.sortFields objectAtIndex:0];
	}
	else {
		sortField = item.sortField;
		ascending = [item.sortAscending boolValue];
	}
		
	NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:sortField 
																   ascending:ascending];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:dateDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	[dateDescriptor release];
	[sortDescriptors release];
	DebugLog(D_FINER, @"--- NoteTable predicate: %@  sortField: %@", item.itemTitle, item.sortField);
}

- (NSFetchedResultsController *)createFetchedResultsController:(NSFetchRequest *)fetchRequest {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);    

	// cacheName nil to prevent caching
	return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
											   managedObjectContext:[self managedObjectContext] 
												 sectionNameKeyPath:nil cacheName:nil];
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
	[noteItem release];
}


@end