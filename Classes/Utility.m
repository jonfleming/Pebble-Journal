//
//  Utility.m
//  Pebble
//
//  Created by techion on 7/3/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "Utility.h"
#import "constants.h"

@implementation Utility

+ (int)viewIndex:(int)view {
	int index = 0;
	
	switch (view) {
		case NOTELIST:
		case NOTEPAD:
			index = 0;
			break;
		case CHECKLIST:
			index = 1;
			break;
	}
	return index;
}

+ (NSString *)formatDate:(NSDate *)date {
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSString *formattedDateString = [dateFormatter stringFromDate:date];
	
	return formattedDateString;
}

+ (NSString *)formatTime:(NSDate *)date {
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSString *formattedDateString = [dateFormatter stringFromDate:date];
	
	return formattedDateString;
}

+ (NSString *)intervalToString:(NSDate *)date {
	NSString *returnValue = @"";
	NSCalendar *cal = [NSCalendar currentCalendar]; 
	
	NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
	NSDate *day = [cal dateFromComponents:comps];

	comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
	NSDate *today =  [cal dateFromComponents:comps];

	NSDateComponents *components = [[NSDateComponents alloc] init]; 
	[components setDay:-1]; 
	NSDate *yesterday = [cal dateByAddingComponents:components toDate:today options:0]; 

	[components setDay:1]; 
	NSDate *tomorrow = [cal dateByAddingComponents:components toDate:today options:0]; 
	
	if([day isEqualToDate:today]) 
		returnValue = @"Today";

	if([day isEqualToDate:yesterday])
		returnValue = @"Yesterday";

	if([day isEqualToDate:tomorrow])
		returnValue = @"Tomorrow";	
	
	
	return returnValue;
}

+ (UIColor *)colorForDueDate:(NSDate *)date {
	UIColor *color;
	
	NSCalendar *cal = [NSCalendar currentCalendar]; 
	
	NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
	NSDate *day = [cal dateFromComponents:comps];
	
	comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
	NSDate *today =  [cal dateFromComponents:comps];

	NSComparisonResult compare = [day compare:today];
	
	if(compare == NSOrderedAscending) {
		// Past
		color = [UIColor redColor];
	}
	else {		
		if(compare == NSOrderedDescending) {
			// Future
			color = [UIColor greenColor];
		}
		else {
			// Same
			color = [UIColor orangeColor];
		}
	}
	
	return color;
}

+ (NSString *)formatBool:(BOOL)value {
	return value?@"YES":@"NO";
}
@end
