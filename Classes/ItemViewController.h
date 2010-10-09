//
//  EditView.h
//  Notebook
//
//  Created by techion on 5/22/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"


@class DetailViewController;
@class PopoverPicklist;

@interface ItemViewController : UIViewController <UITextFieldDelegate> {

	IBOutlet UIView *view;
	IBOutlet UITextField *itemTitle;
	IBOutlet UITextField *tags;
	IBOutlet UISegmentedControl *itemType;
	IBOutlet UINavigationItem *barItem;
	IBOutlet UISwitch *passwordProtect;
	DetailViewController *detailViewController;
	PopoverPicklist *tagPickList;
	NSArray *tagList;
}

@property (nonatomic, retain) DetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet UITextField *itemTitle;
@property (nonatomic, retain) IBOutlet UITextField *tags;
@property (nonatomic, retain) IBOutlet UISegmentedControl *itemType;
@property (nonatomic, retain) IBOutlet UINavigationItem *barItem;
@property (nonatomic, retain) IBOutlet UISwitch *passwordProtect;
@property (nonatomic, retain) PopoverPicklist *tagPickList;
@property (nonatomic, retain) NSArray *tagList;

- (IBAction) save:(id)sender;
- (IBAction) cancel:(id)sender;
- (void)getList;
- (void)updateChoices:(NSString *)substring;
- (void)updateRootView;
@end
