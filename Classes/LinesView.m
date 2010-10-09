//
//  LinesView.m
//  Notebook
//
//  Created by techion on 5/31/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "LinesView.h"


@implementation LinesView

@synthesize lineHeight, offset;

- (id) initWithFrame:(CGRect) frame {
	if (self = [super initWithFrame:frame]) {
		self.userInteractionEnabled = NO;
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		self.offset = 0; // contentOffset.y
	}
	return self;
}

- (void) drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIColor *lineColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:0.5];
	[lineColor set];
	
	CGContextSetShouldAntialias(context, NO);
	CGContextSetLineWidth(context, 1.0);
	CGFloat delta = fmod(offset, lineHeight);
	CGFloat y = lineHeight / 2.0 - 4.0 - delta;
	
	while (y < self.bounds.size.height) {
		if ( y + offset - lineHeight > 0.0) {
			CGContextMoveToPoint(context, 0, y);
			CGContextAddLineToPoint(context, self.bounds.size.width, y);
			CGContextStrokePath(context);
		}
		y += lineHeight;
	}
}
@end
