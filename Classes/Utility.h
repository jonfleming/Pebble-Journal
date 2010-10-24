//
//  Utility.h
//  Pebble
//
//  Created by techion on 7/3/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define YESNO(a) [Utility formatBool:a]

@interface Utility : NSObject {

}

+ (int)viewIndex:(int)view;
+ (NSString *)formatDate:(NSDate *)date;
+ (NSString *)formatTime:(NSDate *)date;
+ (NSString *)intervalToString:(NSDate *)date;
+ (UIColor *)colorForDueDate:(NSDate *)date;
+ (NSString *)formatBool:(BOOL)value;
@end
