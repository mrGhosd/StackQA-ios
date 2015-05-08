//
//  SQACategory.h
//  StackQA
//
//  Created by vsokoltsov on 15.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@class Question;

@interface SQACategory : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * object_id;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSMutableSet *questions;
+ (void) sync: (NSArray *) params;
+ (void) create: (NSDictionary *) params;
- (UIImage *) categoryImage;
- (NSMutableArray *) questionsList;
@end
