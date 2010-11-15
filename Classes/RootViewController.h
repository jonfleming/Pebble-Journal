//
//  RootViewController.h
//  Pebble
//
//  Created by techion on 6/23/10.
//  Copyright Jon Fleming 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@class DetailViewController;
@class ItemViewController;
@class Item;
@class TDBadgedCell;

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate> {
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    DetailViewController *detailViewController;
	IBOutlet ItemViewController *itemViewController;
	IBOutlet UISearchBar *theSearchBar;
	
	NSIndexPath *lastItemPath;
	NSString *lastTag;
	
	SEL postPasswordAction;
	NSArray *resourceArray;
	BOOL protect;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, assign) IBOutlet ItemViewController *itemViewController;
@property (nonatomic, assign) IBOutlet UISearchBar *theSearchBar;
@property (nonatomic, retain) NSIndexPath *lastItemPath;
@property (nonatomic, retain) NSString *lastTag;
@property (assign) SEL postPasswordAction;
@property (nonatomic, retain) NSArray *resourceArray;
@property (assign) BOOL protect;

+ (NSArray *)imageList;
+ (NSArray *)passwordPrompts;
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)setCellImage:(UITableViewCell *)cell index:(NSUInteger)index;
- (void)updateBadgeCount:(NSIndexPath *)indexPath;
- (void)setBadge:(TDBadgedCell *)cell item:(Item *)managedObject;
- (void)updateCurrentBadgeCount;
- (void)insertNewObject:(id)sender;
- (void)performSearch;
- (void)selectItem:(Item *)item;
- (void)saveObjectContext:(NSManagedObjectContext *)context;
- (BOOL)itemIsProtected:(Item *)theItem;
- (void)promptForPassword:(NSUInteger)prompt;
- (void)promptForPasswordWithIndex:(NSIndexPath *)indexPath;
- (void)promptForPasswordWithTitle:(NSString *)title;
- (void)changePassword;
- (void)updateRootView;
- (void)postShowItemView;
- (void)showItemView;
- (BOOL)functionDisabled;
- (BOOL)isSearchResult;
@end
