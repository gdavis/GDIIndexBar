//
//  GDIAppModel.h
//  GDIIndexBarDemo
//
//  Created by Grant Davis on 1/1/14.
//  Copyright (c) 2014 Grant Davis Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GDIMockDataModel : NSObject

/*!
 * Stores an array of strings under a section name as the key
 */
@property (strong, nonatomic) NSMutableDictionary *data;

/*!
 * Stores the strings used to create sections and provides the string used by the index bar.
 */
@property (strong, nonatomic) NSMutableArray *sectionNames;


@end
