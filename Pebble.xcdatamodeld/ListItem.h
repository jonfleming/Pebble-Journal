//
//  ListItem.h
//  Pebble
//
//  Created by techion on 9/19/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Item;

@interface ListItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * dueDate;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic, retain) NSString * duration;
@property (nonatomic, retain) NSNumber * complete;
@property (nonatomic, retain) NSString * progress;
@property (nonatomic, retain) NSString * priority;
@property (nonatomic, retain) Item * item;

@end



