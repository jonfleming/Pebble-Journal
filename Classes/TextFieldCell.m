//
//  TextFieldCell.m
//  Pebble
//
//  Created by techion on 7/2/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "TextFieldCell.h"

#define CELL_WIDTH (self.contentView.frame.size.width)
#define CONTENT_Y 4.0
#define CONTENT_HEIGHT 27.0
#define CHECKBOX_X	3.0
#define CHECKBOX_WIDTH 28.0
#define DATE_WDITH 115.0
#define LABEL_X 30.0
#define LABEL_WIDTH (CELL_WIDTH - LABEL_X - DATE_WDITH)
#define LABEL_PADDING 5.0

#define EDIT_OFFSET 77.0

@implementation TextFieldCell

@synthesize textField, checkboxButton;

- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.textLabel.frame = CGRectMake(LABEL_X , CONTENT_Y, LABEL_WIDTH - LABEL_PADDING, CONTENT_HEIGHT);
	self.textField.frame = CGRectMake(LABEL_X , CONTENT_Y, LABEL_WIDTH - LABEL_PADDING, CONTENT_HEIGHT);
	self.detailTextLabel.frame = CGRectMake(CELL_WIDTH - DATE_WDITH, CONTENT_Y, DATE_WDITH, CONTENT_HEIGHT);
	self.detailTextLabel.textAlignment = UITextAlignmentLeft;
	self.checkboxButton.frame = CGRectMake(CHECKBOX_X, 1.0, CHECKBOX_WIDTH, CHECKBOX_WIDTH);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc {
    [super dealloc];
	[textField release];
	[checkboxButton release];
}

@end
