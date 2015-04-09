//
//  Question.m
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "Question.h"
#import "AppDelegate.h"
#import <CoreData+MagicalRecord.h>


@implementation Question

@dynamic object_id;
@dynamic category_id;
@dynamic rate;
@dynamic title;
@dynamic views;
@dynamic is_closed;
@dynamic created_at;
@dynamic user_id;
@dynamic text;
@dynamic answers_count;
@dynamic comments_count;
@dynamic answers_list;

+ (NSDate *) correctConvertOfDate:(NSString *) date{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *correctDate = [dateFormat dateFromString:date];
    return correctDate;
}

+ (void) create: (NSDictionary *) params{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
        Question *question = [self defineQuestionWithId:params[@"id"] andContext:localContext];
        [self setParams:params toQuestion:question];
        [localContext MR_save];
    }];
}

+ (Question *) defineQuestionWithId: (id) object_id andContext: (NSManagedObjectContext *) context{
    Question *q;
    Question *current_q = [Question MR_findFirstByAttribute:@"object_id" withValue:object_id];
    if(current_q){
        q = current_q;
    } else {
        q = [Question MR_createInContext:context];
    }
    return q;
}

+ (void) setParams:(NSDictionary *)params toQuestion:(Question *) question{
    question.object_id = params[@"id"];
    question.user_id = params[@"user_id"];
    question.category_id = params[@"category_id"];
    question.rate = params[@"rate"];
    question.title = params[@"title"];
    question.created_at = [self correctConvertOfDate:params[@"created_at"]];
    question.answers_count = params[@"answers_count"];
    question.comments_count = params[@"comments_count"];
    question.text = params[@"text"];
}

@end
