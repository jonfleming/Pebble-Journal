//
//  Options.h
//  Pebble
//
//  Created by techion on 9/17/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ProtectViewController;
@class SortOptions;
@class DetailViewController;

@interface Options : UIViewController {
	ProtectViewController *protectViewController;
	SortOptions *sortOptions;
	DetailViewController *detailViewController;
	UIPopoverController *popoverController;	
	UINavigationItem *navigationItem;
	// Protect Journal
	// protect?
}

@property (nonatomic, retain) IBOutlet ProtectViewController *protectViewController;
@property (nonatomic, retain) IBOutlet SortOptions *sortOptions;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;

- (void)initForProtectView;
- (void)initForSortView:(NSArray *)columns;
- (void)changePassword:(id)sender;
- (void)done:(id)sender;
@end
