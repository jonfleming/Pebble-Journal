//
//  ListItemViewController.h
//  Pebble
//
//  Created by techion on 7/4/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TableViewController;
@class DatePicker;

@interface ListItemViewController : UIViewController <UITextFieldDelegate> {
	TableViewController *tableViewController;
	IBOutlet UITextField *section;			//topic
	IBOutlet UITextField *listItemTitle;	//title
	IBOutlet UISegmentedControl *priorityButton;
	IBOutlet UIButton *dueDateButton;
	NSDate *dueDate;
	DatePicker *datePicker;
}
@property (nonatomic, retain) TableViewController *tableViewController;
@property (nonatomic, retain) IBOutlet UITextField *section;
@property (nonatomic, retain) IBOutlet UITextField *listItemTitle;	
@property (nonatomic, retain) IBOutlet UISegmentedControl *priorityButton;
@property (nonatomic, retain) IBOutlet UIButton *dueDateButton;
@property (nonatomic, retain) NSDate *dueDate;

- (IBAction) cancel:(id)sender;
- (IBAction) save:(id)sender;
- (IBAction) selectPriority:(id)sender;
- (IBAction) selectDueDate:(id)sender;
@end
