//
//  TextFieldCell.h
//  Pebble
//
//  Created by techion on 7/2/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextFieldCell : UITableViewCell {
	UITextField *textField;
	UIButton *checkboxButton;
}

@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UIButton *checkboxButton;

- (void)layoutSubviews;

@end
