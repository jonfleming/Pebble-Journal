//
//  Item.h
//  Pebble
//
//  Created by techion on 9/19/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import <CoreData/CoreData.h>

@class ListItem;
@class NoteItem;

@interface Item :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * passwordProtected;
@property (nonatomic, retain) NSString * itemType;
@property (nonatomic, retain) NSString * itemTitle;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSNumber * lastNoteItemRow;
@property (nonatomic, retain) NSString * sortField;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSNumber * showCompleted;
@property (nonatomic, retain) NSNumber * sortAscending;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSSet* noteItems;
@property (nonatomic, retain) NSSet* listItems;

@end


@interface Item (CoreDataGeneratedAccessors)
- (void)addNoteItemsObject:(NoteItem *)value;
- (void)removeNoteItemsObject:(NoteItem *)value;
- (void)addNoteItems:(NSSet *)value;
- (void)removeNoteItems:(NSSet *)value;

- (void)addListItemsObject:(ListItem *)value;
- (void)removeListItemsObject:(ListItem *)value;
- (void)addListItems:(NSSet *)value;
- (void)removeListItems:(NSSet *)value;

@end

