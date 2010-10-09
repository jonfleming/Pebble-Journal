//
//  TableViewController.h
//  Pebble
//
//  Created by techion on 6/24/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ListItem.h"

@class ListViewController;
@class ListItemViewController;
@class TextFieldCell;

@interface TableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UITableViewDelegate> {
		
	ListItem *listItem;
	NSFetchedResultsController *fetchedResultsController;
	ListViewController *listViewController;
	UITableViewCell *selectedCell;
	ListItemViewController *listItemView;
	BOOL moving;
	BOOL changingFocus;
	BOOL inserting;
	BOOL dirty;
	NSString *lastSection;
	UIImageView *dragImage;
	CGPoint lastLocation;
}

@property (nonatomic, retain) ListItem *listItem;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) ListViewController *listViewController;
@property (nonatomic, copy) UITableViewCell *selectedCell;
@property (nonatomic, retain) ListItemViewController *listItemView;
@property (nonatomic, assign) BOOL moving;
@property (nonatomic, assign) BOOL changingFocus;
@property (nonatomic, assign) BOOL inserting;
@property (nonatomic, assign) BOOL dirty;
@property (nonatomic, copy) NSString *lastSection;
@property (nonatomic, retain) UIImageView *dragImage;
@property (nonatomic, assign) CGPoint lastLocation;

- (NSFetchedResultsController *)fetchedResultsControllerInit;
- (void)setEntity:(NSFetchRequest *)fetchRequest;
- (void)setPredicate:(NSFetchRequest *)fetchRequest;
- (void)setSortDescriptors:(NSFetchRequest *)fetchRequest;
- (NSFetchedResultsController *)createFetchedResultsController:(NSFetchRequest *)fetchRequest;
- (NSManagedObjectContext *)managedObjectContext;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)addGestureRecognizer:(UIView *)view;
- (void)createDragImage:(UIPanGestureRecognizer *)recognizer;
- (void)drawBorder:(CGContextRef)context size:(CGSize)size;
- (void)panHandler:(UIPanGestureRecognizer *)recognizer;
- (void)rotateDragImage;
- (void)dropListItem:(UITableViewCell *)cell at:(CGPoint)location;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (void)checkboxClick:(id)sender;
- (NSNumber *)maxDisplayOrder;
- (void)insertNewObject:(id)sender;
- (void)editSelectedText:(NSIndexPath *)indexPath;
- (void)updateColor:(UITableViewCell *)cell fromObject:(ListItem *)object;
- (void)updateObject;
- (void)deselectCell;
- (void)saveSelectedListItem;
- (void)selectCell:(NSIndexPath *)indexPath;
- (void)refreshCell:(TextFieldCell *)cell fromObject:(ListItem *)object;
- (void)showData;
- (void)performFetch;
- (void)saveObjectContext;
- (void)report;

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
@end
