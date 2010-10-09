//
//  NotelistCell.m
//  Pebble
//
//  Created by techion on 7/28/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "NotelistCell.h"

#define CONTENT_Y 4.0
#define CONTENT_HEIGHT 23.0
#define PADDING 5.0

#define DATE_X	8.0
#define TITLE_X 120.0
#define SUMMARY_X 300.0
#define DATE_WIDTH (TITLE_X - DATE_X - PADDING)
#define TITLE_WIDTH (SUMMARY_X - TITLE_X - PADDING)
#define SUMMARY_WIDTH (self.contentView.frame.size.width - SUMMARY_X - PADDING)

#define EDIT_OFFSET 77.0

@implementation NotelistCell

@synthesize title, summary;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

- (CGRect)dateFrame {
	return CGRectMake(DATE_X, CONTENT_Y, DATE_WIDTH, CONTENT_HEIGHT); 
}

- (CGRect)titleFrame {
	return CGRectMake(TITLE_X, CONTENT_Y, TITLE_WIDTH, CONTENT_HEIGHT); 
}

- (CGRect)summaryFrame {
	return CGRectMake(SUMMARY_X, CONTENT_Y, SUMMARY_WIDTH, CONTENT_HEIGHT); 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
    self.textLabel.frame = [self dateFrame];
	self.title.frame = [self titleFrame];
	self.summary.frame = [self summaryFrame];
	
	if (self.selected) {
		self.title.textColor = [UIColor whiteColor];
		self.summary.textColor = [UIColor whiteColor];
	}
	else {
		self.title.textColor = [UIColor blackColor];
		self.summary.textColor = [UIColor blackColor];
	}

}

- (void)dealloc {
    [super dealloc];
	[title release];
	[summary release];
}


@end
