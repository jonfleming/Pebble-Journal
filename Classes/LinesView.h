//
//  LinesView.h
//  Notebook
//
//  Created by techion on 5/31/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LinesView : UIView {
	CGFloat lineHeight; 
	CGFloat offset;
}

@property (nonatomic) CGFloat lineHeight;
@property (nonatomic) CGFloat offset;

@end
