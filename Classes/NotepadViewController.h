//
//  NotepadViewController.h
//  Pebble
//
//  Created by techion on 6/24/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabViewBaseController.h"

@class DetailViewController;
@class LinesView;

@interface NotepadViewController : TabViewBaseController <UITextViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate> {
	IBOutlet LinesView *linesView;
	IBOutlet UITextView *notepadView;

	IBOutlet UILabel *dateLabel;
	IBOutlet UIImageView *imageView;
	
	BOOL dirty;
}

@property (nonatomic, retain) IBOutlet LinesView *linesView;
@property (nonatomic, retain) IBOutlet UITextView *notepadView;

@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@property (nonatomic, assign) BOOL dirty;

- (void)positionDateLabel;
- (IBAction)showNotelist:(id)sender;
- (CGFloat)lineHeight;
- (IBAction)insertNewObject:(id)sender;
- (void)addGestureRecognizer:(UIView *)view;
- (void)selectNote:(NSIndexPath *)indexPath;
- (void)turnPage:(UISwipeGestureRecognizerDirection)direction;
@end

