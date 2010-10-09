//
//  TabViewBaseController.h
//  Pebble
//
//  Created by techion on 8/2/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface TabViewBaseController : UIViewController {

	IBOutlet DetailViewController *detailViewController;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIToolbar *toolbar;
	UIView *keyboardView;
	BOOL keyboardUp;

}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) UIView *keyboardView;
@property (nonatomic, assign) BOOL keyboardUp;

- (void)updateTitle;

@end
