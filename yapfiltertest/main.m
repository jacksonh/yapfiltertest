//
//  main.m
//  yapfiltertest
//
//  Created by Jackson Harper on 1/7/14.
//  Copyright (c) 2014 SyntaxTree. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <YapDatabase.h>
#import <YapDatabaseFilteredView.h>


void loadFilteredView (void);


static NSString * const DBPath = @"test.db";


int main(int argc, const char * argv[])
{

	@autoreleasepool {
	    
		if (argc > 1 && !strcmp (argv [1], "--reset"))
			[[NSFileManager defaultManager] removeItemAtPath:DBPath error:nil];

	    loadFilteredView ();
	}
    return 0;
}


void
loadFilteredView (void)
{
	YapDatabase *db = [[YapDatabase alloc] initWithPath:DBPath];
	YapDatabaseConnection *conn = [db newConnection];

	YapDatabaseViewGroupingWithKeyBlock groupingBlock = ^NSString *(NSString *collection, NSString *key){
		return @"group";
	};

	YapDatabaseViewSortingWithObjectBlock sortingBlock = ^(NSString *group,
														   NSString *collection1, NSString *key1, id obj1,
														   NSString *collection2, NSString *key2, id obj2){
		return NSOrderedSame;
	};

	YapDatabaseView *view = [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock
														 groupingBlockType:YapDatabaseViewBlockTypeWithKey
															  sortingBlock:sortingBlock
														  sortingBlockType:YapDatabaseViewBlockTypeWithObject
																   version:0
																   options:nil];
	[db registerExtension:view withName:@"view"];

	
	YapDatabaseViewFilteringBlock filteringBlock  = ^BOOL (NSString *group, NSString *collection,
														   NSString *key, id object){
		return YES;
	};

	YapDatabaseFilteredView *filteredView = [[YapDatabaseFilteredView alloc] initWithParentViewName:@"view"
																					 filteringBlock:filteringBlock
																				 filteringBlockType:YapDatabaseViewBlockTypeWithObject
																								tag:@"one"];
	
	[db registerExtension:filteredView withName:@"filteredView"];

	[conn readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
		[transaction setObject:@"object1" forKey:@"_theKey1" inCollection:@"theCollection"];
	}];
}
