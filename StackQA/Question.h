//
//  Question.h
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SQACategory.h"
#import "Answer.h"
#import "User.h"
@interface Question : NSManagedObject{
   }

@property (nonatomic, retain) NSNumber * object_id;
@property (nonatomic, retain) NSNumber * category_id;
@property (nonatomic) BOOL is_closed;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSNumber * views;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSNumber * answers_count;
@property (nonatomic, retain) NSNumber * comments_count;
@property (nonatomic, retain) NSMutableArray * answers_list;
@property (nonatomic, retain) SQACategory *category;
@property (nonatomic, retain) User *user;
@property (nonatomic, strong) NSMutableSet *answers;

+ (NSDate *) correctConvertOfDate:(NSString *) date;
+ (void) create: (NSDictionary *) params;
+ (void) setQuestionsForUser:(User *) user;
+ (void) sync: (NSArray *) params;
- (void) closeQuestion;
@end
