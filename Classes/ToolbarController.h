//
//  ToolbarController.h
//  Pebble
//
//  Created by techion on 6/25/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ToolbarController : UIViewController {

	UIToolbar *toolbar;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

- (void) repositionToolbar:(UIInterfaceOrientation) interfaceOrientation;

@end
