//
//  NotelistCell.h
//  Pebble
//
//  Created by techion on 7/28/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NotelistCell : UITableViewCell {
	UILabel *title;
	UILabel *summary;
}
@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UILabel *summary;

- (CGRect)dateFrame;
- (CGRect)titleFrame;
- (CGRect)summaryFrame;
- (void)layoutSubviews;

@end
