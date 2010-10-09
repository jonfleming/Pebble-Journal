//
//  NoteTableViewController.h
//  Pebble
//
//  Created by techion on 7/28/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"

@class NoteItem;
@class NotelistCell;

@interface NoteTableViewController : TableViewController {
	NoteItem *noteItem;
}

@property (nonatomic, retain) NoteItem *noteItem;


//- (NSFetchedResultsController *)fetchedResultsControllerInit;  // implemented in base class
- (void)setEntity:(NSFetchRequest *)fetchRequest;
- (void)setPredicate:(NSFetchRequest *)fetchRequest;
- (void)setSortDescriptors:(NSFetchRequest *)fetchRequest;
- (void)setSelectedCell:(NotelistCell *)cell;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)updateNotepadView;
- (void)addGestureRecognizer:(UIView *)view;
- (void)panHandler:(UIPanGestureRecognizer *)recognizer;
- (void)dropListItem:(UITableViewCell *)cell at:(CGPoint) location;
- (void)selectCell:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)editNote:(NSIndexPath *)indexPath;
- (void)insertNewObject:(id)sender;
- (void)updateObject;
- (NSIndexPath *)selectedRow;
- (void)report;
@end
