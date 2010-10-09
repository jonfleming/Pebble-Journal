//
//  DatePicker.h
//  Pebble
//
//  Created by techion on 7/5/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DatePicker : UIViewController <UIPopoverControllerDelegate> {
	NSDate *selectedDate;
	IBOutlet UIDatePicker *datePicker;
	UIPopoverController *popoverController;
	NSObject *observer;
}

@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) NSObject *observer;

- (void) cancel:(id)sender;
- (void) done:(id)sender;

@end
