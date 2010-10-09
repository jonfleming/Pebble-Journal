//
//  DetailViewController.h
//  Pebble
//
//  Created by techion on 6/23/10.
//  Copyright Jon Fleming 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Item.h"
#import "DebugLog.h"

@class RootViewController;
@class NotepadViewController;
@class ChecklistViewController;
@class NotelistViewController;
@class TabViewBaseController;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITabBarControllerDelegate, UITabBarDelegate, UIActionSheetDelegate> {
    
	UIWindow *window;
	
    IBOutlet RootViewController *rootViewController;

	IBOutlet UIPopoverController *popoverController;
	IBOutlet UITabBarController *tabBarController;
	IBOutlet UIPopoverController *editViewPopoverController;
	
	IBOutlet NotepadViewController *notepadViewController;
	IBOutlet ChecklistViewController *checklistViewController;
	IBOutlet NotelistViewController *notelistViewController;

    Item *item;
	BOOL buttonShowing;
	BOOL changingViews;
	UIBarButtonItem *popoverButton;
	UIInterfaceOrientation orientation;
	
	NSMutableArray *viewStatusArray;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, assign) IBOutlet RootViewController *rootViewController;

@property (nonatomic, assign) IBOutlet UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, assign) IBOutlet NotepadViewController *notepadViewController;
@property (nonatomic, assign) IBOutlet ChecklistViewController *checklistViewController;
@property (nonatomic, assign) IBOutlet NotelistViewController *notelistViewController;

@property (nonatomic, retain) Item *item;
@property (nonatomic, assign) BOOL buttonShowing;
@property (nonatomic, assign) BOOL changingViews;
@property (nonatomic, retain) UIBarButtonItem *popoverButton;
@property (nonatomic, assign) UIInterfaceOrientation orientation;

@property (nonatomic, retain) NSMutableArray *viewStatusArray;

- (IBAction)insertNewItem:(id)sender;
- (void)saveItem;
- (void)savePosition;
- (void)saveNote;
- (void)configureView:(NSUInteger)index;
- (void)resizeSubviews;
- (void)reportFrames;
- (void) refreshAfterItemEdit;
- (NSInteger) entityCount:(NSString *)entityName item:(Item *)theItem;

- (void)toolbarEnabled:(BOOL)enabled;
- (void)updatePopoverButton;
- (void)showPopoverButton:(UIToolbar *)toolbar;
- (void)removePopoverButton:(UIToolbar *)toolbar;
- (void)showView:(NSUInteger)index;
- (void)updateNotepadView;
- (void)initializeView:(NSUInteger)index;
- (void)reloadData:(NSUInteger)index;

- (UITableViewCell *)currentCell;
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;
- (void)scrollViewForKeyboard:(TabViewBaseController *)viewController notification:(NSNotification*)aNotification up:(BOOL)up;
- (void)moveUp:(id)sender;
- (void)moveDown:(id)sender;

@end
