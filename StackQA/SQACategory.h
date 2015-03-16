//
//  SQACategory.h
//  StackQA
//
//  Created by vsokoltsov on 15.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question;

@interface SQACategory : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Question *question;

@end
