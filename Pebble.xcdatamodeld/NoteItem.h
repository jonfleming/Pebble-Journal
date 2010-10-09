//
//  NoteItem.h
//  Pebble
//
//  Created by techion on 9/19/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Item;

@interface NoteItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Item * item;

@end



