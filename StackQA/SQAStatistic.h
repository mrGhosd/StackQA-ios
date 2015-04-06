//
//  Statistic.h
//  StackQA
//
//  Created by vsokoltsov on 07.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface SQAStatistic : NSManagedObject

@property (nonatomic, retain) NSNumber * answers_negative_rate_count;
@property (nonatomic, retain) NSNumber * answers_positive_rate_count;
@property (nonatomic, retain) NSNumber * first_answers_count;
@property (nonatomic, retain) NSNumber * first_self_answers_count;
@property (nonatomic, retain) NSNumber * helpfull_answers_count;
@property (nonatomic, retain) NSNumber * questions_negative_rate_count;
@property (nonatomic, retain) NSNumber * questions_positive_rate_count;
@property (nonatomic, retain) NSNumber * self_answers_count;
@property (nonatomic, retain) User *user;

@end
