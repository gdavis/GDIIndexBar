//
//  GDIAppModel.m
//  GDIIndexBarDemo
//
//  Created by Grant Davis on 1/1/14.
//  Copyright (c) 2014 Grant Davis Interactive, LLC. All rights reserved.
//

#import "GDIMockDataModel.h"

@implementation GDIMockDataModel

- (id)init
{
    self = [super init];
    if (self) {
        [self createMockData];
    }
    return self;
}

- (void)createMockData
{
    self.data = [NSMutableDictionary dictionary];
    self.sectionNames = [NSMutableArray array];
    
    NSArray *names = @[
                       @"!OMG",
                       @"?",
                       @"#hashtag",
                       @"Liam",
                       @"Noah",
                       @"Oliver",
                       @"Adian",
                       @"Asher",
                       @"Barry",
                       @"Butch",
                       @"Chris",
                       @"Drew",
                       @"Grant",
                       @"Kevin",
                       @"Carl",
                       @"Katarina",
                       @"Larissa",
                       @"Michael",
                       @"Frank",
                       @"Ryan",
                       @"Rebecca",
                       @"Owen",
                       @"Benjamin",
                       @"Declan",
                       @"Henry",
                       @"Jackson",
                       @"Ethan",
                       @"Charlotte",
                       @"Amelia",
                       @"Olivia",
                       @"Ava",
                       @"Aria",
                       @"Violet",
                       @"Sophia",
                       @"Scarlett",
                       @"Audrey",
                       @"Emma",
                       @"Nora",
                       @"Grace",
                       @"Lily",
                       @"Aurora",
                       @"Abigail",
                       @"Chloe",
                       @"Harper",
                       @"Alice",
                       @"Ella",
                       @"Claire",
                       @"Isabella",
                       @"Lucy",
                       ];
    
    // break the names into alphabetical groups
    [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        NSString *firstLetter = [name substringToIndex:1];
        NSMutableArray *namesByFirstLetter;
        
        if ([self.data objectForKey:firstLetter] == nil) {
            namesByFirstLetter = [NSMutableArray array];
            [self.data setObject:namesByFirstLetter forKey:firstLetter];
            [self.sectionNames addObject:firstLetter];
        }
        else {
            namesByFirstLetter = [self.data objectForKey:firstLetter];
        }
        
        [namesByFirstLetter addObject:name];
    }];
    
    // sort the groups
    NSArray *nameLists = [self.data allValues];
    [nameLists enumerateObjectsUsingBlock:^(NSMutableArray *namesByFirstLetter, NSUInteger idx, BOOL *stop) {
        [namesByFirstLetter sortUsingComparator:^NSComparisonResult(NSString *name1, NSString *name2) {
            return [name1 compare:name2];
        }];
    }];
    
    // sort the names
    [self.sectionNames sortUsingComparator:^NSComparisonResult(NSString *name1, NSString *name2) {
        return [name1 compare:name2];
    }];
    
    NSLog(@"Mock Data: %@", self.data);
}

@end
