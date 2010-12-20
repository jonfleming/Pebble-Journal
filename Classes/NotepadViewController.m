//
//  NotepadViewController.m
//  Pebble
//
//  Created by techion on 6/24/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "NotepadViewController.h"
#import "DetailViewController.h"
#import "NotelistViewController.h"
#import "NoteTableViewController.h"
#import "LinesView.h"
#import "Utility.h"
#import "constants.h"
#import "NotelistCell.h"

@implementation NotepadViewController

@synthesize linesView, notepadView, dateLabel, imageView, dirty;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	keyboardView = notepadView;
	
	notepadView.backgroundColor = [UIColor clearColor];
	notepadView.delegate = self;
	
	NSString *text = [[NSString alloc] initWithString:@"XXX"];
	CGSize size = [text sizeWithFont: notepadView.font];
	[text release];

	linesView.lineHeight = size.height;
	linesView.backgroundColor = [UIColor clearColor];
		
	notepadView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
	notepadView.editable = FALSE;
	
	// Date label
	dateLabel = [[UILabel alloc] init];
	[dateLabel setFont:[UIFont systemFontOfSize:14]];
	dateLabel.textAlignment = UITextAlignmentLeft;
	[dateLabel setText:@""];
	dateLabel.textColor = [UIColor grayColor];
	dateLabel.backgroundColor = [UIColor clearColor];
	dateLabel.userInteractionEnabled = TRUE;
	[self positionDateLabel];
	
	[notepadView addSubview:dateLabel];
	
	// Swipe recognizer
	[self addGestureRecognizer:self.notepadView];
}

- (void)addGestureRecognizer:(UIView *)view {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
	[view addGestureRecognizer:recognizer];
	[recognizer release];

	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
	recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

- (IBAction)swipeRight:(UIPanGestureRecognizer *)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	NoteTableViewController *tableViewController = (NoteTableViewController *)detailViewController.notelistViewController.tableViewController;

	//NSIndexPath *indexPath = [detailViewController.notelistViewController indexPathForSelectedCell];
	NSIndexPath *indexPath = [tableViewController selectedPath];
	DebugLog(D_FINER, @"--- indexPath: %@:", indexPath); 
	if (indexPath) {
		if (indexPath.row > 0) {
			indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
		}
		[self turnPage:UISwipeGestureRecognizerDirectionRight];
		[self selectNote:indexPath];
	}
}

- (IBAction)swipeLeft:(UIPanGestureRecognizer *)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	NoteTableViewController *tableViewController = (NoteTableViewController *)detailViewController.notelistViewController.tableViewController;

	//NSIndexPath *indexPath = [detailViewController.notelistViewController indexPathForSelectedCell];
	NSIndexPath *indexPath = [tableViewController selectedPath];
	DebugLog(D_FINER, @"--- indexPath: %@:", indexPath); 
	if (indexPath) {
		NSInteger rows = [tableViewController tableView:tableViewController.tableView numberOfRowsInSection:0];
		indexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
		DebugLog(D_FINER, @"--- rows: %d  new indexPath: %@:", rows, indexPath); 

		if (indexPath.row < rows) {
			[self turnPage:UISwipeGestureRecognizerDirectionLeft];
			[self selectNote:indexPath];
		}
	}
}

- (void)selectNote:(NSIndexPath *)indexPath {
	DebugLog(D_TRACE, @"%s row: %d", __FUNCTION__, indexPath.row);
	[detailViewController saveNote];
	TableViewController *tableViewController = detailViewController.notelistViewController.tableViewController;
	
	[tableViewController setSelectedCell:(NotelistCell *)[tableViewController tableView:tableViewController.tableView cellForRowAtIndexPath:indexPath]];	
	[tableViewController selectCell:indexPath];
}

- (void)turnPage:(UISwipeGestureRecognizerDirection)direction {
	DebugLog(D_TRACE, @"%s direction:%@", __FUNCTION__,direction == UISwipeGestureRecognizerDirectionLeft ? @"Left":@"Right");
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	if (direction == UISwipeGestureRecognizerDirectionLeft) {
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:[self view] cache:YES];
	}
	else {
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:[self view] cache:YES];
	
	}

	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Add a new object
- (IBAction)insertNewObject:(id)sender {
	[detailViewController.notelistViewController insertNewObject:sender];
}


- (void)textViewDidChange:(UITextView *)textView {
	DebugLog(D_VERBOSE, @"%s %@", __FUNCTION__, detailViewController.item.itemTitle);
	self.dirty = TRUE;
}

- (void)setItemTitle {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	// first line of text is used for title
	NSArray *array;
	if ([notepadView.text length] > 120) {
		array = [[notepadView.text substringToIndex:120] componentsSeparatedByString:@"\n"];
	}
	else {
		array = [notepadView.text componentsSeparatedByString:@"\n"];
	}
	NSString *title = [array objectAtIndex:0];
	
	// Update NotepadView
	titleLabel.text = title;
	
	// Update Table Cell
	[detailViewController currentCell].textLabel.text = title;
	[[detailViewController currentCell]	 setNeedsLayout];
}


- (void)viewWillAppear:(BOOL)animated {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Mail Handler
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Toolbar button handlers
- (IBAction)sendNote:(id)sender {
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:titleLabel.text];
	
	/*
	UIImage *roboPic = [UIImage imageNamed:@"RobotWithPencil.jpg"];
	NSData *imageData = UIImageJPEGRepresentation(roboPic, 1);
	[picker addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"RobotWithPencil.jpg"];
	*/
	
	NSString *emailBody = notepadView.text;
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
	[picker release];	
}

- (IBAction)timestamp:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	NSString *text = [Utility formatTime:[NSDate date]];

	// Save a copy of the system pasteboard's items
	UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
	NSArray* items = [pasteboard.items copy];
	
	// Paste the text
	pasteboard.string = [text stringByAppendingString:@"\n"];
	[notepadView paste: notepadView];
	
	// Restore the system pasteboard to its original items.
	pasteboard.items = items;	
	[items release];
}

- (IBAction)showNotelist:(id)sender {
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	[detailViewController saveNote];
	[detailViewController.notelistViewController.tableViewController.tableView reloadData]; 
	[detailViewController showView:NOTELIST];
}

#pragma mark -
#pragma mark Handle Line Drawing
- (CGFloat)lineHeight {
	return linesView.lineHeight;
}

- (void) scrollViewDidScroll:(UIScrollView *) scrollView {
//	DebugLog(D_TRACE, @"%s", __FUNCTION__);
	linesView.offset = scrollView.contentOffset.y;	
	[linesView setNeedsDisplay];
}

#pragma mark -
#pragma mark Rotation support
- (void)positionDateLabel {
	CGFloat frameWidth = notepadView.frame.size.width;
	CGFloat labelWidth = DATE_LABEL_WIDTH;
	/*
	if (UIInterfaceOrientationIsLandscape(detailViewController.orientation)) {
		labelWidth = labelWidth * 1.5;
	}
	 */
	DebugLog(D_TRACE, @"%s width: %f", __FUNCTION__, labelWidth);

	dateLabel.frame = CGRectMake(frameWidth - labelWidth, -DATE_LABEL_TOP, labelWidth, DATE_LABEL_HEIGHT);
}

#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	DebugLog(D_TRACE, @"%s", __FUNCTION__);

	[linesView release];
	[notepadView release];
	[dateLabel release];
	[imageView release];
}


@end
